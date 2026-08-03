import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/export_csv.dart';
import '../../logic/services/partage_csv.dart';
import '../navigation/route_animee.dart';
import 'categories_screen.dart';
import 'comptes_screen.dart';

/// Écran D (section 4) : gestion des catégories et des comptes, export
/// CSV. Le réglage des pourcentages 40/25/35 et la bascule de thème ne
/// font pas partie du périmètre Phase 2 (section 6) — ils viendront
/// avec le reste du polissage en Phase 3/4.
class ReglagesScreen extends ConsumerStatefulWidget {
  const ReglagesScreen({super.key});

  @override
  ConsumerState<ReglagesScreen> createState() => _ReglagesScreenState();
}

class _ReglagesScreenState extends ConsumerState<ReglagesScreen> {
  bool _exportEnCours = false;

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
                  onTap: () => Navigator.of(context).push(routeAnimee(const CategoriesScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Comptes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(routeAnimee(const ComptesScreen())),
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
