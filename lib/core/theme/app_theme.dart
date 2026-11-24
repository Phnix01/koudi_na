import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_spacing.dart';
import 'koudi_tokens.dart';

/// Thème clair de la refonte D (brief §2) : fond cassé, encre, un seul
/// accent vert, Geist en chiffres tabulaires partout (comme les maquettes,
/// qui posent `tnum` sur tout l'écran : les montants ne « dansent » pas
/// quand ils changent).
abstract final class AppTheme {
  static const _tabulaires = [FontFeature.tabularFigures()];

  static ThemeData get clair => _construire(KoudiTokens.clair, Brightness.light);

  static ThemeData _construire(KoudiTokens t, Brightness luminosite) {
    final schema = ColorScheme(
      brightness: luminosite,
      primary: t.ink,
      onPrimary: t.onInk,
      secondary: t.positive,
      onSecondary: t.onInk,
      error: t.streak,
      onError: t.onInk,
      surface: t.surface,
      onSurface: t.ink,
      onSurfaceVariant: t.muted,
      surfaceContainerHighest: t.surfaceMuted,
      outline: t.lineStrong,
      outlineVariant: t.line,
    );

    TextStyle s(double taille, FontWeight graisse, {double? espacement, Color? couleur, double? hauteur}) =>
        GoogleFonts.geist(
          fontSize: taille,
          fontWeight: graisse,
          letterSpacing: espacement,
          color: couleur ?? t.ink,
          height: hauteur,
          fontFeatures: _tabulaires,
        );

    final texte = TextTheme(
      displayLarge: s(60, FontWeight.w600, espacement: -2.6, hauteur: 1),
      displayMedium: s(54, FontWeight.w600, espacement: -2.6, hauteur: 1.04),
      displaySmall: s(34, FontWeight.w600, espacement: -1.2),
      headlineMedium: s(26, FontWeight.w600, espacement: -0.6),
      headlineSmall: s(21, FontWeight.w600, espacement: -0.6),
      titleLarge: s(17, FontWeight.w600),
      titleMedium: s(15, FontWeight.w600),
      titleSmall: s(14, FontWeight.w600),
      bodyLarge: s(15, FontWeight.w500),
      bodyMedium: s(14, FontWeight.w500),
      bodySmall: s(12, FontWeight.w400, couleur: t.muted),
      labelLarge: s(16, FontWeight.w600),
      labelMedium: s(13, FontWeight.w500),
      labelSmall: s(11, FontWeight.w500),
    );

    final rayonCarte = BorderRadius.circular(18);

    return ThemeData(
      useMaterial3: true,
      brightness: luminosite,
      colorScheme: schema,
      scaffoldBackgroundColor: t.bg,
      canvasColor: t.bg,
      textTheme: texte,
      fontFamily: GoogleFonts.geist().fontFamily,
      extensions: [t],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        foregroundColor: t.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: texte.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: rayonCarte,
          side: BorderSide(color: t.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.ink,
          foregroundColor: t.onInk,
          disabledBackgroundColor: t.ctaDisabled,
          disabledForegroundColor: t.muted,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: texte.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.ink,
          foregroundColor: t.onInk,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: texte.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.ink2,
          textStyle: texte.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.lineStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: texte.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: t.ink),
      ),
      iconTheme: IconThemeData(color: t.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: texte.bodyMedium?.copyWith(color: t.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: t.ink, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        selectedColor: t.ink,
        labelStyle: texte.labelMedium,
        secondaryLabelStyle: texte.labelMedium?.copyWith(color: t.onInk),
        side: BorderSide(color: t.line),
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: t.ink2,
        titleTextStyle: texte.bodyLarge,
        subtitleTextStyle: texte.bodySmall,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (etats) => etats.contains(WidgetState.selected) ? t.onInk : t.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (etats) => etats.contains(WidgetState.selected) ? t.positive : t.track,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.ink,
        linearTrackColor: t.track,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        contentTextStyle: texte.bodyMedium?.copyWith(color: t.onInk),
        actionTextColor: t.positiveTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.surface,
        modalBarrierColor: t.scrim,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: t.scrim,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: texte.titleLarge,
        contentTextStyle: texte.bodyMedium?.copyWith(color: t.ink2),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: texte.labelMedium?.copyWith(color: t.onInk),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: t.bg,
        headerForegroundColor: t.ink,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: t.surface,
        dialBackgroundColor: t.surfaceMuted,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
