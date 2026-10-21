import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/providers/capture_form_provider.dart';
import '../../l10n/l10n.dart';

/// Note optionnelle (repliée par défaut) et date de la transaction
/// (section 4). Le champ note utilise un `TextEditingController` local
/// plutôt qu'un texte reconstruit depuis Riverpod à chaque frappe :
/// si le `TextField` lisait sa valeur directement depuis l'état
/// Riverpod, chaque caractère tapé provoquerait un rebuild qui replace
/// le curseur en fin de texte. On synchronise donc dans un seul sens
/// (`TextField` → provider), et on n'écoute le provider que pour
/// détecter la remise à zéro après un enregistrement.
class NoteEtDate extends ConsumerStatefulWidget {
  const NoteEtDate({super.key});

  @override
  ConsumerState<NoteEtDate> createState() => _NoteEtDateState();
}

class _NoteEtDateState extends ConsumerState<NoteEtDate> {
  bool _noteOuverte = false;
  final _controleurNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cas de l'écran Édition : le formulaire peut déjà contenir une
    // note au tout premier affichage (pré-remplie depuis la
    // transaction existante). On ne lit le provider qu'une fois ici :
    // ensuite, la synchronisation reste TextField → provider (voir la
    // note en tête de fichier).
    final noteInitiale = ref.read(captureFormProvider).note;
    if (noteInitiale.isNotEmpty) {
      _controleurNote.text = noteInitiale;
      _noteOuverte = true;
    }
  }

  @override
  void dispose() {
    _controleurNote.dispose();
    super.dispose();
  }

  bool _estAujourdHui(DateTime date) {
    final maintenant = DateTime.now();
    return date.year == maintenant.year &&
        date.month == maintenant.month &&
        date.day == maintenant.day;
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(captureFormProvider.select((form) => form.date));

    // Après reinitialiserApresEnregistrement(), form.note redevient '' :
    // on vide et on replie le champ pour la saisie suivante.
    ref.listen(captureFormProvider.select((form) => form.note), (avant, note) {
      if (note.isEmpty && _controleurNote.text.isNotEmpty) {
        _controleurNote.clear();
        setState(() => _noteOuverte = false);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _noteOuverte = !_noteOuverte),
              icon: PhosphorIcon(
                _noteOuverte
                    ? PhosphorIconsFill.minusCircle
                    : PhosphorIconsFill.plusCircle,
                size: 16,
              ),
              label: Text(
                _noteOuverte
                    ? context.l10n.retirerNote
                    : context.l10n.ajouterNote,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final choisie = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (choisie != null) {
                  ref.read(captureFormProvider.notifier).changerDate(choisie);
                }
              },
              icon: const Icon(Icons.calendar_today, size: 14),
              label: Text(
                _estAujourdHui(date)
                    ? context.l10n.aujourdHui
                    : DateFormat.MMMd().format(date),
              ),
            ),
          ],
        ),
        if (_noteOuverte)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextField(
              controller: _controleurNote,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: context.l10n.noteOptionnelle,
              ),
              onChanged: (valeur) =>
                  ref.read(captureFormProvider.notifier).changerNote(valeur),
            ),
          ),
      ],
    );
  }
}
