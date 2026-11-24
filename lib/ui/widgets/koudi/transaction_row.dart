import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/koudi_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/visuels.dart';
import '../../../data/models/categorie.dart';
import '../../../data/models/compte.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/type_mouvement.dart';

/// Une ligne d'opération (brief §3.5) : pastille teintée de la catégorie,
/// titre (la note, sinon la catégorie), sous-titre, montant signé.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.categorie,
    required this.compte,
    this.sousTitre,
    this.hauteur = 54,
    this.taillePastille = 38,
    this.separateur = false,
    this.onTap,
  });

  final Transaction transaction;
  final Categorie? categorie;
  final Compte? compte;

  /// Remplace le sous-titre par défaut (ex. « Aujourd'hui · Espèces »).
  final String? sousTitre;
  final double hauteur;
  final double taillePastille;
  final bool separateur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final texte = Theme.of(context).textTheme;
    final entree = transaction.type == TypeMouvement.entree;
    final note = transaction.note?.trim() ?? '';
    final nomCategorie = categorie?.nom ?? '';
    final nomCompte = compte?.nom ?? '';
    final titre = note.isNotEmpty ? note : nomCategorie;
    final sousTitreParDefaut = note.isNotEmpty
        ? [nomCategorie, nomCompte].where((s) => s.isNotEmpty).join(' · ')
        : nomCompte;
    final montant = entree ? transaction.montant : -transaction.montant;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: hauteur,
        decoration: separateur
            ? BoxDecoration(border: Border(bottom: BorderSide(color: t.line)))
            : null,
        child: Row(
          children: [
            Container(
              width: taillePastille,
              height: taillePastille,
              decoration: BoxDecoration(
                color: entree ? t.positiveTint : (categorie?.teinte ?? t.surfaceMuted),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                categorie?.icone ?? PhosphorIconsRegular.dotsThree,
                size: taillePastille * 0.47,
                color: entree ? t.positive : (categorie?.couleur ?? t.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texte.bodyLarge?.copyWith(fontSize: hauteur >= 54 ? 15 : 14),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sousTitre ?? sousTitreParDefaut,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texte.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formaterSigne(montant),
              style: texte.titleMedium?.copyWith(
                fontSize: hauteur >= 54 ? 15 : 14,
                color: entree ? t.positive : t.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
