/// Noms des Box Hive (les "tables" du stockage local). Centralisés ici
/// pour ne jamais risquer une faute de frappe entre deux écrans.
abstract final class HiveBoxes {
  static const transactions = 'transactions';
  static const categories = 'categories';
  static const comptes = 'comptes';
  static const recurrences = 'recurrences';

  /// Préférences simples (langue...) : une Box de chaînes, clé → valeur,
  /// sans modèle Hive dédié.
  static const reglages = 'reglages';

  /// Série de jours actifs, badges débloqués et alertes de dépassement
  /// déjà montrées : même principe que [reglages], une Box de chaînes
  /// sans modèle Hive dédié.
  static const gamification = 'gamification';
}
