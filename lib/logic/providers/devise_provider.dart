import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/devises.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/reglages_repository.dart';
import 'langue_provider.dart' show reglagesRepositoryProvider;

/// Devise choisie par l'utilisateur, réglage global (section 4, écran
/// D) au même titre que la langue — pas de devise par compte, pas de
/// conversion : les montants restent des entiers, seul le symbole
/// affiché change (voir `formaterMontant`).
class DeviseNotifier extends StateNotifier<Devise> {
  DeviseNotifier(this._reglages)
    : super(deviseDepuisCode(_reglages.devise));

  final ReglagesRepository _reglages;

  Future<void> choisir(Devise devise) async {
    await _reglages.enregistrerDevise(devisesDisponibles[devise]!.code);
    appliquerDeviseGlobale(devise);
    state = devise;
  }
}

final deviseProvider = StateNotifierProvider<DeviseNotifier, Devise>(
  (ref) => DeviseNotifier(ref.watch(reglagesRepositoryProvider)),
);
