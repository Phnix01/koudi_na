import 'package:intl/intl.dart';

// String.fromCharCode(0x...) plutot qu'un caractere brut dans le code :
// une espace fine et une espace insecable sont visuellement identiques
// a une espace normale dans un editeur de texte, impossible a
// distinguer a l'oeil nu. Ecrire le code hexadecimal leve toute ambiguite.
final String _espaceFineInsecable = String.fromCharCode(0x202F);
final String _espaceInsecable = String.fromCharCode(0x00A0);

/// Formate un montant en FCFA : entier, jamais de decimale, separateur
/// de milliers de la langue courante (section 1.3) -- espace en
/// francais ("1 994 000 F"), virgule en anglais ("1,994,000 F").
///
/// Aucune locale n'est passee a `NumberFormat` : il suit
/// `Intl.defaultLocale`, aligne sur la langue choisie dans Reglages
/// (voir `appliquerLocaleIntl` dans langue_provider.dart).
///
/// `intl` insere par defaut une espace fine insecable (0x202F) entre
/// les groupes de chiffres pour la locale `fr` -- un caractere que
/// certaines polices d'affichage (dont Sora, utilisee ici) ne dessinent
/// pas correctement : le nombre apparait colle et illisible
/// ("1994000" au lieu de "1 994 000"). On le remplace par l'espace
/// insecable "classique" (0x00A0), presque universellement supportee.
String formaterMontant(int montant) {
  final brut = NumberFormat.decimalPattern().format(montant);
  final formate = brut.replaceAll(_espaceFineInsecable, _espaceInsecable);
  return '$formate${_espaceInsecable}F';
}

/// Un nombre decimal a une decimale ("2,5" en francais, "2.5" en
/// anglais), pour l'autonomie financiere exprimee en mois.
String formaterDecimal(double valeur) => NumberFormat('0.0').format(valeur);
