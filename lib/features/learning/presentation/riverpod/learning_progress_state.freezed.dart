// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LearningProgressState {
  /// 마지막으로 학습한 챕터 ID
  int get lastChapterId => throw _privateConstructorUsedError;

  /// 마지막으로 학습한 단계 ('theory', 'quiz', 'result')
  String get lastStep => throw _privateConstructorUsedError;

  /// 챕터별 완료 상태 {chapterId: isCompleted}
  Map<int, bool> get completedChapters => throw _privateConstructorUsedError;

  /// 퀴즈별 완료 상태 {chapterId: isCompleted}
  Map<int, bool> get completedQuizzes => throw _privateConstructorUsedError;

  /// 학습한 날짜들 (연속 학습일 계산용) 'yyyy-MM-dd' 형태
  Set<String> get studiedDates => throw _privateConstructorUsedError;

  /// 사용 가능한 챕터 목록 (Repository에서 조회)
  List<Map<String, dynamic>> get availableChapters =>
      throw _privateConstructorUsedError;

  /// 초기화 완료 여부
  bool get isInitialized => throw _privateConstructorUsedError;

  /// 로딩 중
  bool get isLoading => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of LearningProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningProgressStateCopyWith<LearningProgressState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningProgressStateCopyWith<$Res> {
  factory $LearningProgressStateCopyWith(LearningProgressState value,
          $Res Function(LearningProgressState) then) =
      _$LearningProgressStateCopyWithImpl<$Res, LearningProgressState>;
  @useResult
  $Res call(
      {int lastChapterId,
      String lastStep,
      Map<int, bool> completedChapters,
      Map<int, bool> completedQuizzes,
      Set<String> studiedDates,
      List<Map<String, dynamic>> availableChapters,
      bool isInitialized,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$LearningProgressStateCopyWithImpl<$Res,
        $Val extends LearningProgressState>
    implements $LearningProgressStateCopyWith<$Res> {
  _$LearningProgressStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastChapterId = null,
    Object? lastStep = null,
    Object? completedChapters = null,
    Object? completedQuizzes = null,
    Object? studiedDates = null,
    Object? availableChapters = null,
    Object? isInitialized = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      lastChapterId: null == lastChapterId
          ? _value.lastChapterId
          : lastChapterId // ignore: cast_nullable_to_non_nullable
              as int,
      lastStep: null == lastStep
          ? _value.lastStep
          : lastStep // ignore: cast_nullable_to_non_nullable
              as String,
      completedChapters: null == completedChapters
          ? _value.completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      completedQuizzes: null == completedQuizzes
          ? _value.completedQuizzes
          : completedQuizzes // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      studiedDates: null == studiedDates
          ? _value.studiedDates
          : studiedDates // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      availableChapters: null == availableChapters
          ? _value.availableChapters
          : availableChapters // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$LearningProgressStateImplCopyWith<$Res>
    implements $LearningProgressStateCopyWith<$Res> {
  factory _$$LearningProgressStateImplCopyWith(
          _$LearningProgressStateImpl value,
          $Res Function(_$LearningProgressStateImpl) then) =
      __$$LearningProgressStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int lastChapterId,
      String lastStep,
      Map<int, bool> completedChapters,
      Map<int, bool> completedQuizzes,
      Set<String> studiedDates,
      List<Map<String, dynamic>> availableChapters,
      bool isInitialized,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$LearningProgressStateImplCopyWithImpl<$Res>
    extends _$LearningProgressStateCopyWithImpl<$Res,
        _$LearningProgressStateImpl>
    implements _$$LearningProgressStateImplCopyWith<$Res> {
  __$$LearningProgressStateImplCopyWithImpl(_$LearningProgressStateImpl _value,
      $Res Function(_$LearningProgressStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastChapterId = null,
    Object? lastStep = null,
    Object? completedChapters = null,
    Object? completedQuizzes = null,
    Object? studiedDates = null,
    Object? availableChapters = null,
    Object? isInitialized = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$LearningProgressStateImpl(
      lastChapterId: null == lastChapterId
          ? _value.lastChapterId
          : lastChapterId // ignore: cast_nullable_to_non_nullable
              as int,
      lastStep: null == lastStep
          ? _value.lastStep
          : lastStep // ignore: cast_nullable_to_non_nullable
              as String,
      completedChapters: null == completedChapters
          ? _value._completedChapters
          : completedChapters // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      completedQuizzes: null == completedQuizzes
          ? _value._completedQuizzes
          : completedQuizzes // ignore: cast_nullable_to_non_nullable
              as Map<int, bool>,
      studiedDates: null == studiedDates
          ? _value._studiedDates
          : studiedDates // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      availableChapters: null == availableChapters
          ? _value._availableChapters
          : availableChapters // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
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

class _$LearningProgressStateImpl extends _LearningProgressState {
  const _$LearningProgressStateImpl(
      {this.lastChapterId = 1,
      this.lastStep = 'theory',
      final Map<int, bool> completedChapters = const {},
      final Map<int, bool> completedQuizzes = const {},
      final Set<String> studiedDates = const {},
      final List<Map<String, dynamic>> availableChapters = const [],
      this.isInitialized = false,
      this.isLoading = false,
      this.errorMessage})
      : _completedChapters = completedChapters,
        _completedQuizzes = completedQuizzes,
        _studiedDates = studiedDates,
        _availableChapters = availableChapters,
        super._();

  /// 마지막으로 학습한 챕터 ID
  @override
  @JsonKey()
  final int lastChapterId;

  /// 마지막으로 학습한 단계 ('theory', 'quiz', 'result')
  @override
  @JsonKey()
  final String lastStep;

  /// 챕터별 완료 상태 {chapterId: isCompleted}
  final Map<int, bool> _completedChapters;

  /// 챕터별 완료 상태 {chapterId: isCompleted}
  @override
  @JsonKey()
  Map<int, bool> get completedChapters {
    if (_completedChapters is EqualUnmodifiableMapView)
      return _completedChapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedChapters);
  }

  /// 퀴즈별 완료 상태 {chapterId: isCompleted}
  final Map<int, bool> _completedQuizzes;

  /// 퀴즈별 완료 상태 {chapterId: isCompleted}
  @override
  @JsonKey()
  Map<int, bool> get completedQuizzes {
    if (_completedQuizzes is EqualUnmodifiableMapView) return _completedQuizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedQuizzes);
  }

  /// 학습한 날짜들 (연속 학습일 계산용) 'yyyy-MM-dd' 형태
  final Set<String> _studiedDates;

  /// 학습한 날짜들 (연속 학습일 계산용) 'yyyy-MM-dd' 형태
  @override
  @JsonKey()
  Set<String> get studiedDates {
    if (_studiedDates is EqualUnmodifiableSetView) return _studiedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_studiedDates);
  }

  /// 사용 가능한 챕터 목록 (Repository에서 조회)
  final List<Map<String, dynamic>> _availableChapters;

  /// 사용 가능한 챕터 목록 (Repository에서 조회)
  @override
  @JsonKey()
  List<Map<String, dynamic>> get availableChapters {
    if (_availableChapters is EqualUnmodifiableListView)
      return _availableChapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableChapters);
  }

  /// 초기화 완료 여부
  @override
  @JsonKey()
  final bool isInitialized;

  /// 로딩 중
  @override
  @JsonKey()
  final bool isLoading;

  /// 에러 메시지
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'LearningProgressState(lastChapterId: $lastChapterId, lastStep: $lastStep, completedChapters: $completedChapters, completedQuizzes: $completedQuizzes, studiedDates: $studiedDates, availableChapters: $availableChapters, isInitialized: $isInitialized, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningProgressStateImpl &&
            (identical(other.lastChapterId, lastChapterId) ||
                other.lastChapterId == lastChapterId) &&
            (identical(other.lastStep, lastStep) ||
                other.lastStep == lastStep) &&
            const DeepCollectionEquality()
                .equals(other._completedChapters, _completedChapters) &&
            const DeepCollectionEquality()
                .equals(other._completedQuizzes, _completedQuizzes) &&
            const DeepCollectionEquality()
                .equals(other._studiedDates, _studiedDates) &&
            const DeepCollectionEquality()
                .equals(other._availableChapters, _availableChapters) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lastChapterId,
      lastStep,
      const DeepCollectionEquality().hash(_completedChapters),
      const DeepCollectionEquality().hash(_completedQuizzes),
      const DeepCollectionEquality().hash(_studiedDates),
      const DeepCollectionEquality().hash(_availableChapters),
      isInitialized,
      isLoading,
      errorMessage);

  /// Create a copy of LearningProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningProgressStateImplCopyWith<_$LearningProgressStateImpl>
      get copyWith => __$$LearningProgressStateImplCopyWithImpl<
          _$LearningProgressStateImpl>(this, _$identity);
}

abstract class _LearningProgressState extends LearningProgressState {
  const factory _LearningProgressState(
      {final int lastChapterId,
      final String lastStep,
      final Map<int, bool> completedChapters,
      final Map<int, bool> completedQuizzes,
      final Set<String> studiedDates,
      final List<Map<String, dynamic>> availableChapters,
      final bool isInitialized,
      final bool isLoading,
      final String? errorMessage}) = _$LearningProgressStateImpl;
  const _LearningProgressState._() : super._();

  /// 마지막으로 학습한 챕터 ID
  @override
  int get lastChapterId;

  /// 마지막으로 학습한 단계 ('theory', 'quiz', 'result')
  @override
  String get lastStep;

  /// 챕터별 완료 상태 {chapterId: isCompleted}
  @override
  Map<int, bool> get completedChapters;

  /// 퀴즈별 완료 상태 {chapterId: isCompleted}
  @override
  Map<int, bool> get completedQuizzes;

  /// 학습한 날짜들 (연속 학습일 계산용) 'yyyy-MM-dd' 형태
  @override
  Set<String> get studiedDates;

  /// 사용 가능한 챕터 목록 (Repository에서 조회)
  @override
  List<Map<String, dynamic>> get availableChapters;

  /// 초기화 완료 여부
  @override
  bool get isInitialized;

  /// 로딩 중
  @override
  bool get isLoading;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of LearningProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningProgressStateImplCopyWith<_$LearningProgressStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
