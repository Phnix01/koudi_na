import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../data/models/categorie.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/tri_categories.dart';

/// Grille de catégories, 4 par ligne (section 4). Enveloppée dans un
/// `ValueListenableBuilder` sur la Box des transactions : dès qu'une
/// transaction est enregistrée, le tri par fréquence se recalcule tout
/// seul, sans action de l'utilisateur.
class GrilleCategories extends ConsumerWidget {
  const GrilleCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(captureFormProvider.select((form) => form.type));
    final categorieSelectionneeId = ref.watch(captureFormProvider.select((form) => form.categorieId));
    final categorieRepo = ref.watch(categorieRepositoryProvider);
    final transactionRepo = ref.watch(transactionRepositoryProvider);

    final categories = categorieRepo.tous().where((c) => c.type == type && c.active).toList();

    return ValueListenableBuilder(
      valueListenable: transactionRepo.listenable(),
      builder: (context, _, _) {
        final categoriesTriees = trierCategoriesParFrequence(categories, transactionRepo.tous());
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 4,
            childAspectRatio: 0.8,
          ),
          itemCount: categoriesTriees.length,
          itemBuilder: (context, index) {
            final categorie = categoriesTriees[index];
            return _TuileCategorie(
              categorie: categorie,
              selectionnee: categorie.id == categorieSelectionneeId,
              onTap: () => ref.read(captureFormProvider.notifier).choisirCategorie(categorie.id),
            );
          },
        );
      },
    );
  }
}

class _TuileCategorie extends StatelessWidget {
  const _TuileCategorie({required this.categorie, required this.selectionnee, required this.onTap});

  final Categorie categorie;
  final bool selectionnee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = depuisHex(categorie.couleurHex);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selectionnee ? couleur : couleur.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: selectionnee ? Border.all(color: couleur, width: 2) : null,
            ),
            child: Center(
              child: PhosphorIcon(
                icones[categorie.iconeCode] ?? PhosphorIconsFill.question,
                color: selectionnee ? AppColors.bg : couleur,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categorie.libelle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: selectionnee ? AppColors.textPrimary : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
