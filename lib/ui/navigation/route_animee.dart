import 'package:flutter/material.dart';

/// Transition entre écrans plafonnée à 250 ms (section 3.2) : un fondu
/// combiné à un léger glissement vertical, jamais un fondu long. À
/// utiliser à la place de `MaterialPageRoute` partout dans l'app, pour
/// que toutes les navigations aient le même rythme.
Route<T> routeAnimee<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fondu = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fondu,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(fondu),
          child: child,
        ),
      );
    },
  );
}
