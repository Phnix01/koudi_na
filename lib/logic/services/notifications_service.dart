import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/pilier.dart';

/// Enveloppe fine autour de `flutter_local_notifications` : planifie et
/// affiche les notifications locales de l'app (rappel quotidien, récap
/// hebdomadaire, alerte de dépassement). Ne persiste rien elle-même
/// (les préférences restent dans `ReglagesRepository`) et ne connaît
/// pas `BuildContext`/`AppLocalizations` : les appelants lui passent
/// des chaînes déjà résolues.
class NotificationsService {
  NotificationsService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _idRappelQuotidien = 1;
  static const _idRecapHebdomadaire = 2;
  static const _canal = AndroidNotificationDetails(
    'koudi_na_rappels',
    'Koudi Na',
  );

  Future<void> init() async {
    tzdata.initializeTimeZones();
    final fuseau = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(_resoudreFuseau(fuseau.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  /// Demande la permission de notifier, en contexte (jamais à
  /// l'onboarding). `true` si accordée.
  Future<bool> demanderPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  Future<void> planifierRappelQuotidien(
    TimeOfDay heure, {
    required String titre,
    required String corps,
  }) => _plugin.zonedSchedule(
    id: _idRappelQuotidien,
    title: titre,
    body: corps,
    scheduledDate: _prochaineOccurrence(heure.hour, heure.minute),
    notificationDetails: const NotificationDetails(
      android: _canal,
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  Future<void> annulerRappelQuotidien() =>
      _plugin.cancel(id: _idRappelQuotidien);

  /// Créneau fixe, dimanche 19h — pas de sélecteur dédié, pour garder
  /// ce réglage simple (un seul rappel a droit à une heure choisie).
  Future<void> planifierRecapHebdomadaire({
    required String titre,
    required String corps,
  }) => _plugin.zonedSchedule(
    id: _idRecapHebdomadaire,
    title: titre,
    body: corps,
    scheduledDate: _prochainDimanche(19, 0),
    notificationDetails: const NotificationDetails(
      android: _canal,
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
  );

  Future<void> annulerRecapHebdomadaire() =>
      _plugin.cancel(id: _idRecapHebdomadaire);

  /// Affichée immédiatement (pas planifiée) : calculée en direct au
  /// moment où l'app repasse au premier plan, voir `capture_screen.dart`.
  Future<void> afficherAlerteDepassement(
    Pilier pilier, {
    required String titre,
    required String corps,
  }) => _plugin.show(
    id: 100 + pilier.index,
    title: titre,
    body: corps,
    notificationDetails: const NotificationDetails(
      android: _canal,
      iOS: DarwinNotificationDetails(),
    ),
  );

  tz.TZDateTime _prochaineOccurrence(int heure, int minute) {
    final maintenant = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      maintenant.year,
      maintenant.month,
      maintenant.day,
      heure,
      minute,
    );
    if (date.isBefore(maintenant)) date = date.add(const Duration(days: 1));
    return date;
  }

  tz.TZDateTime _prochainDimanche(int heure, int minute) {
    var date = _prochaineOccurrence(heure, minute);
    while (date.weekday != DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  /// `flutter_timezone` rapporte le nom IANA tel que le système
  /// d'exploitation le connaît (ex. "Africa/Niamey"), mais la base
  /// embarquée par `timezone` ne contient que les fuseaux canoniques,
  /// pas leurs alias politiques (Niger utilise les mêmes horaires que
  /// le Nigeria, donc "Africa/Niamey" n'existe que comme alias vers
  /// "Africa/Lagos" dans la base IANA — absent ici). Si le nom n'est
  /// pas reconnu, on reconstruit un fuseau à décalage fixe à partir du
  /// décalage UTC réel de l'appareil : l'heure affichée reste correcte
  /// même sans nom de zone reconnu.
  tz.Location _resoudreFuseau(String identifiant) {
    try {
      return tz.getLocation(identifiant);
    } on tz.LocationNotFoundException {
      final decalage = DateTime.now().timeZoneOffset;
      return tz.Location('decalage-local-$identifiant', const [], const [], [
        tz.TimeZone(decalage, isDst: false, abbreviation: 'LOCAL'),
      ]);
    }
  }
}
