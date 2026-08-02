import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/transaction.dart';

/// Accès à la Box des transactions. Aucune règle métier ici (pas de
/// calcul de solde, pas de tri par fréquence) : juste lire et écrire.
class TransactionRepository {
  Box<Transaction> get _box => Hive.box<Transaction>(HiveBoxes.transactions);

  List<Transaction> tous() => _box.values.toList();

  Future<void> ajouter(Transaction transaction) => _box.put(transaction.id, transaction);

  /// Expose le flux de changements de la Box, pour que l'UI se
  /// reconstruise automatiquement après chaque nouvelle transaction
  /// (solde du mois, fréquence des catégories).
  ValueListenable<Box<Transaction>> listenable() => _box.listenable();
}
