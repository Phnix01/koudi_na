import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/devises.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/devise_provider.dart';
import '../../logic/providers/langue_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/export_csv.dart';
import '../../logic/services/import_csv.dart';
import '../../logic/services/partage_csv.dart';
import '../navigation/route_animee.dart';
import '../widgets/feuille_selection.dart';
import '../widgets/segmented_toggle.dart';
import 'categories_screen.dart';
import 'comptes_screen.dart';
import 'recurrences_screen.dart';

/// Valeur du segment « Système » dans le sélecteur de langue : le
/// provider stocke `null` pour ce cas, mais un `SegmentedToggle` est
/// plus simple à écrire avec une valeur non nulle.
const _langueSysteme = 'systeme';

/// Guideline 5.1.1 (i) d'Apple (et équivalent Google Play) : la politique
/// de confidentialité doit être accessible depuis l'app, pas seulement
/// depuis la fiche store.
const _urlPolitiqueConfidentialite = 'https://claude.ai/artifact/Y3yFsKPSZjrWnGNcpFRgis';
const _emailContact = 'contact@xnovasystems.com';

/// Écran D (section 4) : langue, gestion des catégories, des comptes et
/// des récurrences, export et import CSV. Le réglage des pourcentages
/// 40/25/35 et la bascule de thème ne font pas partie du périmètre
/// couvert jusqu'ici (sections 6, Phases 2-4).
class ReglagesScreen extends ConsumerStatefulWidget {
  const ReglagesScreen({super.key});

  @override
  ConsumerState<ReglagesScreen> createState() => _ReglagesScreenState();
}

class _ReglagesScreenState extends ConsumerState<ReglagesScreen> {
  bool _exportEnCours = false;
  bool _importEnCours = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  Future<void> _choisirDevise(Devise actuelle) async {
    final l10n = context.l10n;
    final choix = await showModalBottomSheet<Devise>(
      context: context,
      builder: (context) => FeuilleSelection<Devise>(
        titre: l10n.devise,
        options: Devise.values,
        libelleDe: (d) =>
            '${devisesDisponibles[d]!.symbole} · ${libelleDevise(l10n, d)}',
        estSelectionne: (d) => d == actuelle,
        avecOptionTous: false,
      ),
    );
    if (choix != null) {
      await ref.read(deviseProvider.notifier).choisir(choix);
    }
  }

  Future<void> _ouvrirLien(Uri lien) async {
    final messageEchec = context.l10n.aProposLienIndisponible;
    final ouvert = await launchUrl(lien, mode: LaunchMode.externalApplication);
    if (!ouvert) _afficherMessage(messageEchec);
  }

  Future<void> _exporter({required bool moisCourantSeulement}) async {
    final l10n = context.l10n;
    setState(() => _exportEnCours = true);
    try {
      final categoriesParId = {
        for (final c in ref.read(categorieRepositoryProvider).tous()) c.id: c,
      };
      final comptesParId = {
        for (final c in ref.read(compteRepositoryProvider).tous()) c.id: c,
      };

      var transactions = ref.read(transactionRepositoryProvider).tous();
      if (moisCourantSeulement) {
        final maintenant = DateTime.now();
        transactions = transactions
            .where(
              (t) =>
                  t.date.year == maintenant.year &&
                  t.date.month == maintenant.month,
            )
            .toList();
      }
      transactions.sort((a, b) => a.date.compareTo(b.date));

      final csv = genererCsvTransactions(
        transactions,
        categoriesParId,
        comptesParId,
        langue: ref.read(localeProvider).languageCode,
      );
      final suffixe = moisCourantSeulement
          ? DateFormat('yyyy-MM').format(DateTime.now())
          : 'tout';
      final nomFichier = 'koudi_na_$suffixe.csv';
      await partagerCsv(
        csv,
        nomFichier,
        texte: l10n.exportPartageTexte(nomFichier),
      );
    } finally {
      if (mounted) setState(() => _exportEnCours = false);
    }
  }

  Future<void> _importer() async {
    final l10n = context.l10n;
    final resultat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (resultat == null || resultat.files.isEmpty) return;

    setState(() => _importEnCours = true);
    try {
      final fichier = resultat.files.first;
      // Sur le web, le contenu arrive déjà en mémoire (`bytes`) ; sur
      // mobile/desktop, seul un chemin de fichier est fourni, à lire
      // via dart:io — les deux cas doivent être gérés.
      final contenu = fichier.bytes != null
          ? utf8.decode(fichier.bytes!, allowMalformed: true)
          : (fichier.path != null
                ? await File(fichier.path!).readAsString()
                : null);

      if (contenu == null) {
        _afficherMessage(l10n.fichierIllisible);
        return;
      }

      final categories = ref.read(categorieRepositoryProvider).tous();
      final comptes = ref.read(compteRepositoryProvider).tous();
      final resultatImport = parserCsvTransactions(
        contenu,
        categories,
        comptes,
      );

      if (!mounted) return;
      final confirme = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.importerTitre),
          content: Text(
            '${l10n.importResume(resultatImport.transactions.length)}'
            '${resultatImport.lignesIgnorees > 0 ? '\n${l10n.importIgnorees(resultatImport.lignesIgnorees)}' : ''}'
            '\n\n${l10n.importDoublonsAvertissement}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.annuler),
            ),
            TextButton(
              onPressed: resultatImport.transactions.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(true),
              child: Text(l10n.importer),
            ),
          ],
        ),
      );
      if (confirme != true) return;

      final repo = ref.read(transactionRepositoryProvider);
      for (final transaction in resultatImport.transactions) {
        await repo.enregistrer(transaction);
      }
      _afficherMessage(l10n.importTermine(resultatImport.transactions.length));
    } finally {
      if (mounted) setState(() => _importEnCours = false);
    }
  }

  void _afficherMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final langueChoisie = ref.watch(langueProvider) ?? _langueSysteme;
    final deviseChoisie = ref.watch(deviseProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reglages)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.langue, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              // Les noms de langues restent dans leur propre langue
              // (« Français », « English ») : c'est ainsi qu'un
              // utilisateur perdu dans une langue qu'il ne lit pas
              // retrouve la sienne.
              child: SegmentedToggle<String>(
                options: [
                  SegmentedToggleOption(
                    valeur: _langueSysteme,
                    label: l10n.langueSysteme,
                  ),
                  const SegmentedToggleOption(
                    valeur: 'fr',
                    label: 'Français',
                  ),
                  const SegmentedToggleOption(valeur: 'en', label: 'English'),
                ],
                selectionne: langueChoisie,
                onChanged: (code) => ref
                    .read(langueProvider.notifier)
                    .choisir(code == _langueSysteme ? null : code),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.devise, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const PhosphorIcon(
                PhosphorIconsRegular.currencyCircleDollar,
              ),
              title: Text(
                '${devisesDisponibles[deviseChoisie]!.symbole} · '
                '${libelleDevise(l10n, deviseChoisie)}',
              ),
              trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight),
              onTap: () => _choisirDevise(deviseChoisie),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.donnees, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const PhosphorIcon(PhosphorIconsRegular.squaresFour),
                  title: Text(l10n.categories),
                  trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const CategoriesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const PhosphorIcon(PhosphorIconsRegular.wallet),
                  title: Text(l10n.comptes),
                  trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const ComptesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const PhosphorIcon(PhosphorIconsRegular.repeat),
                  title: Text(l10n.recurrences),
                  trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const RecurrencesScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.export, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const PhosphorIcon(
                    PhosphorIconsRegular.calendarBlank,
                  ),
                  title: Text(l10n.exporterMoisCourant),
                  trailing: _exportEnCours
                      ? const _IndicateurChargement()
                      : const PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: _exportEnCours
                      ? null
                      : () => _exporter(moisCourantSeulement: true),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const PhosphorIcon(
                    PhosphorIconsRegular.folderSimple,
                  ),
                  title: Text(l10n.exporterTout),
                  trailing: _exportEnCours
                      ? const _IndicateurChargement()
                      : const PhosphorIcon(PhosphorIconsRegular.caretRight),
                  onTap: _exportEnCours
                      ? null
                      : () => _exporter(moisCourantSeulement: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.import, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const PhosphorIcon(PhosphorIconsRegular.uploadSimple),
              title: Text(l10n.importerCsv),
              subtitle: Text(l10n.importerCsvSousTitre),
              trailing: _importEnCours
                  ? const _IndicateurChargement()
                  : const PhosphorIcon(PhosphorIconsRegular.caretRight),
              onTap: _importEnCours ? null : _importer,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aPropos, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.aProposEditeur),
                      const SizedBox(height: 4),
                      Text(
                        l10n.aProposHorsLigne,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const PhosphorIcon(PhosphorIconsRegular.shieldCheck),
                  title: Text(l10n.aProposPolitiqueConfidentialite),
                  trailing: const PhosphorIcon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 18,
                  ),
                  onTap: () =>
                      _ouvrirLien(Uri.parse(_urlPolitiqueConfidentialite)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const PhosphorIcon(
                    PhosphorIconsRegular.envelopeSimple,
                  ),
                  title: Text(l10n.aProposNousContacter),
                  subtitle: const Text(_emailContact),
                  trailing: const PhosphorIcon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 18,
                  ),
                  onTap: () => _ouvrirLien(
                    Uri(scheme: 'mailto', path: _emailContact),
                  ),
                ),
                if (_version.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(title: Text(l10n.aProposVersion(_version))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicateurChargement extends StatelessWidget {
  const _IndicateurChargement();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
