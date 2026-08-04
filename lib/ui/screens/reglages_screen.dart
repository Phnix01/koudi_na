import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/export_csv.dart';
import '../../logic/services/import_csv.dart';
import '../../logic/services/partage_csv.dart';
import '../navigation/route_animee.dart';
import 'categories_screen.dart';
import 'comptes_screen.dart';
import 'recurrences_screen.dart';

/// Écran D (section 4) : gestion des catégories, des comptes et des
/// récurrences, export et import CSV. Le réglage des pourcentages
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
      );
      final suffixe = moisCourantSeulement
          ? DateFormat('yyyy-MM').format(DateTime.now())
          : 'tout';
      await partagerCsv(csv, 'kudi_$suffixe.csv');
    } finally {
      if (mounted) setState(() => _exportEnCours = false);
    }
  }

  Future<void> _importer() async {
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
        _afficherMessage('Impossible de lire ce fichier.');
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
          title: const Text('Importer ce fichier ?'),
          content: Text(
            '${resultatImport.transactions.length} transaction(s) seront ajoutées.'
            '${resultatImport.lignesIgnorees > 0 ? '\n${resultatImport.lignesIgnorees} ligne(s) ignorée(s) (catégorie, compte ou montant introuvable).' : ''}'
            '\n\nCet import ajoute ces transactions sans vérifier les doublons : réimporter le même fichier deux fois crée deux copies.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: resultatImport.transactions.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(true),
              child: const Text('Importer'),
            ),
          ],
        ),
      );
      if (confirme != true) return;

      final repo = ref.read(transactionRepositoryProvider);
      for (final transaction in resultatImport.transactions) {
        await repo.enregistrer(transaction);
      }
      _afficherMessage(
        '${resultatImport.transactions.length} transaction(s) importée(s).',
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Données', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Catégories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const CategoriesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Comptes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const ComptesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Récurrences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(
                    context,
                  ).push(routeAnimee(const RecurrencesScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Export', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Exporter le mois courant'),
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
                  title: const Text('Exporter toutes les transactions'),
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
          Text('Import', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Importer un CSV'),
              subtitle: const Text('Reprendre un export KUDI (mêmes colonnes)'),
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
