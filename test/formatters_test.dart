import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:koudi_na/core/utils/formatters.dart';

/// Les montants suivent `Intl.defaultLocale`, aligné sur la langue
/// choisie dans Réglages : séparateur de milliers français ou anglais.
void main() {
  final espaceInsecable = String.fromCharCode(0x00A0);

  test('montant en français : espace insécable et suffixe F', () {
    Intl.defaultLocale = 'fr';
    expect(
      formaterMontant(1994000),
      '1${espaceInsecable}994${espaceInsecable}000${espaceInsecable}F',
    );
    expect(formaterDecimal(2.5), '2,5');
  });

  test('montant en anglais : virgule et suffixe F', () {
    Intl.defaultLocale = 'en';
    expect(formaterMontant(1994000), '1,994,000${espaceInsecable}F');
    expect(formaterDecimal(2.5), '2.5');
  });

  test('zéro et petits montants', () {
    Intl.defaultLocale = 'fr';
    expect(formaterMontant(0), '0${espaceInsecable}F');
    expect(formaterMontant(500), '500${espaceInsecable}F');
  });
}
