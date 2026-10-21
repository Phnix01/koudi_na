import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reglages_repository.dart';
import '../../l10n/locale_utils.dart';

/// Langue choisie par l'utilisateur, `null` pour « Système ». L'état
/// est le code brut (pas la locale résolue) pour que l'écran Réglages
/// puisse distinguer « Système » d'un choix explicite.
class LangueNotifier extends StateNotifier<String?> {
  LangueNotifier(this._reglages) : super(_reglages.langue);

  final ReglagesRepository _reglages;

  Future<void> choisir(String? code) async {
    await _reglages.enregistrerLangue(code);
    appliquerLocaleIntl(resoudreLocale(code));
    state = code;
  }
}

final reglagesRepositoryProvider = Provider((ref) => ReglagesRepository());

final langueProvider = StateNotifierProvider<LangueNotifier, String?>(
  (ref) => LangueNotifier(ref.watch(reglagesRepositoryProvider)),
);

/// La locale effective, prête à donner à `MaterialApp.locale`.
final localeProvider = Provider<Locale>(
  (ref) => resoudreLocale(ref.watch(langueProvider)),
);
