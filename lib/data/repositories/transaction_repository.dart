import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../core/constants/hive_boxes.dart';
import '../models/transaction.dart';

/// Accès à la Box des transactions. Aucune règle métier ici (pas de
/// calcul de solde, pas de tri par fréquence) : juste lire et écrire.
class TransactionRepository {
  Box<Transaction> get _box => Hive.box<Transaction>(HiveBoxes.transactions);

  List<Transaction> tous() => _box.values.toList();

  /// `put` avec la même clé écrase l'existant : cette même méthode sert
  /// donc aussi bien à la création (nouvel id) qu'à la modification
  /// (id d'une transaction déjà enregistrée) ou à l'annulation d'une
  /// suppression (on remet l'objet supprimé tel quel).
  Future<void> enregistrer(Transaction transaction) => _box.put(transaction.id, transaction);

  Future<void> supprimer(String id) => _box.delete(id);

  /// Expose le flux de changements de la Box, pour que l'UI se
  /// reconstruise automatiquement après chaque écriture (solde du mois,
  /// fréquence des catégories, liste du mois).
  ValueListenable<Box<Transaction>> listenable() => _box.listenable();
}
