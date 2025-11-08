// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wrong_note_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WrongNoteState {
  /// 오답노트 목록
  List<WrongNoteItem> get wrongNotes => throw _privateConstructorUsedError;

  /// 재시도된 퀴즈 ID들
  Set<int> get retriedQuizIds => throw _privateConstructorUsedError;

  /// 삭제 처리 중인 퀴즈 ID들 (중복 방지)
  Set<int> get deletingQuizIds => throw _privateConstructorUsedError;

  /// 로딩 중
  bool get isLoading => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of WrongNoteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WrongNoteStateCopyWith<WrongNoteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrongNoteStateCopyWith<$Res> {
  factory $WrongNoteStateCopyWith(
          WrongNoteState value, $Res Function(WrongNoteState) then) =
      _$WrongNoteStateCopyWithImpl<$Res, WrongNoteState>;
  @useResult
  $Res call(
      {List<WrongNoteItem> wrongNotes,
      Set<int> retriedQuizIds,
      Set<int> deletingQuizIds,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$WrongNoteStateCopyWithImpl<$Res, $Val extends WrongNoteState>
    implements $WrongNoteStateCopyWith<$Res> {
  _$WrongNoteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WrongNoteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wrongNotes = null,
    Object? retriedQuizIds = null,
    Object? deletingQuizIds = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      wrongNotes: null == wrongNotes
          ? _value.wrongNotes
          : wrongNotes // ignore: cast_nullable_to_non_nullable
              as List<WrongNoteItem>,
      retriedQuizIds: null == retriedQuizIds
          ? _value.retriedQuizIds
          : retriedQuizIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      deletingQuizIds: null == deletingQuizIds
          ? _value.deletingQuizIds
          : deletingQuizIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WrongNoteStateImplCopyWith<$Res>
    implements $WrongNoteStateCopyWith<$Res> {
  factory _$$WrongNoteStateImplCopyWith(_$WrongNoteStateImpl value,
          $Res Function(_$WrongNoteStateImpl) then) =
      __$$WrongNoteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WrongNoteItem> wrongNotes,
      Set<int> retriedQuizIds,
      Set<int> deletingQuizIds,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$WrongNoteStateImplCopyWithImpl<$Res>
    extends _$WrongNoteStateCopyWithImpl<$Res, _$WrongNoteStateImpl>
    implements _$$WrongNoteStateImplCopyWith<$Res> {
  __$$WrongNoteStateImplCopyWithImpl(
      _$WrongNoteStateImpl _value, $Res Function(_$WrongNoteStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WrongNoteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wrongNotes = null,
    Object? retriedQuizIds = null,
    Object? deletingQuizIds = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$WrongNoteStateImpl(
      wrongNotes: null == wrongNotes
          ? _value._wrongNotes
          : wrongNotes // ignore: cast_nullable_to_non_nullable
              as List<WrongNoteItem>,
      retriedQuizIds: null == retriedQuizIds
          ? _value._retriedQuizIds
          : retriedQuizIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      deletingQuizIds: null == deletingQuizIds
          ? _value._deletingQuizIds
          : deletingQuizIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$WrongNoteStateImpl extends _WrongNoteState {
  const _$WrongNoteStateImpl(
      {final List<WrongNoteItem> wrongNotes = const [],
      final Set<int> retriedQuizIds = const {},
      final Set<int> deletingQuizIds = const {},
      this.isLoading = false,
      this.errorMessage})
      : _wrongNotes = wrongNotes,
        _retriedQuizIds = retriedQuizIds,
        _deletingQuizIds = deletingQuizIds,
        super._();

  /// 오답노트 목록
  final List<WrongNoteItem> _wrongNotes;

  /// 오답노트 목록
  @override
  @JsonKey()
  List<WrongNoteItem> get wrongNotes {
    if (_wrongNotes is EqualUnmodifiableListView) return _wrongNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wrongNotes);
  }

  /// 재시도된 퀴즈 ID들
  final Set<int> _retriedQuizIds;

  /// 재시도된 퀴즈 ID들
  @override
  @JsonKey()
  Set<int> get retriedQuizIds {
    if (_retriedQuizIds is EqualUnmodifiableSetView) return _retriedQuizIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_retriedQuizIds);
  }

  /// 삭제 처리 중인 퀴즈 ID들 (중복 방지)
  final Set<int> _deletingQuizIds;

  /// 삭제 처리 중인 퀴즈 ID들 (중복 방지)
  @override
  @JsonKey()
  Set<int> get deletingQuizIds {
    if (_deletingQuizIds is EqualUnmodifiableSetView) return _deletingQuizIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_deletingQuizIds);
  }

  /// 로딩 중
  @override
  @JsonKey()
  final bool isLoading;

  /// 에러 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'WrongNoteState(wrongNotes: $wrongNotes, retriedQuizIds: $retriedQuizIds, deletingQuizIds: $deletingQuizIds, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrongNoteStateImpl &&
            const DeepCollectionEquality()
                .equals(other._wrongNotes, _wrongNotes) &&
            const DeepCollectionEquality()
                .equals(other._retriedQuizIds, _retriedQuizIds) &&
            const DeepCollectionEquality()
                .equals(other._deletingQuizIds, _deletingQuizIds) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_wrongNotes),
      const DeepCollectionEquality().hash(_retriedQuizIds),
      const DeepCollectionEquality().hash(_deletingQuizIds),
      isLoading,
      errorMessage);

  /// Create a copy of WrongNoteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WrongNoteStateImplCopyWith<_$WrongNoteStateImpl> get copyWith =>
      __$$WrongNoteStateImplCopyWithImpl<_$WrongNoteStateImpl>(
          this, _$identity);
}

abstract class _WrongNoteState extends WrongNoteState {
  const factory _WrongNoteState(
      {final List<WrongNoteItem> wrongNotes,
      final Set<int> retriedQuizIds,
      final Set<int> deletingQuizIds,
      final bool isLoading,
      final String? errorMessage}) = _$WrongNoteStateImpl;
  const _WrongNoteState._() : super._();

  /// 오답노트 목록
  @override
  List<WrongNoteItem> get wrongNotes;

  /// 재시도된 퀴즈 ID들
  @override
  Set<int> get retriedQuizIds;

  /// 삭제 처리 중인 퀴즈 ID들 (중복 방지)
  @override
  Set<int> get deletingQuizIds;

  /// 로딩 중
  @override
  bool get isLoading;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of WrongNoteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WrongNoteStateImplCopyWith<_$WrongNoteStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
