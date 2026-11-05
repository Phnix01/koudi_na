import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koudi_na/core/constants/devises.dart';
import 'package:koudi_na/core/theme/app_colors.dart';
import 'package:koudi_na/core/theme/app_spacing.dart';
import 'package:koudi_na/core/theme/app_theme.dart';
import 'package:koudi_na/l10n/app_localizations.dart';
import 'package:koudi_na/ui/widgets/feuille_selection.dart';

void main() {
  testWidgets('Rangée cliquable + feuille de sélection des devises', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(32),
                child: Material(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    onTap: () => showModalBottomSheet<Devise>(
                      context: context,
                      builder: (context) => FeuilleSelection<Devise>(
                        titre: l10n.devise,
                        options: Devise.values,
                        libelleDe: (d) =>
                            '${devisesDisponibles[d]!.symbole} · '
                            '${libelleDevise(l10n, d)}',
                        estSelectionne: (d) => d == Devise.xof,
                        avecOptionTous: false,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text('FCFA · Franc CFA (UEMOA)'),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('_tmp_devise_rangee.png'),
    );

    await tester.tap(find.text('FCFA · Franc CFA (UEMOA)'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(BottomSheet),
      matchesGoldenFile('_tmp_devise_feuille.png'),
    );
  });
}
