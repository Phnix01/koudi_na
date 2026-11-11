import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrémenté pour demander à l'écran Capture de rejouer la visite
/// guidée (depuis Réglages) : un compteur plutôt qu'un booléen, pour que
/// chaque demande soit un changement de valeur que `ref.listen` voit.
final demandeDidacticielProvider = StateProvider<int>((ref) => 0);
