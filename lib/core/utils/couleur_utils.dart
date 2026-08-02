import 'package:flutter/painting.dart';

/// Convertit une couleur stockée dans Hive (ex: `"#00C2A8"`) en [Color].
Color depuisHex(String hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')));
