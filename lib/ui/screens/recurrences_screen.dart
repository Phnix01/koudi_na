import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/repositories_providers.dart';
import '../navigation/route_animee.dart';
import 'recurrence_edition_screen.dart';

/// Gestion des transactions récurrentes (Phase 4, section 2.3) :
/// création, modification, désactivation. Chaque récurrence active
/// génère automatiquement sa transaction du mois au démarrage de l'app
/// (voir `data/recurrence/generation_recurrences.dart`).
class RecurrencesScreen extends ConsumerWidget {
  const RecurrencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(recurrenceRepositoryProvider);
    final categoriesParId = {
      for (final c in ref.watch(categorieRepositoryProvider).tous()) c.id: c,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Récurrences')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(routeAnimee(const RecurrenceEditionScreen())),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final recurrences = repo.tous()
            ..sort((a, b) => a.jourDuMois.compareTo(b.jourDuMois));

          if (recurrences.isEmpty) {
            return Center(
              child: Text(
                "Aucune récurrence pour l'instant",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            );
          }

          return ListView(
            children: recurrences.map((recurrence) {
              final categorie = categoriesParId[recurrence.categorieId];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: recurrence.active
                      ? AppColors.surfaceHigh
                      : AppColors.surfaceHigh.withValues(alpha: 0.5),
                  child: Text('${recurrence.jourDuMois}'),
                ),
                title: Text(
                  recurrence.libelle,
                  style: TextStyle(
                    color: recurrence.active
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                subtitle: Text(
                  '${categorie?.libelle ?? 'Catégorie supprimée'} · le ${recurrence.jourDuMois} de chaque mois',
                ),
                trailing: Text(
                  formaterMontant(recurrence.montant),
                  style: TextStyle(
                    color: recurrence.active
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  routeAnimee(RecurrenceEditionScreen(recurrence: recurrence)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
