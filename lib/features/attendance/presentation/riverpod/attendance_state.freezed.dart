// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AttendanceState {
  /// 출석 현황 (날짜 → 출석 여부 매핑)
  Map<DateTime, bool> get attendanceStatus =>
      throw _privateConstructorUsedError;

  /// 오늘의 퀴즈 목록
  List<AttendanceQuiz> get quizzes => throw _privateConstructorUsedError;

  /// 현재 포커스된 월
  DateTime get focusedMonth => throw _privateConstructorUsedError;

  /// 출석 현황 로딩 중
  bool get isLoading => throw _privateConstructorUsedError;

  /// 퀴즈 로딩 중
  bool get isQuizLoading => throw _privateConstructorUsedError;

  /// 퀴즈 제출 중
  bool get isSubmitting => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceStateCopyWith<AttendanceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceStateCopyWith<$Res> {
  factory $AttendanceStateCopyWith(
          AttendanceState value, $Res Function(AttendanceState) then) =
      _$AttendanceStateCopyWithImpl<$Res, AttendanceState>;
  @useResult
  $Res call(
      {Map<DateTime, bool> attendanceStatus,
      List<AttendanceQuiz> quizzes,
      DateTime focusedMonth,
      bool isLoading,
      bool isQuizLoading,
      bool isSubmitting,
      String? errorMessage});
}

/// @nodoc
class _$AttendanceStateCopyWithImpl<$Res, $Val extends AttendanceState>
    implements $AttendanceStateCopyWith<$Res> {
  _$AttendanceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attendanceStatus = null,
    Object? quizzes = null,
    Object? focusedMonth = null,
    Object? isLoading = null,
    Object? isQuizLoading = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      attendanceStatus: null == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, bool>,
      quizzes: null == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<AttendanceQuiz>,
      focusedMonth: null == focusedMonth
          ? _value.focusedMonth
          : focusedMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isQuizLoading: null == isQuizLoading
          ? _value.isQuizLoading
          : isQuizLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceStateImplCopyWith<$Res>
    implements $AttendanceStateCopyWith<$Res> {
  factory _$$AttendanceStateImplCopyWith(_$AttendanceStateImpl value,
          $Res Function(_$AttendanceStateImpl) then) =
      __$$AttendanceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<DateTime, bool> attendanceStatus,
      List<AttendanceQuiz> quizzes,
      DateTime focusedMonth,
      bool isLoading,
      bool isQuizLoading,
      bool isSubmitting,
      String? errorMessage});
}

/// @nodoc
class __$$AttendanceStateImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$AttendanceStateImpl>
    implements _$$AttendanceStateImplCopyWith<$Res> {
  __$$AttendanceStateImplCopyWithImpl(
      _$AttendanceStateImpl _value, $Res Function(_$AttendanceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attendanceStatus = null,
    Object? quizzes = null,
    Object? focusedMonth = null,
    Object? isLoading = null,
    Object? isQuizLoading = null,
    Object? isSubmitting = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$AttendanceStateImpl(
      attendanceStatus: null == attendanceStatus
          ? _value._attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as Map<DateTime, bool>,
      quizzes: null == quizzes
          ? _value._quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<AttendanceQuiz>,
      focusedMonth: null == focusedMonth
          ? _value.focusedMonth
          : focusedMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isQuizLoading: null == isQuizLoading
          ? _value.isQuizLoading
          : isQuizLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AttendanceStateImpl extends _AttendanceState {
  const _$AttendanceStateImpl(
      {final Map<DateTime, bool> attendanceStatus = const {},
      final List<AttendanceQuiz> quizzes = const [],
      required this.focusedMonth,
      this.isLoading = false,
      this.isQuizLoading = false,
      this.isSubmitting = false,
      this.errorMessage})
      : _attendanceStatus = attendanceStatus,
        _quizzes = quizzes,
        super._();

  /// 출석 현황 (날짜 → 출석 여부 매핑)
  final Map<DateTime, bool> _attendanceStatus;

  /// 출석 현황 (날짜 → 출석 여부 매핑)
  @override
  @JsonKey()
  Map<DateTime, bool> get attendanceStatus {
    if (_attendanceStatus is EqualUnmodifiableMapView) return _attendanceStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attendanceStatus);
  }

  /// 오늘의 퀴즈 목록
  final List<AttendanceQuiz> _quizzes;

  /// 오늘의 퀴즈 목록
  @override
  @JsonKey()
  List<AttendanceQuiz> get quizzes {
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizzes);
  }

  /// 현재 포커스된 월
  @override
  final DateTime focusedMonth;

  /// 출석 현황 로딩 중
  @override
  @JsonKey()
  final bool isLoading;

  /// 퀴즈 로딩 중
  @override
  @JsonKey()
  final bool isQuizLoading;

  /// 퀴즈 제출 중
  @override
  @JsonKey()
  final bool isSubmitting;

  /// 에러 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AttendanceState(attendanceStatus: $attendanceStatus, quizzes: $quizzes, focusedMonth: $focusedMonth, isLoading: $isLoading, isQuizLoading: $isQuizLoading, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceStateImpl &&
            const DeepCollectionEquality()
                .equals(other._attendanceStatus, _attendanceStatus) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes) &&
            (identical(other.focusedMonth, focusedMonth) ||
                other.focusedMonth == focusedMonth) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isQuizLoading, isQuizLoading) ||
                other.isQuizLoading == isQuizLoading) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_attendanceStatus),
      const DeepCollectionEquality().hash(_quizzes),
      focusedMonth,
      isLoading,
      isQuizLoading,
      isSubmitting,
      errorMessage);

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceStateImplCopyWith<_$AttendanceStateImpl> get copyWith =>
      __$$AttendanceStateImplCopyWithImpl<_$AttendanceStateImpl>(
          this, _$identity);
}

abstract class _AttendanceState extends AttendanceState {
  const factory _AttendanceState(
      {final Map<DateTime, bool> attendanceStatus,
      final List<AttendanceQuiz> quizzes,
      required final DateTime focusedMonth,
      final bool isLoading,
      final bool isQuizLoading,
      final bool isSubmitting,
      final String? errorMessage}) = _$AttendanceStateImpl;
  const _AttendanceState._() : super._();

  /// 출석 현황 (날짜 → 출석 여부 매핑)
  @override
  Map<DateTime, bool> get attendanceStatus;

  /// 오늘의 퀴즈 목록
  @override
  List<AttendanceQuiz> get quizzes;

  /// 현재 포커스된 월
  @override
  DateTime get focusedMonth;

  /// 출석 현황 로딩 중
  @override
  bool get isLoading;

  /// 퀴즈 로딩 중
  @override
  bool get isQuizLoading;

  /// 퀴즈 제출 중
  @override
  bool get isSubmitting;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceStateImplCopyWith<_$AttendanceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
