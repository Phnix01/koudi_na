import 'package:flutter/painting.dart';

import '../../data/models/pilier.dart';
import '../theme/app_colors.dart';

/// Une couleur fixe par pilier, réutilisée partout où les trois piliers
/// apparaissent côte à côte (ici, les barres empilées de la section 5.1).
/// Vit dans `core/constants` plutôt que dans `logic/services` : c'est
/// une préoccupation d'affichage, la logique métier des piliers
/// (calcul_piliers.dart) ne connaît aucune couleur.
const Map<Pilier, Color> couleursPiliers = {
  Pilier.epargne: AppColors.primary,
  Pilier.famille: Color(0xFFEC7FA9),
  Pilier.vie: Color(0xFF3498DB),
};
