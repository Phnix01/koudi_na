import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notifications_service.dart';

/// `NotificationsService.init()` est asynchrone et doit tourner avant
/// `runApp()` (fuseau horaire, plugin natif) : le provider est donc
/// surchargé par valeur dans `main.dart`, jamais construit ici.
final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => throw UnimplementedError(
    'notificationsServiceProvider doit être surchargé dans main.dart, '
    'après NotificationsService.init().',
  ),
);
