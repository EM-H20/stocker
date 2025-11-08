import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/note.dart';

part 'note_state.freezed.dart';

/// 🔥 Riverpod 노트 상태 클래스 (Freezed)
@freezed
class NoteState with _$NoteState {
  const factory NoteState({
    /// 노트 목록
    @Default([]) List<Note> notes,

    /// 로딩 중
    @Default(false) bool isLoading,

    /// 에러 메시지
    String? errorMessage,
  }) = _NoteState;
}
