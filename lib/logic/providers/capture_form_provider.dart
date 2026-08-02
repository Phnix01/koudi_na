import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction.dart';
import '../../data/models/type_mouvement.dart';
import 'repositories_providers.dart';

const _chiffresMax = 9;

/// Tout ce que l'écran Capture affiche à l'instant T. Regrouper ces
/// champs dans une seule classe (plutôt qu'un StateProvider par champ)
/// garantit qu'un enregistrement lit un instantané cohérent : montant,
/// catégorie et compte ne peuvent jamais se désynchroniser entre eux.
class CaptureFormState {
  const CaptureFormState({
    required this.type,
    required this.montantSaisi,
    required this.categorieId,
    required this.compteId,
    required this.note,
    required this.date,
  });

  final TypeMouvement type;
  final String montantSaisi;
  final String? categorieId;
  final String compteId;
  final String note;
  final DateTime date;

  int get montant => int.tryParse(montantSaisi) ?? 0;

  CaptureFormState copyWith({
    TypeMouvement? type,
    String? montantSaisi,
    String? categorieId,
    bool effacerCategorie = false,
    String? compteId,
    String? note,
    DateTime? date,
  }) {
    return CaptureFormState(
      type: type ?? this.type,
      montantSaisi: montantSaisi ?? this.montantSaisi,
      categorieId: effacerCategorie ? null : (categorieId ?? this.categorieId),
      compteId: compteId ?? this.compteId,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }
}

class CaptureFormNotifier extends StateNotifier<CaptureFormState> {
  CaptureFormNotifier({required String compteParDefautId})
    : super(
        CaptureFormState(
          type: TypeMouvement.depense,
          montantSaisi: '',
          categorieId: null,
          compteId: compteParDefautId,
          note: '',
          date: DateTime.now(),
        ),
      );

  /// Pré-remplit le formulaire à partir d'une transaction existante,
  /// pour l'écran d'édition. Le champ `note` de [Transaction] est
  /// `String?` (jamais obligatoire, section 2.3) mais celui du
  /// formulaire ne l'est pas : `null` devient simplement `''`.
  CaptureFormNotifier.depuisTransaction(Transaction transaction)
    : super(
        CaptureFormState(
          type: transaction.type,
          montantSaisi: '${transaction.montant}',
          categorieId: transaction.categorieId,
          compteId: transaction.compteId,
          note: transaction.note ?? '',
          date: transaction.date,
        ),
      );

  void choisirType(TypeMouvement type) {
    // Changer de sens vide la catégorie : dépenses et entrées sont deux
    // listes disjointes (section 2.3), l'ancienne sélection n'a plus de sens.
    state = state.copyWith(type: type, effacerCategorie: true);
  }

  void ajouterChiffre(String chiffre) {
    if (state.montantSaisi.isEmpty && int.parse(chiffre) == 0) {
      return; // pas de zéro non significatif
    }
    if (state.montantSaisi.length + chiffre.length > _chiffresMax) return;
    state = state.copyWith(montantSaisi: state.montantSaisi + chiffre);
  }

  void effacerDernierChiffre() {
    if (state.montantSaisi.isEmpty) return;
    state = state.copyWith(
      montantSaisi: state.montantSaisi.substring(
        0,
        state.montantSaisi.length - 1,
      ),
    );
  }

  void choisirCategorie(String categorieId) =>
      state = state.copyWith(categorieId: categorieId);

  void choisirCompte(String compteId) =>
      state = state.copyWith(compteId: compteId);

  void changerNote(String note) => state = state.copyWith(note: note);

  void changerDate(DateTime date) => state = state.copyWith(date: date);

  /// Après un enregistrement réussi : on garde le type et le compte
  /// (probablement réutilisés pour la saisie suivante), le reste repart à zéro.
  void reinitialiserApresEnregistrement() {
    state = state.copyWith(
      montantSaisi: '',
      note: '',
      date: DateTime.now(),
      effacerCategorie: true,
    );
  }
}

final captureFormProvider =
    StateNotifierProvider<CaptureFormNotifier, CaptureFormState>((ref) {
      final comptes = ref.watch(compteRepositoryProvider).tous();
      final compteParDefaut = comptes.isNotEmpty ? comptes.first.id : '';
      return CaptureFormNotifier(compteParDefautId: compteParDefaut);
    });
