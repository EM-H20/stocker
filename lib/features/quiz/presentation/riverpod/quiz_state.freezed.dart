// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuizState {
  /// 현재 퀴즈 세션
  QuizSession? get currentQuizSession => throw _privateConstructorUsedError;

  /// 퀴즈 결과 목록
  List<QuizResult> get quizResults => throw _privateConstructorUsedError;

  /// 퀴즈 로딩 중
  bool get isLoadingQuiz => throw _privateConstructorUsedError;

  /// 답안 제출 중
  bool get isSubmittingAnswer => throw _privateConstructorUsedError;

  /// 퀴즈 결과 로딩 중
  bool get isLoadingResults => throw _privateConstructorUsedError;

  /// 읽기 전용 모드 (오답노트 복습용)
  bool get isReadOnlyMode => throw _privateConstructorUsedError;

  /// 타이머 실행 중
  bool get isTimerRunning => throw _privateConstructorUsedError;

  /// 남은 시간 (초)
  int get remainingSeconds => throw _privateConstructorUsedError;

  /// 퀴즈 에러 메시지
  String? get quizError => throw _privateConstructorUsedError;

  /// 퀴즈 결과 에러 메시지
  String? get resultsError => throw _privateConstructorUsedError;

  /// Create a copy of QuizState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizStateCopyWith<QuizState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizStateCopyWith<$Res> {
  factory $QuizStateCopyWith(QuizState value, $Res Function(QuizState) then) =
      _$QuizStateCopyWithImpl<$Res, QuizState>;
  @useResult
  $Res call(
      {QuizSession? currentQuizSession,
      List<QuizResult> quizResults,
      bool isLoadingQuiz,
      bool isSubmittingAnswer,
      bool isLoadingResults,
      bool isReadOnlyMode,
      bool isTimerRunning,
      int remainingSeconds,
      String? quizError,
      String? resultsError});
}

/// @nodoc
class _$QuizStateCopyWithImpl<$Res, $Val extends QuizState>
    implements $QuizStateCopyWith<$Res> {
  _$QuizStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentQuizSession = freezed,
    Object? quizResults = null,
    Object? isLoadingQuiz = null,
    Object? isSubmittingAnswer = null,
    Object? isLoadingResults = null,
    Object? isReadOnlyMode = null,
    Object? isTimerRunning = null,
    Object? remainingSeconds = null,
    Object? quizError = freezed,
    Object? resultsError = freezed,
  }) {
    return _then(_value.copyWith(
      currentQuizSession: freezed == currentQuizSession
          ? _value.currentQuizSession
          : currentQuizSession // ignore: cast_nullable_to_non_nullable
              as QuizSession?,
      quizResults: null == quizResults
          ? _value.quizResults
          : quizResults // ignore: cast_nullable_to_non_nullable
              as List<QuizResult>,
      isLoadingQuiz: null == isLoadingQuiz
          ? _value.isLoadingQuiz
          : isLoadingQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmittingAnswer: null == isSubmittingAnswer
          ? _value.isSubmittingAnswer
          : isSubmittingAnswer // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingResults: null == isLoadingResults
          ? _value.isLoadingResults
          : isLoadingResults // ignore: cast_nullable_to_non_nullable
              as bool,
      isReadOnlyMode: null == isReadOnlyMode
          ? _value.isReadOnlyMode
          : isReadOnlyMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isTimerRunning: null == isTimerRunning
          ? _value.isTimerRunning
          : isTimerRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      quizError: freezed == quizError
          ? _value.quizError
          : quizError // ignore: cast_nullable_to_non_nullable
              as String?,
      resultsError: freezed == resultsError
          ? _value.resultsError
          : resultsError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizStateImplCopyWith<$Res>
    implements $QuizStateCopyWith<$Res> {
  factory _$$QuizStateImplCopyWith(
          _$QuizStateImpl value, $Res Function(_$QuizStateImpl) then) =
      __$$QuizStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {QuizSession? currentQuizSession,
      List<QuizResult> quizResults,
      bool isLoadingQuiz,
      bool isSubmittingAnswer,
      bool isLoadingResults,
      bool isReadOnlyMode,
      bool isTimerRunning,
      int remainingSeconds,
      String? quizError,
      String? resultsError});
}

/// @nodoc
class __$$QuizStateImplCopyWithImpl<$Res>
    extends _$QuizStateCopyWithImpl<$Res, _$QuizStateImpl>
    implements _$$QuizStateImplCopyWith<$Res> {
  __$$QuizStateImplCopyWithImpl(
      _$QuizStateImpl _value, $Res Function(_$QuizStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuizState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentQuizSession = freezed,
    Object? quizResults = null,
    Object? isLoadingQuiz = null,
    Object? isSubmittingAnswer = null,
    Object? isLoadingResults = null,
    Object? isReadOnlyMode = null,
    Object? isTimerRunning = null,
    Object? remainingSeconds = null,
    Object? quizError = freezed,
    Object? resultsError = freezed,
  }) {
    return _then(_$QuizStateImpl(
      currentQuizSession: freezed == currentQuizSession
          ? _value.currentQuizSession
          : currentQuizSession // ignore: cast_nullable_to_non_nullable
              as QuizSession?,
      quizResults: null == quizResults
          ? _value._quizResults
          : quizResults // ignore: cast_nullable_to_non_nullable
              as List<QuizResult>,
      isLoadingQuiz: null == isLoadingQuiz
          ? _value.isLoadingQuiz
          : isLoadingQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmittingAnswer: null == isSubmittingAnswer
          ? _value.isSubmittingAnswer
          : isSubmittingAnswer // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingResults: null == isLoadingResults
          ? _value.isLoadingResults
          : isLoadingResults // ignore: cast_nullable_to_non_nullable
              as bool,
      isReadOnlyMode: null == isReadOnlyMode
          ? _value.isReadOnlyMode
          : isReadOnlyMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isTimerRunning: null == isTimerRunning
          ? _value.isTimerRunning
          : isTimerRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      quizError: freezed == quizError
          ? _value.quizError
          : quizError // ignore: cast_nullable_to_non_nullable
              as String?,
      resultsError: freezed == resultsError
          ? _value.resultsError
          : resultsError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$QuizStateImpl extends _QuizState {
  const _$QuizStateImpl(
      {this.currentQuizSession,
      final List<QuizResult> quizResults = const [],
      this.isLoadingQuiz = false,
      this.isSubmittingAnswer = false,
      this.isLoadingResults = false,
      this.isReadOnlyMode = false,
      this.isTimerRunning = false,
      this.remainingSeconds = 0,
      this.quizError,
      this.resultsError})
      : _quizResults = quizResults,
        super._();

  /// 현재 퀴즈 세션
  @override
  final QuizSession? currentQuizSession;

  /// 퀴즈 결과 목록
  final List<QuizResult> _quizResults;

  /// 퀴즈 결과 목록
  @override
  @JsonKey()
  List<QuizResult> get quizResults {
    if (_quizResults is EqualUnmodifiableListView) return _quizResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizResults);
  }

  /// 퀴즈 로딩 중
  @override
  @JsonKey()
  final bool isLoadingQuiz;

  /// 답안 제출 중
  @override
  @JsonKey()
  final bool isSubmittingAnswer;

  /// 퀴즈 결과 로딩 중
  @override
  @JsonKey()
  final bool isLoadingResults;

  /// 읽기 전용 모드 (오답노트 복습용)
  @override
  @JsonKey()
  final bool isReadOnlyMode;

  /// 타이머 실행 중
  @override
  @JsonKey()
  final bool isTimerRunning;

  /// 남은 시간 (초)
  @override
  @JsonKey()
  final int remainingSeconds;

  /// 퀴즈 에러 메시지
  @override
  final String? quizError;

  /// 퀴즈 결과 에러 메시지
  @override
  final String? resultsError;

  @override
  String toString() {
    return 'QuizState(currentQuizSession: $currentQuizSession, quizResults: $quizResults, isLoadingQuiz: $isLoadingQuiz, isSubmittingAnswer: $isSubmittingAnswer, isLoadingResults: $isLoadingResults, isReadOnlyMode: $isReadOnlyMode, isTimerRunning: $isTimerRunning, remainingSeconds: $remainingSeconds, quizError: $quizError, resultsError: $resultsError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizStateImpl &&
            (identical(other.currentQuizSession, currentQuizSession) ||
                other.currentQuizSession == currentQuizSession) &&
            const DeepCollectionEquality()
                .equals(other._quizResults, _quizResults) &&
            (identical(other.isLoadingQuiz, isLoadingQuiz) ||
                other.isLoadingQuiz == isLoadingQuiz) &&
            (identical(other.isSubmittingAnswer, isSubmittingAnswer) ||
                other.isSubmittingAnswer == isSubmittingAnswer) &&
            (identical(other.isLoadingResults, isLoadingResults) ||
                other.isLoadingResults == isLoadingResults) &&
            (identical(other.isReadOnlyMode, isReadOnlyMode) ||
                other.isReadOnlyMode == isReadOnlyMode) &&
            (identical(other.isTimerRunning, isTimerRunning) ||
                other.isTimerRunning == isTimerRunning) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.quizError, quizError) ||
                other.quizError == quizError) &&
            (identical(other.resultsError, resultsError) ||
                other.resultsError == resultsError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentQuizSession,
      const DeepCollectionEquality().hash(_quizResults),
      isLoadingQuiz,
      isSubmittingAnswer,
      isLoadingResults,
      isReadOnlyMode,
      isTimerRunning,
      remainingSeconds,
      quizError,
      resultsError);

  /// Create a copy of QuizState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizStateImplCopyWith<_$QuizStateImpl> get copyWith =>
      __$$QuizStateImplCopyWithImpl<_$QuizStateImpl>(this, _$identity);
}

abstract class _QuizState extends QuizState {
  const factory _QuizState(
      {final QuizSession? currentQuizSession,
      final List<QuizResult> quizResults,
      final bool isLoadingQuiz,
      final bool isSubmittingAnswer,
      final bool isLoadingResults,
      final bool isReadOnlyMode,
      final bool isTimerRunning,
      final int remainingSeconds,
      final String? quizError,
      final String? resultsError}) = _$QuizStateImpl;
  const _QuizState._() : super._();

  /// 현재 퀴즈 세션
  @override
  QuizSession? get currentQuizSession;

  /// 퀴즈 결과 목록
  @override
  List<QuizResult> get quizResults;

  /// 퀴즈 로딩 중
  @override
  bool get isLoadingQuiz;

  /// 답안 제출 중
  @override
  bool get isSubmittingAnswer;

  /// 퀴즈 결과 로딩 중
  @override
  bool get isLoadingResults;

  /// 읽기 전용 모드 (오답노트 복습용)
  @override
  bool get isReadOnlyMode;

  /// 타이머 실행 중
  @override
  bool get isTimerRunning;

  /// 남은 시간 (초)
  @override
  int get remainingSeconds;

  /// 퀴즈 에러 메시지
  @override
  String? get quizError;

  /// 퀴즈 결과 에러 메시지
  @override
  String? get resultsError;

  /// Create a copy of QuizState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizStateImplCopyWith<_$QuizStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
