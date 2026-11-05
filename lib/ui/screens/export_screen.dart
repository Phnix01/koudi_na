import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../logic/providers/langue_provider.dart';
import '../../logic/providers/repositories_providers.dart';
import '../../logic/services/export_csv.dart';
import '../../logic/services/export_excel.dart';
import '../../logic/services/export_pdf.dart';
import '../../logic/services/filtre_periode.dart';
import '../../logic/services/partage_csv.dart';
import '../../logic/services/partage_fichier.dart';
import '../widgets/segmented_toggle.dart';

/// Les trois formats proposés (section Export, Réglages) : noms non
/// traduits, comme les autres sigles de l'app (FCFA, CSV...).
enum _FormatExport { csv, pdf, excel }

extension on _FormatExport {
  String get label => switch (this) {
    _FormatExport.csv => 'CSV',
    _FormatExport.pdf => 'PDF',
    _FormatExport.excel => 'Excel',
  };

  String get extension => switch (this) {
    _FormatExport.csv => 'csv',
    _FormatExport.pdf => 'pdf',
    _FormatExport.excel => 'xlsx',
  };
}

/// Écran unifié d'export (section Export, Réglages) : choix de la
/// période (mois courant / tout / plage personnalisée) puis du format
/// (CSV / PDF / Excel), remplace les deux raccourcis CSV figés d'avant.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  PeriodeExport _periode = PeriodeExport.moisCourant;
  DateTimeRange? _plage;
  _FormatExport _format = _FormatExport.csv;
  bool _exportEnCours = false;

  Future<void> _choisirPlage() async {
    final choix = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _plage,
    );
    if (choix != null) setState(() => _plage = choix);
  }

  String _suffixePeriode() {
    switch (_periode) {
      case PeriodeExport.moisCourant:
        return DateFormat('yyyy-MM').format(DateTime.now());
      case PeriodeExport.tout:
        return 'tout';
      case PeriodeExport.personnalisee:
        final f = DateFormat('yyyyMMdd');
        return '${f.format(_plage!.start)}_${f.format(_plage!.end)}';
    }
  }

  String _libellePeriode(String langue) {
    final l10n = context.l10n;
    switch (_periode) {
      case PeriodeExport.moisCourant:
        final libelle = DateFormat.yMMMM(langue).format(DateTime.now());
        return libelle[0].toUpperCase() + libelle.substring(1);
      case PeriodeExport.tout:
        return l10n.periodeTout;
      case PeriodeExport.personnalisee:
        return l10n.plageDatesValeur(
          DateFormat.yMd(langue).format(_plage!.start),
          DateFormat.yMd(langue).format(_plage!.end),
        );
    }
  }

  Future<void> _exporter() async {
    final l10n = context.l10n;
    setState(() => _exportEnCours = true);
    try {
      final categoriesParId = {
        for (final c in ref.read(categorieRepositoryProvider).tous()) c.id: c,
      };
      final comptesParId = {
        for (final c in ref.read(compteRepositoryProvider).tous()) c.id: c,
      };
      final transactions =
          filtrerParPeriode(
            ref.read(transactionRepositoryProvider).tous(),
            _periode,
            _plage,
          )
          ..sort((a, b) => a.date.compareTo(b.date));
      final langue = ref.read(localeProvider).languageCode;
      final nomFichier = 'koudi_na_${_suffixePeriode()}.${_format.extension}';
      final texte = l10n.exportPartageTexte(nomFichier);

      switch (_format) {
        case _FormatExport.csv:
          final csv = genererCsvTransactions(
            transactions,
            categoriesParId,
            comptesParId,
            langue: langue,
          );
          await partagerCsv(csv, nomFichier, texte: texte);
        case _FormatExport.excel:
          final octets = genererExcelTransactions(
            transactions,
            categoriesParId,
            comptesParId,
            langue: langue,
          );
          await partagerFichier(octets, nomFichier, texte: texte);
        case _FormatExport.pdf:
          final octets = await genererPdfTransactions(
            transactions: transactions,
            categoriesParId: categoriesParId,
            comptesParId: comptesParId,
            langue: langue,
            libellePeriode: _libellePeriode(langue),
            libelleGenereLe: l10n.genereLe(
              DateFormat.yMd(langue).add_Hm().format(DateTime.now()),
            ),
            libelleEntrees: l10n.entrees,
            libelleDepenses: l10n.depenses,
            libelleSolde: l10n.solde,
          );
          await partagerFichier(octets, nomFichier, texte: texte);
      }
    } finally {
      if (mounted) setState(() => _exportEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final peutExporter =
        !_exportEnCours &&
        (_periode != PeriodeExport.personnalisee || _plage != null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.export)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Text(l10n.periode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s8),
          SegmentedToggle<PeriodeExport>(
            options: [
              SegmentedToggleOption(
                valeur: PeriodeExport.moisCourant,
                label: l10n.periodeMoisCourant,
              ),
              SegmentedToggleOption(
                valeur: PeriodeExport.tout,
                label: l10n.periodeTout,
              ),
              SegmentedToggleOption(
                valeur: PeriodeExport.personnalisee,
                label: l10n.periodePersonnalisee,
              ),
            ],
            selectionne: _periode,
            onChanged: (periode) => setState(() => _periode = periode),
          ),
          if (_periode == PeriodeExport.personnalisee) ...[
            const SizedBox(height: AppSpacing.s12),
            _LignePlageDates(plage: _plage, onTap: _choisirPlage),
          ],
          const SizedBox(height: AppSpacing.s24),
          Text(l10n.format, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s8),
          SegmentedToggle<_FormatExport>(
            options: [
              for (final format in _FormatExport.values)
                SegmentedToggleOption(valeur: format, label: format.label),
            ],
            selectionne: _format,
            onChanged: (format) => setState(() => _format = format),
          ),
          const SizedBox(height: AppSpacing.s32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: peutExporter ? _exporter : null,
              child: _exportEnCours
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.exporterBouton),
            ),
          ),
        ],
      ),
    );
  }
}

class _LignePlageDates extends StatelessWidget {
  const _LignePlageDates({required this.plage, required this.onTap});

  final DateTimeRange? plage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final langue = Localizations.localeOf(context).languageCode;
    final texte = plage == null
        ? l10n.choisirDates
        : l10n.plageDatesValeur(
            DateFormat.yMd(langue).format(plage!.start),
            DateFormat.yMd(langue).format(plage!.end),
          );
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Expanded(child: Text(texte)),
              const PhosphorIcon(PhosphorIconsRegular.caretRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
