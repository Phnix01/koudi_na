import unittest

from generer_fiche import CHAMPS_FICHE, lire_fiche, valider

FICHE_OK = {
    "name": "Koudi Na – Presupuesto",
    "subtitle": "Cada peso en su sitio",
    "promotional_text": "Anota un gasto en tres toques.",
    "description": "Todo el mes, claro. Sin cuenta, sin servidor.",
    "keywords": "gastos,ahorro,finanzas",
}


class ValiderTest(unittest.TestCase):
    def test_fiche_correcte(self):
        erreurs, avertissements = valider("es-MX", FICHE_OK, notes_attendues=False)
        self.assertEqual(erreurs, [])
        self.assertEqual(avertissements, [])

    def test_todo_espagnol_n_est_pas_un_brouillon(self):
        erreurs, _ = valider("es-ES", {**FICHE_OK, "description": "Todo tu dinero, todo el mes."}, False)
        self.assertEqual(erreurs, [])

    def test_marqueur_de_brouillon(self):
        erreurs, _ = valider("es-ES", {**FICHE_OK, "description": "TODO: écrire"}, False)
        self.assertTrue(any("brouillon" in e for e in erreurs))

    def test_limite_de_caracteres(self):
        erreurs, _ = valider("de-DE", {**FICHE_OK, "subtitle": "x" * 31}, False)
        self.assertTrue(any("subtitle fait 31" in e for e in erreurs))

    def test_nom_doit_commencer_par_la_marque(self):
        erreurs, _ = valider("it", {**FICHE_OK, "name": "Budget – Koudi Na"}, False)
        self.assertTrue(any("Koudi Na" in e for e in erreurs))

    def test_mots_cles_espace_vide_et_doublon(self):
        for mots_cles, attendu in [
            ("gastos, ahorro", "espace"),
            ("gastos,,ahorro", "vide"),
            ("gastos,Gastos", "double"),
        ]:
            erreurs, _ = valider("es-ES", {**FICHE_OK, "keywords": mots_cles}, False)
            self.assertTrue(any(attendu in e for e in erreurs), mots_cles)

    def test_mot_cle_deja_dans_le_nom_est_un_avertissement(self):
        erreurs, avertissements = valider("es-ES", {**FICHE_OK, "keywords": "presupuesto,ahorro"}, False)
        self.assertEqual(erreurs, [])
        self.assertTrue(avertissements)

    def test_plateforme_concurrente_interdite(self):
        erreurs, _ = valider("pt-BR", {**FICHE_OK, "description": "Também no Google Play."}, False)
        self.assertTrue(erreurs)

    def test_gratuit_interdit_dans_le_nom_mais_pas_ailleurs(self):
        erreurs, _ = valider("pt-BR", {**FICHE_OK, "subtitle": "Orçamento grátis"}, False)
        self.assertTrue(erreurs)

    def test_fiche_arabe_doit_etre_en_arabe(self):
        erreurs, _ = valider("ar-SA", FICHE_OK, False)
        self.assertTrue(any("arabe" in e for e in erreurs))
        arabe = {**FICHE_OK, "description": "سجّل مصروفاتك في ثلاث لمسات، دون إنترنت."}
        erreurs, _ = valider("ar-SA", arabe, False)
        self.assertEqual(erreurs, [])

    def test_notes_attendues_mais_absentes(self):
        erreurs, _ = valider("it", FICHE_OK, notes_attendues=True)
        self.assertTrue(any("release_notes" in e for e in erreurs))

    def test_fiches_sources_valides(self):
        for locale in ("fr-FR", "en-US"):
            fiche = lire_fiche(locale)
            self.assertEqual(set(fiche), set(CHAMPS_FICHE))
            erreurs, _ = valider(locale, fiche, notes_attendues=False)
            self.assertEqual(erreurs, [], locale)


if __name__ == "__main__":
    unittest.main()
