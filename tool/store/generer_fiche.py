#!/usr/bin/env python3
"""Génère les localisations de la fiche App Store à partir de la fiche française.

Pour chaque langue : un agent rédacteur écrit la fiche, ce script en vérifie
les règles mesurables (limites, format des mots-clés, termes interdits), puis
un agent relecteur juge la conformité et la langue. Tant qu'il reste un
problème bloquant, le rédacteur réécrit avec ces retours (3 tours au plus).
Une langue qui échoue n'est pas écrite. Rien n'est envoyé à Apple ici :
voir release_ios.sh.

Les agents passent par la CLI `claude` (abonnement Claude Code de la machine),
sans outils, sans hooks ni serveurs MCP du projet.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path

DOSSIER_OUTIL = Path(__file__).resolve().parent
RACINE = DOSSIER_OUTIL.parents[1]
METADATA = RACINE / "ios" / "fastlane" / "metadata"
RAPPORT = RACINE / "build" / "fiche_store" / "rapport.md"

LOCALE_SOURCE = "fr-FR"
LOCALE_REFERENCE = "en-US"
MODELE = os.environ.get("KOUDI_STORE_MODELE", "opus")
BUDGET_PAR_APPEL_USD = os.environ.get("KOUDI_STORE_BUDGET_APPEL", "2")
TOURS_MAX = 3

CHAMPS_FICHE = ["name", "subtitle", "promotional_text", "description", "keywords"]
LIMITES = {
    "name": 30,
    "subtitle": 30,
    "promotional_text": 170,
    "description": 4000,
    "keywords": 100,
    "release_notes": 4000,
}

# Termes vérifiables mécaniquement dans toutes les langues. Les interdits qui
# dépendent du sens (conseil financier, prêt, « meilleure app »…) sont jugés
# par le relecteur à partir du tableau de DEPLOIEMENT_IOS.md.
TERMES_INTERDITS = [
    "android", "google play", "play store", "ynab", "revolut", "orange money",
    "m-pesa", "mpesa", "bitcoin", "crypto", "lorem ipsum", "beta", "bêta",
]
# Sensible à la casse : « todo » est un mot courant en espagnol et en portugais.
MARQUEURS_BROUILLON = ["TODO", "TBD", "FIXME", "XXX"]
TERMES_INTERDITS_EN_TETE = [
    "iphone", "apple", "app store", "free", "gratuit", "gratis", "grátis",
    "gratuito", "kostenlos", "مجاني", "مجانا",
]

SCHEMA_FICHE = {
    "type": "object",
    "properties": {
        **{c: {"type": "string"} for c in CHAMPS_FICHE},
        "release_notes": {"type": "string"},
        "note_pour_relecteur": {"type": "string"},
    },
    "required": CHAMPS_FICHE + ["release_notes", "note_pour_relecteur"],
    "additionalProperties": False,
}

SCHEMA_REVUE = {
    "type": "object",
    "properties": {
        "problemes": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "champ": {"type": "string", "enum": CHAMPS_FICHE + ["release_notes"]},
                    "gravite": {"type": "string", "enum": ["bloquant", "mineur"]},
                    "passage": {"type": "string"},
                    "explication": {"type": "string"},
                    "correction_proposee": {"type": "string"},
                },
                "required": ["champ", "gravite", "passage", "explication", "correction_proposee"],
                "additionalProperties": False,
            },
        },
        "appreciation": {"type": "string"},
    },
    "required": ["problemes", "appreciation"],
    "additionalProperties": False,
}

SCHEMA_NOTES = {
    "type": "object",
    "properties": {"fr": {"type": "string"}, "en": {"type": "string"}},
    "required": ["fr", "en"],
    "additionalProperties": False,
}


class ErreurAgent(RuntimeError):
    pass


def appeler_claude(prompt: str, schema: dict, effort: str = "high") -> dict:
    commande = [
        "claude", "-p",
        "--output-format", "json",
        "--json-schema", json.dumps(schema),
        "--tools", "",
        "--model", MODELE,
        "--effort", effort,
        "--max-budget-usd", BUDGET_PAR_APPEL_USD,
        "--no-session-persistence",
        "--strict-mcp-config",
        "--setting-sources", "",
    ]
    # Lancé hors du dépôt : l'agent ne doit lire que ce qu'on lui donne.
    with tempfile.TemporaryDirectory() as dossier_vide:
        res = subprocess.run(
            commande, input=prompt, capture_output=True, text=True,
            timeout=900, cwd=dossier_vide,
        )
    # D'autres lignes (journaux de plugins) peuvent précéder le JSON final.
    for ligne in reversed(res.stdout.splitlines()):
        ligne = ligne.strip()
        if not ligne.startswith("{"):
            continue
        try:
            resultat = json.loads(ligne)
        except json.JSONDecodeError:
            continue
        if resultat.get("type") != "result":
            continue
        if resultat.get("is_error") or "structured_output" not in resultat:
            raise ErreurAgent(str(resultat.get("result"))[:500])
        return resultat["structured_output"]
    raise ErreurAgent(f"réponse illisible (code {res.returncode}) : {res.stderr[-500:]}")


def lire_fiche(locale: str) -> dict[str, str]:
    dossier = METADATA / locale
    return {c: (dossier / f"{c}.txt").read_text(encoding="utf-8").strip() for c in CHAMPS_FICHE}


def formater_fiche(fiche: dict[str, str]) -> str:
    return "\n\n".join(f"### {c}\n{fiche[c]}" for c in CHAMPS_FICHE + ["release_notes"] if fiche.get(c))


def formulations_a_eviter() -> str:
    texte = (RACINE / "docs" / "DEPLOIEMENT_IOS.md").read_text(encoding="utf-8")
    debut = texte.index("## 5. Formulations à éviter")
    fin = texte.index("## 6.", debut)
    return texte[debut:fin].strip()


def remplir(gabarit: str, **valeurs: str) -> str:
    for cle, valeur in valeurs.items():
        gabarit = gabarit.replace("{{" + cle + "}}", valeur)
    reste = re.findall(r"\{\{[A-Z_]+\}\}", gabarit)
    if reste:
        raise ValueError(f"marqueurs non remplis : {reste}")
    return gabarit


def _contient(texte: str, terme: str) -> bool:
    return re.search(r"(?<!\w)" + re.escape(terme) + r"(?!\w)", texte.casefold()) is not None


def valider(locale: str, fiche: dict[str, str], notes_attendues: bool) -> tuple[list[str], list[str]]:
    """Règles mesurables : renvoie (erreurs bloquantes, avertissements)."""
    erreurs: list[str] = []
    avertissements: list[str] = []
    champs = CHAMPS_FICHE + (["release_notes"] if notes_attendues else [])

    for champ in champs:
        valeur = fiche.get(champ, "")
        if not valeur.strip():
            erreurs.append(f"{champ} est vide.")
        elif len(valeur) > LIMITES[champ]:
            erreurs.append(f"{champ} fait {len(valeur)} caractères, limite {LIMITES[champ]}.")

    if not fiche.get("name", "").startswith("Koudi Na"):
        erreurs.append("name doit commencer exactement par « Koudi Na ».")

    mots_cles = fiche.get("keywords", "")
    termes = mots_cles.split(",")
    if any(t != t.strip() for t in termes):
        erreurs.append("keywords : pas d'espace autour des virgules.")
    if any(not t.strip() for t in termes):
        erreurs.append("keywords : terme vide (virgule en trop).")
    vus: set[str] = set()
    for t in (t.strip().casefold() for t in termes):
        if t and t in vus:
            erreurs.append(f"keywords : « {t} » en double.")
        vus.add(t)
    en_tete = f"{fiche.get('name', '')} {fiche.get('subtitle', '')}".casefold()
    deja_indexes = [t for t in vus if t and _contient(en_tete, t)]
    if deja_indexes:
        avertissements.append(
            "keywords : déjà indexés via le nom ou le sous-titre, place perdue : "
            + ", ".join(sorted(deja_indexes))
        )

    for champ in champs:
        for terme in TERMES_INTERDITS:
            if _contient(fiche.get(champ, ""), terme):
                erreurs.append(f"{champ} contient le terme interdit « {terme} ».")
        for marqueur in MARQUEURS_BROUILLON:
            if re.search(r"\b" + marqueur + r"\b", fiche.get(champ, "")):
                erreurs.append(f"{champ} contient le marqueur de brouillon « {marqueur} ».")
    for champ in ("name", "subtitle", "keywords"):
        for terme in TERMES_INTERDITS_EN_TETE:
            if _contient(fiche.get(champ, ""), terme):
                erreurs.append(f"{champ} contient « {terme} » (interdit dans le nom, le sous-titre et les mots-clés).")

    if locale.startswith("ar"):
        description = fiche.get("description", "")
        lettres = [c for c in description if c.isalpha()]
        arabes = [c for c in lettres if "؀" <= c <= "ۿ"]
        if lettres and len(arabes) / len(lettres) < 0.6:
            erreurs.append("description : la fiche ar-SA doit être rédigée en arabe.")

    return erreurs, avertissements


@dataclass
class Resultat:
    locale: str
    ok: bool
    tours: int
    fiche: dict[str, str] | None = None
    remarques: list[str] = field(default_factory=list)


def localiser(locale: str, marche: dict, contexte: dict) -> Resultat:
    gabarit_redacteur = (DOSSIER_OUTIL / "prompts" / "redacteur.md").read_text(encoding="utf-8")
    gabarit_relecteur = (DOSSIER_OUTIL / "prompts" / "relecteur.md").read_text(encoding="utf-8")
    notes_fr = contexte["notes_fr"]
    consigne_notes = (
        f"adapte dans la langue cible les notes de version françaises suivantes, sans rien ajouter : « {notes_fr} »"
        if notes_fr
        else "laisse ce champ vide (première version, Apple n'affiche pas de notes)."
    )

    def rediger(precedent: dict[str, str] | None, consigne: str, retours: list[str]) -> dict[str, str]:
        tour_precedent = ""
        if precedent is not None:
            tour_precedent = (
                "\n<tour_precedent>\nTa version précédente :\n\n"
                + formater_fiche(precedent)
                + f"\n\n{consigne} (garde tout le reste) :\n- "
                + "\n- ".join(retours)
                + "\n</tour_precedent>\n"
            )
        fiche = appeler_claude(
            remplir(
                gabarit_redacteur,
                LANGUE=marche["langue"], MARCHE=marche["marche"], LOCALE=locale,
                CONSIGNES=marche["consignes"], CONSIGNE_NOTES=consigne_notes,
                FAITS=contexte["faits"], FORMULATIONS=contexte["formulations"],
                SOURCE_FR=contexte["source_fr"], REFERENCE_EN=contexte["reference_en"],
                TOUR_PRECEDENT=tour_precedent,
            ),
            SCHEMA_FICHE,
        )
        return {k: v.strip() for k, v in fiche.items()}

    def relire(fiche: dict[str, str]) -> tuple[list[dict], list[dict], str]:
        revue = appeler_claude(
            remplir(
                gabarit_relecteur,
                LANGUE=marche["langue"], MARCHE=marche["marche"], LOCALE=locale,
                FAITS=contexte["faits"], FORMULATIONS=contexte["formulations"],
                SOURCE_FR=contexte["source_fr"],
                NOTE_REDACTEUR=fiche["note_pour_relecteur"],
                CANDIDAT=formater_fiche(fiche),
            ),
            SCHEMA_REVUE,
        )
        bloquants = [p for p in revue["problemes"] if p["gravite"] == "bloquant"]
        mineurs = [p for p in revue["problemes"] if p["gravite"] == "mineur"]
        return bloquants, mineurs, revue["appreciation"]

    def detailler(problemes: list[dict]) -> list[str]:
        return [
            f"[{p['champ']}] « {p['passage']} » : {p['explication']} Correction proposée : {p['correction_proposee']}"
            for p in problemes
        ]

    candidat: dict[str, str] | None = None
    retours: list[str] = []
    for tour in range(1, TOURS_MAX + 1):
        candidat = rediger(candidat, "Problèmes à corriger", retours)

        erreurs, avertissements = valider(locale, candidat, notes_attendues=bool(notes_fr))
        if erreurs:
            retours = erreurs + avertissements
            print(f"  {locale} tour {tour} : {len(erreurs)} erreur(s) de format, réécriture", flush=True)
            continue

        bloquants, mineurs, appreciation = relire(candidat)
        if bloquants:
            retours = detailler(bloquants) + avertissements
            print(f"  {locale} tour {tour} : {len(bloquants)} problème(s) bloquant(s) du relecteur, réécriture", flush=True)
            continue

        # Validée. Un tour de finition applique les remarques de style ; il
        # n'est gardé que s'il repasse les deux contrôles sans bloquant.
        if mineurs or avertissements:
            fini = rediger(candidat, "Remarques de style du relecteur à appliquer", detailler(mineurs) + avertissements)
            erreurs_fini, avertissements_fini = valider(locale, fini, notes_attendues=bool(notes_fr))
            if not erreurs_fini:
                bloquants_fini, mineurs_fini, appreciation_fini = relire(fini)
                if not bloquants_fini:
                    candidat, mineurs, avertissements, appreciation = (
                        fini, mineurs_fini, avertissements_fini, appreciation_fini,
                    )
                    print(f"  {locale} : finition appliquée", flush=True)

        print(f"  {locale} : validée au tour {tour}", flush=True)
        remarques = avertissements + [
            f"[{p['champ']}] {p['explication']} → {p['correction_proposee']}" for p in mineurs
        ]
        return Resultat(locale, True, tour, candidat, [appreciation, *remarques])

    return Resultat(locale, False, TOURS_MAX, candidat, retours)


def generer_notes(depuis: str) -> tuple[str, str]:
    commits = subprocess.run(
        ["git", "log", "--no-merges", "--format=- %s%n%b", f"{depuis}..HEAD"],
        cwd=RACINE, capture_output=True, text=True, check=True,
    ).stdout.strip()
    if not commits:
        return "", ""
    gabarit = (DOSSIER_OUTIL / "prompts" / "notes_version.md").read_text(encoding="utf-8")
    notes = appeler_claude(remplir(gabarit, COMMITS=commits), SCHEMA_NOTES, effort="medium")
    for langue, texte in notes.items():
        if len(texte) > LIMITES["release_notes"]:
            raise ErreurAgent(f"notes {langue} trop longues ({len(texte)} car.)")
    return notes["fr"].strip(), notes["en"].strip()


def derniere_version() -> str | None:
    res = subprocess.run(
        ["git", "describe", "--tags", "--abbrev=0"], cwd=RACINE, capture_output=True, text=True,
    )
    return res.stdout.strip() if res.returncode == 0 else None


def ecrire(locale: str, fiche: dict[str, str]) -> None:
    dossier = METADATA / locale
    dossier.mkdir(parents=True, exist_ok=True)
    for champ in CHAMPS_FICHE + ["release_notes"]:
        chemin = dossier / f"{champ}.txt"
        if fiche.get(champ):
            chemin.write_text(fiche[champ], encoding="utf-8")
        elif chemin.exists():
            chemin.unlink()
    # Même politique de confidentialité pour toutes les langues.
    url = (METADATA / LOCALE_SOURCE / "privacy_url.txt").read_text(encoding="utf-8").strip()
    (dossier / "privacy_url.txt").write_text(url, encoding="utf-8")


def ecrire_rapport(resultats: list[Resultat], depuis: str | None) -> None:
    lignes = ["# Rapport de génération de la fiche App Store", ""]
    lignes.append(f"Notes de version depuis : {depuis or 'aucune (première version)'}")
    lignes.append("")
    for r in resultats:
        statut = f"validée au tour {r.tours}" if r.ok else f"ÉCHEC après {r.tours} tours, non écrite"
        lignes += [f"## {r.locale} — {statut}", ""]
        lignes += [f"- {m}" for m in r.remarques] or ["- (aucune remarque)"]
        lignes.append("")
    RAPPORT.parent.mkdir(parents=True, exist_ok=True)
    RAPPORT.write_text("\n".join(lignes), encoding="utf-8")


def main() -> int:
    marches = json.loads((DOSSIER_OUTIL / "marches.json").read_text(encoding="utf-8"))
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--locales", help=f"sous-ensemble séparé par des virgules (défaut : {','.join(marches)})")
    parser.add_argument("--depuis", help="référence git des notes de version (défaut : dernier tag)")
    parser.add_argument("--sans-notes", action="store_true", help="ne pas générer de notes de version")
    args = parser.parse_args()

    locales = args.locales.split(",") if args.locales else list(marches)
    inconnues = [l for l in locales if l not in marches]
    if inconnues:
        parser.error(f"locales sans entrée dans marches.json : {', '.join(inconnues)}")

    depuis = None if args.sans_notes else (args.depuis or derniere_version())
    notes_fr = notes_en = ""
    if depuis:
        print(f"Notes de version depuis {depuis}…", flush=True)
        notes_fr, notes_en = generer_notes(depuis)
        for locale, notes in ((LOCALE_SOURCE, notes_fr), (LOCALE_REFERENCE, notes_en)):
            if notes:
                (METADATA / locale / "release_notes.txt").write_text(notes, encoding="utf-8")

    contexte = {
        "faits": (DOSSIER_OUTIL / "faits_produit.md").read_text(encoding="utf-8"),
        "formulations": formulations_a_eviter(),
        "source_fr": formater_fiche({**lire_fiche(LOCALE_SOURCE), "release_notes": notes_fr}),
        "reference_en": formater_fiche({**lire_fiche(LOCALE_REFERENCE), "release_notes": notes_en}),
        "notes_fr": notes_fr,
    }
    # La fiche source doit elle-même respecter les règles mesurables.
    for locale in (LOCALE_SOURCE, LOCALE_REFERENCE):
        erreurs, _ = valider(locale, lire_fiche(locale), notes_attendues=False)
        if erreurs:
            print(f"Fiche {locale} invalide, corrige-la d'abord :\n- " + "\n- ".join(erreurs))
            return 1

    print(f"Localisation de {len(locales)} langue(s) avec le modèle « {MODELE} »…", flush=True)

    def tache(locale: str) -> Resultat:
        try:
            return localiser(locale, marches[locale], contexte)
        except (ErreurAgent, subprocess.TimeoutExpired) as e:
            print(f"  {locale} : erreur de l'agent : {e}", flush=True)
            return Resultat(locale, False, 0, remarques=[f"Erreur de l'agent : {e}"])

    with ThreadPoolExecutor(max_workers=4) as pool:
        resultats = list(pool.map(tache, locales))

    for r in resultats:
        if r.ok and r.fiche:
            ecrire(r.locale, r.fiche)
    ecrire_rapport(resultats, depuis)

    echecs = [r.locale for r in resultats if not r.ok]
    print(f"\nRapport détaillé : {RAPPORT.relative_to(RACINE)}")
    if echecs:
        print(f"Langues en échec (non écrites) : {', '.join(echecs)}")
        return 1
    print("Toutes les langues sont validées.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
