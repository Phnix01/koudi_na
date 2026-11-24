import 'package:flutter/painting.dart';

import '../../data/models/pilier.dart';

/// Une couleur fixe par pilier, réutilisée partout où les trois piliers
/// apparaissent côte à côte (ici, les barres empilées de la section 5.1).
/// Vit dans `core/constants` plutôt que dans `logic/services` : c'est
/// une préoccupation d'affichage, la logique métier des piliers
/// (calcul_piliers.dart) ne connaît aucune couleur.
const Map<Pilier, Color> couleursPiliers = {
  Pilier.epargne: Color(0xFF0E7A4F),
  Pilier.famille: Color(0xFF2F5BD3),
  Pilier.vie: Color(0xFF111113),
};
