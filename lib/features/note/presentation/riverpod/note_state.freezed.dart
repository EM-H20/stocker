// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NoteState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  List<Note> get notes => throw _privateConstructorUsedError;

  /// Create a copy of NoteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteStateCopyWith<NoteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteStateCopyWith<$Res> {
  factory $NoteStateCopyWith(NoteState value, $Res Function(NoteState) then) =
      _$NoteStateCopyWithImpl<$Res, NoteState>;
  @useResult
  $Res call({bool isLoading, String? errorMessage, List<Note> notes});
}

/// @nodoc
class _$NoteStateCopyWithImpl<$Res, $Val extends NoteState>
    implements $NoteStateCopyWith<$Res> {
  _$NoteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<Note>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NoteStateImplCopyWith<$Res>
    implements $NoteStateCopyWith<$Res> {
  factory _$$NoteStateImplCopyWith(
          _$NoteStateImpl value, $Res Function(_$NoteStateImpl) then) =
      __$$NoteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, String? errorMessage, List<Note> notes});
}

/// @nodoc
class __$$NoteStateImplCopyWithImpl<$Res>
    extends _$NoteStateCopyWithImpl<$Res, _$NoteStateImpl>
    implements _$$NoteStateImplCopyWith<$Res> {
  __$$NoteStateImplCopyWithImpl(
      _$NoteStateImpl _value, $Res Function(_$NoteStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NoteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? notes = null,
  }) {
    return _then(_$NoteStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<Note>,
    ));
  }
}

/// @nodoc

class _$NoteStateImpl extends _NoteState {
  const _$NoteStateImpl(
      {this.isLoading = false,
      this.errorMessage,
      final List<Note> notes = const []})
      : _notes = notes,
        super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  final List<Note> _notes;
  @override
  @JsonKey()
  List<Note> get notes {
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'NoteState(isLoading: $isLoading, errorMessage: $errorMessage, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, errorMessage,
      const DeepCollectionEquality().hash(_notes));

  /// Create a copy of NoteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteStateImplCopyWith<_$NoteStateImpl> get copyWith =>
      __$$NoteStateImplCopyWithImpl<_$NoteStateImpl>(this, _$identity);
}

abstract class _NoteState extends NoteState {
  const factory _NoteState(
      {final bool isLoading,
      final String? errorMessage,
      final List<Note> notes}) = _$NoteStateImpl;
  const _NoteState._() : super._();

  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  List<Note> get notes;

  /// Create a copy of NoteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteStateImplCopyWith<_$NoteStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
