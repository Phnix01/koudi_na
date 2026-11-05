import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/core/constants/devises.dart';
import 'package:koudi_na/core/utils/formatters.dart';

/// Les montants suivent `Intl.defaultLocale`, aligné sur la langue
/// choisie dans Réglages : séparateur de milliers français ou anglais.
/// Le symbole, lui, suit la devise choisie (`appliquerDeviseGlobale`),
/// XOF/FCFA par défaut tant que l'utilisateur n'a rien choisi.
void main() {
  final espaceInsecable = String.fromCharCode(0x00A0);

  setUp(() => appliquerDeviseGlobale(deviseParDefaut));

  test('montant en français : espace insécable et suffixe FCFA', () {
    Intl.defaultLocale = 'fr';
    expect(
      formaterMontant(1994000),
      '1${espaceInsecable}994${espaceInsecable}000${espaceInsecable}FCFA',
    );
    expect(formaterDecimal(2.5), '2,5');
  });

  test('montant en anglais : virgule et suffixe FCFA', () {
    Intl.defaultLocale = 'en';
    expect(formaterMontant(1994000), '1,994,000${espaceInsecable}FCFA');
    expect(formaterDecimal(2.5), '2.5');
  });

  test('zéro et petits montants', () {
    Intl.defaultLocale = 'fr';
    expect(formaterMontant(0), '0${espaceInsecable}FCFA');
    expect(formaterMontant(500), '500${espaceInsecable}FCFA');
  });

  test('devise suffixe (EUR) : symbole après le montant', () {
    Intl.defaultLocale = 'fr';
    appliquerDeviseGlobale(Devise.eur);
    expect(formaterMontant(2500), '2${espaceInsecable}500$espaceInsecable€');
  });

  test('devise préfixe (USD) : symbole collé avant le montant', () {
    Intl.defaultLocale = 'en';
    appliquerDeviseGlobale(Devise.usd);
    expect(formaterMontant(2500), '\$2,500');
  });
}
