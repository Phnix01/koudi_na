import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/icones.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../logic/providers/repositories_providers.dart';

/// Puces horizontales pour choisir le compte (section 4). Le mobile
/// money apparaît au même rang que les espèces et la banque — aucun
/// compte n'est mis en avant par défaut au-delà de son ordre de création.
class SelecteurCompte extends ConsumerWidget {
  const SelecteurCompte({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compteSelectionneId = ref.watch(captureFormProvider.select((form) => form.compteId));
    final comptes = ref.watch(compteRepositoryProvider).tous().where((c) => c.actif).toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: comptes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final compte = comptes[index];
          return ChoiceChip(
            avatar: PhosphorIcon(icones[compte.iconeCode] ?? PhosphorIconsFill.question, size: 16),
            label: Text(compte.libelle),
            selected: compte.id == compteSelectionneId,
            onSelected: (_) => ref.read(captureFormProvider.notifier).choisirCompte(compte.id),
          );
        },
      ),
    );
  }
}
