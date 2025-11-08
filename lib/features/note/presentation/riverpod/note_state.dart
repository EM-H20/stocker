import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/note.dart';

part 'note_state.freezed.dart';

@freezed
class NoteState with _$NoteState {
  const factory NoteState({
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default([]) List<Note> notes,
  }) = _NoteState;

  const NoteState._();

  bool get hasError => errorMessage != null;
  int get noteCount => notes.length;
  bool get hasNotes => notes.isNotEmpty;
}
