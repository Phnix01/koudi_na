import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/constants/badges.dart';

void main() {
  test('chaque badge a sa médaille dans assets/badges', () {
    for (final badge in badgesDisponibles) {
      expect(File(badge.image).existsSync(), isTrue, reason: badge.id);
    }
  });

  test('aucune médaille orpheline dans assets/badges', () {
    final attendues = badgesDisponibles.map((b) => b.image).toSet();
    final presentes = Directory('assets/badges')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .toSet();
    expect(presentes, attendues);
  });

  test('identifiants uniques', () {
    final ids = badgesDisponibles.map((b) => b.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
