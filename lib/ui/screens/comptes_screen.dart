import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/couleur_utils.dart';
import '../../core/utils/formatters.dart';
import '../../logic/providers/repositories_providers.dart';
import 'compte_edition_screen.dart';

/// Gestion des comptes, avec solde initial (section 4, écran D). Pas de
/// réordonnancement ici : le cahier des charges ne le demande que pour
/// les catégories.
class ComptesScreen extends ConsumerWidget {
  const ComptesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(compteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comptes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CompteEditionScreen())),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: repo.listenable(),
        builder: (context, _, _) {
          final comptes = repo.tous();
          return ListView(
            children: comptes.map((compte) {
              final couleur = depuisHex(compte.couleurHex);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: couleur.withValues(
                    alpha: compte.actif ? 0.18 : 0.08,
                  ),
                  child: PhosphorIcon(
                    icones[compte.iconeCode] ?? PhosphorIconsFill.question,
                    color: couleur,
                    size: 20,
                  ),
                ),
                title: Text(
                  compte.libelle,
                  style: TextStyle(
                    color: compte.actif
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                subtitle: Text(
                  'Solde initial : ${formaterMontant(compte.soldeInitial)}',
                ),
                trailing: compte.actif
                    ? const Icon(Icons.chevron_right)
                    : const Icon(Icons.visibility_off_outlined, size: 18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompteEditionScreen(compte: compte),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
