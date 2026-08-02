import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/categorie_repository.dart';
import '../../data/repositories/compte_repository.dart';
import '../../data/repositories/transaction_repository.dart';

/// Un seul point de création pour chaque repository : les écrans ne
/// font jamais `CategorieRepository()` eux-mêmes, ils lisent
/// `ref.watch(categorieRepositoryProvider)`. Ça permettra plus tard de
/// substituer un faux repository dans les tests sans toucher à l'UI.
final categorieRepositoryProvider = Provider((ref) => CategorieRepository());
final compteRepositoryProvider = Provider((ref) => CompteRepository());
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);
