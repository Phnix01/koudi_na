import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/constants/devises.dart';

/// Garde-fou structurel sur la liste mondiale des devises (~150
/// entrées, section Export/onboarding) : un test ne peut pas vérifier
/// l'exactitude du monde réel, mais il attrape les fautes de frappe et
/// les doublons qu'une liste de cette taille, tapée à la main, risque
/// fort de contenir.
void main() {
  const codesPrincipauxAttendus = {
    'XOF',
    'XAF',
    'EUR',
    'CHF',
    'CAD',
    'MAD',
    'DZD',
    'TND',
    'GBP',
    'USD',
    'NGN',
    'GHS',
  };

  test('aucun code ISO dupliqué', () {
    final codes = devisesDisponibles.map((d) => d.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('chaque code fait exactement 3 lettres majuscules', () {
    final motif = RegExp(r'^[A-Z]{3}$');
    for (final devise in devisesDisponibles) {
      expect(motif.hasMatch(devise.code), isTrue, reason: devise.code);
    }
  });

  test('chaque devise a un nom fr et en non vide', () {
    for (final devise in devisesDisponibles) {
      expect(devise.nomFr, isNotEmpty, reason: devise.code);
      expect(devise.nomEn, isNotEmpty, reason: devise.code);
    }
  });

  test('exactement les 12 devises historiques sont "principales"', () {
    final codesPrincipaux = devisesDisponibles
        .where((d) => d.principale)
        .map((d) => d.code)
        .toSet();
    expect(codesPrincipaux, codesPrincipauxAttendus);
  });

  test('deviseDepuisCode retrouve une devise par son code', () {
    expect(deviseDepuisCode('EUR').code, 'EUR');
    expect(deviseDepuisCode('inconnu').code, deviseParDefautCode);
    expect(deviseDepuisCode(null).code, deviseParDefautCode);
  });

  test('nomDevise bascule entre fr et en', () {
    final eur = deviseDepuisCode('EUR');
    expect(nomDevise(eur, 'fr'), 'Euro');
    expect(nomDevise(eur, 'en'), 'Euro');
    final usd = deviseDepuisCode('USD');
    expect(nomDevise(usd, 'fr'), 'Dollar américain');
    expect(nomDevise(usd, 'en'), 'US Dollar');
  });
}
