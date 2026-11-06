import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/devises.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';

/// Ouvre la feuille de choix de devise (onboarding, dernier écran, et
/// Réglages) : point d'entrée unique pour ne pas dupliquer la
/// construction de la feuille entre les deux appelants.
Future<DeviseInfo?> ouvrirSelecteurDevise(
  BuildContext context, {
  required DeviseInfo actuelle,
}) {
  return showModalBottomSheet<DeviseInfo>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _DeviseSelecteurFeuille(actuelle: actuelle),
  );
}

/// Avec ~150 devises, une simple liste (comme `FeuilleSelection`,
/// utilisée pour catégories/comptes) serait injouable à parcourir :
/// cette feuille ajoute une recherche et sépare les devises déjà
/// proposées avant l'ouverture au monde entier (« Principales ») du
/// reste, trié alphabétiquement sur le nom localisé.
class _DeviseSelecteurFeuille extends StatefulWidget {
  const _DeviseSelecteurFeuille({required this.actuelle});

  final DeviseInfo actuelle;

  @override
  State<_DeviseSelecteurFeuille> createState() =>
      _DeviseSelecteurFeuilleState();
}

class _DeviseSelecteurFeuilleState extends State<_DeviseSelecteurFeuille> {
  final _recherche = TextEditingController();
  String _requete = '';

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final langue = Localizations.localeOf(context).languageCode;
    final requete = _requete.trim().toLowerCase();
    final enRecherche = requete.isNotEmpty;

    List<DeviseInfo> trier(Iterable<DeviseInfo> devises) =>
        devises.toList()
          ..sort((a, b) => nomDevise(a, langue).compareTo(nomDevise(b, langue)));

    final principales = enRecherche
        ? const <DeviseInfo>[]
        : devisesDisponibles.where((d) => d.principale).toList();
    final autres = enRecherche
        ? const <DeviseInfo>[]
        : trier(devisesDisponibles.where((d) => !d.principale));
    final resultats = enRecherche
        ? trier(
            devisesDisponibles.where(
              (d) =>
                  d.code.toLowerCase().contains(requete) ||
                  nomDevise(d, langue).toLowerCase().contains(requete),
            ),
          )
        : const <DeviseInfo>[];

    Widget ligne(DeviseInfo devise) => _LigneDevise(
      devise: devise,
      langue: langue,
      selectionnee: devise.code == widget.actuelle.code,
    );

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s8,
              ),
              child: Text(l10n.devise, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: TextField(
                controller: _recherche,
                onChanged: (valeur) => setState(() => _requete = valeur),
                decoration: InputDecoration(
                  hintText: l10n.deviseRechercher,
                  prefixIcon: const PhosphorIcon(
                    PhosphorIconsRegular.magnifyingGlass,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Expanded(
              child: enRecherche
                  ? (resultats.isEmpty
                        ? Center(
                            child: Text(
                              l10n.deviseAucunResultat,
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView(children: [for (final d in resultats) ligne(d)]))
                  : ListView(
                      children: [
                        _EnteteSection(texte: l10n.devisePrincipales),
                        for (final d in principales) ligne(d),
                        _EnteteSection(texte: l10n.deviseToutes),
                        for (final d in autres) ligne(d),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnteteSection extends StatelessWidget {
  const _EnteteSection({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Text(
        texte,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _LigneDevise extends StatelessWidget {
  const _LigneDevise({
    required this.devise,
    required this.langue,
    required this.selectionnee,
  });

  final DeviseInfo devise;
  final String langue;
  final bool selectionnee;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${devise.symbole} · ${nomDevise(devise, langue)}'),
      trailing: selectionnee
          ? const PhosphorIcon(PhosphorIconsBold.check, color: AppColors.primary)
          : null,
      onTap: () => Navigator.of(context).pop(devise),
    );
  }
}
