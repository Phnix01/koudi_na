import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../logic/providers/langue_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/export_csv.dart';
import '../../logic/services/import_csv.dart';
import '../../logic/services/partage_csv.dart';
import '../navigation/route_animee.dart';
import 'categories_screen.dart';
import 'comptes_screen.dart';
import 'recurrences_screen.dart';

/// Valeur du segment « Système » dans le sélecteur de langue : le
/// provider stocke `null` pour ce cas, mais un `SegmentedButton` est
/// plus simple à écrire avec une valeur non nulle.
const _langueSysteme = 'systeme';

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
              child: SegmentedButton<String>(
                // Les noms de langues restent dans leur propre langue
                // (« Français », « English ») : c'est ainsi qu'un
                // utilisateur perdu dans une langue qu'il ne lit pas
                // retrouve la sienne.
                segments: [
                  ButtonSegment(
                    value: _langueSysteme,
                    label: Text(l10n.langueSysteme),
                  ),
                  const ButtonSegment(value: 'fr', label: Text('Français')),
                  const ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {langueChoisie},
                onSelectionChanged: (selection) {
                  final code = selection.first;
                  ref
                      .read(langueProvider.notifier)
                      .choisir(code == _langueSysteme ? null : code);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.donnees, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(l10n.categories),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const CategoriesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(l10n.comptes),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const ComptesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(l10n.recurrences),
                  trailing: const Icon(Icons.chevron_right),
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
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(l10n.exporterMoisCourant),
                  trailing: _exportEnCours
                      ? const _IndicateurChargement()
                      : const Icon(Icons.chevron_right),
                  onTap: _exportEnCours
                      ? null
                      : () => _exporter(moisCourantSeulement: true),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(l10n.exporterTout),
                  trailing: _exportEnCours
                      ? const _IndicateurChargement()
                      : const Icon(Icons.chevron_right),
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
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(l10n.importerCsv),
              subtitle: Text(l10n.importerCsvSousTitre),
              trailing: _importEnCours
                  ? const _IndicateurChargement()
                  : const Icon(Icons.chevron_right),
              onTap: _importEnCours ? null : _importer,
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
