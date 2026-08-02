import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/providers/capture_form_provider.dart';

/// Pavé numérique personnalisé (section 4) : le clavier système est
/// trop lent et trop petit pour la règle des 10 secondes. `000` en bas
/// à gauche complète les montants ronds (2 puis 000 → 2000) sans avoir
/// à taper chaque zéro.
class PaveNumerique extends ConsumerWidget {
  const PaveNumerique({super.key});

  static const _touches = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', '⌫'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(captureFormProvider.notifier);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.9,
      children: _touches.map((touche) {
        return _ToucheNumerique(
          libelle: touche,
          onTap: () {
            HapticFeedback.selectionClick();
            if (touche == '⌫') {
              notifier.effacerDernierChiffre();
            } else {
              notifier.ajouterChiffre(touche);
            }
          },
        );
      }).toList(),
    );
  }
}

class _ToucheNumerique extends StatelessWidget {
  const _ToucheNumerique({required this.libelle, required this.onTap});

  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final estEffacer = libelle == '⌫';
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: estEffacer
              ? const Icon(Icons.backspace_outlined, color: AppColors.textPrimary, size: 20)
              : Text(
                  libelle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
        ),
      ),
    );
  }
}
