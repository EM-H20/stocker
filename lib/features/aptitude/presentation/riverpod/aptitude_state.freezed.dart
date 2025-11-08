// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aptitude_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AptitudeState {
  /// 로딩 중
  bool get isLoading => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 질문 목록
  List<AptitudeQuestion> get questions => throw _privateConstructorUsedError;

  /// 답변 맵 (questionId → value)
  Map<int, int> get answers => throw _privateConstructorUsedError;

  /// 내 검사 결과 (마지막 저장된 결과)
  AptitudeResult? get myResult => throw _privateConstructorUsedError;

  /// 현재 보고 있는 결과 (상세 보기용)
  AptitudeResult? get currentResult => throw _privateConstructorUsedError;

  /// 이전 검사 결과 존재 여부
  bool get hasPreviousResult => throw _privateConstructorUsedError;

  /// 모든 성향 타입 목록
  List<AptitudeTypeSummary> get allTypes => throw _privateConstructorUsedError;

  /// Create a copy of AptitudeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AptitudeStateCopyWith<AptitudeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AptitudeStateCopyWith<$Res> {
  factory $AptitudeStateCopyWith(
          AptitudeState value, $Res Function(AptitudeState) then) =
      _$AptitudeStateCopyWithImpl<$Res, AptitudeState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? errorMessage,
      List<AptitudeQuestion> questions,
      Map<int, int> answers,
      AptitudeResult? myResult,
      AptitudeResult? currentResult,
      bool hasPreviousResult,
      List<AptitudeTypeSummary> allTypes});
}

/// @nodoc
class _$AptitudeStateCopyWithImpl<$Res, $Val extends AptitudeState>
    implements $AptitudeStateCopyWith<$Res> {
  _$AptitudeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AptitudeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? questions = null,
    Object? answers = null,
    Object? myResult = freezed,
    Object? currentResult = freezed,
    Object? hasPreviousResult = null,
    Object? allTypes = null,
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
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<AptitudeQuestion>,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      myResult: freezed == myResult
          ? _value.myResult
          : myResult // ignore: cast_nullable_to_non_nullable
              as AptitudeResult?,
      currentResult: freezed == currentResult
          ? _value.currentResult
          : currentResult // ignore: cast_nullable_to_non_nullable
              as AptitudeResult?,
      hasPreviousResult: null == hasPreviousResult
          ? _value.hasPreviousResult
          : hasPreviousResult // ignore: cast_nullable_to_non_nullable
              as bool,
      allTypes: null == allTypes
          ? _value.allTypes
          : allTypes // ignore: cast_nullable_to_non_nullable
              as List<AptitudeTypeSummary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AptitudeStateImplCopyWith<$Res>
    implements $AptitudeStateCopyWith<$Res> {
  factory _$$AptitudeStateImplCopyWith(
          _$AptitudeStateImpl value, $Res Function(_$AptitudeStateImpl) then) =
      __$$AptitudeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? errorMessage,
      List<AptitudeQuestion> questions,
      Map<int, int> answers,
      AptitudeResult? myResult,
      AptitudeResult? currentResult,
      bool hasPreviousResult,
      List<AptitudeTypeSummary> allTypes});
}

/// @nodoc
class __$$AptitudeStateImplCopyWithImpl<$Res>
    extends _$AptitudeStateCopyWithImpl<$Res, _$AptitudeStateImpl>
    implements _$$AptitudeStateImplCopyWith<$Res> {
  __$$AptitudeStateImplCopyWithImpl(
      _$AptitudeStateImpl _value, $Res Function(_$AptitudeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AptitudeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? questions = null,
    Object? answers = null,
    Object? myResult = freezed,
    Object? currentResult = freezed,
    Object? hasPreviousResult = null,
    Object? allTypes = null,
  }) {
    return _then(_$AptitudeStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<AptitudeQuestion>,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      myResult: freezed == myResult
          ? _value.myResult
          : myResult // ignore: cast_nullable_to_non_nullable
              as AptitudeResult?,
      currentResult: freezed == currentResult
          ? _value.currentResult
          : currentResult // ignore: cast_nullable_to_non_nullable
              as AptitudeResult?,
      hasPreviousResult: null == hasPreviousResult
          ? _value.hasPreviousResult
          : hasPreviousResult // ignore: cast_nullable_to_non_nullable
              as bool,
      allTypes: null == allTypes
          ? _value._allTypes
          : allTypes // ignore: cast_nullable_to_non_nullable
              as List<AptitudeTypeSummary>,
    ));
  }
}

/// @nodoc

class _$AptitudeStateImpl extends _AptitudeState {
  const _$AptitudeStateImpl(
      {this.isLoading = false,
      this.errorMessage,
      final List<AptitudeQuestion> questions = const [],
      final Map<int, int> answers = const {},
      this.myResult,
      this.currentResult,
      this.hasPreviousResult = false,
      final List<AptitudeTypeSummary> allTypes = const []})
      : _questions = questions,
        _answers = answers,
        _allTypes = allTypes,
        super._();

  /// 로딩 중
  @override
  @JsonKey()
  final bool isLoading;

  /// 에러 메시지
  @override
  final String? errorMessage;

  /// 질문 목록
  final List<AptitudeQuestion> _questions;

  /// 질문 목록
  @override
  @JsonKey()
  List<AptitudeQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  /// 답변 맵 (questionId → value)
  final Map<int, int> _answers;

  /// 답변 맵 (questionId → value)
  @override
  @JsonKey()
  Map<int, int> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  /// 내 검사 결과 (마지막 저장된 결과)
  @override
  final AptitudeResult? myResult;

  /// 현재 보고 있는 결과 (상세 보기용)
  @override
  final AptitudeResult? currentResult;

  /// 이전 검사 결과 존재 여부
  @override
  @JsonKey()
  final bool hasPreviousResult;

  /// 모든 성향 타입 목록
  final List<AptitudeTypeSummary> _allTypes;

  /// 모든 성향 타입 목록
  @override
  @JsonKey()
  List<AptitudeTypeSummary> get allTypes {
    if (_allTypes is EqualUnmodifiableListView) return _allTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allTypes);
  }

  @override
  String toString() {
    return 'AptitudeState(isLoading: $isLoading, errorMessage: $errorMessage, questions: $questions, answers: $answers, myResult: $myResult, currentResult: $currentResult, hasPreviousResult: $hasPreviousResult, allTypes: $allTypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AptitudeStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.myResult, myResult) ||
                other.myResult == myResult) &&
            (identical(other.currentResult, currentResult) ||
                other.currentResult == currentResult) &&
            (identical(other.hasPreviousResult, hasPreviousResult) ||
                other.hasPreviousResult == hasPreviousResult) &&
            const DeepCollectionEquality().equals(other._allTypes, _allTypes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      errorMessage,
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_answers),
      myResult,
      currentResult,
      hasPreviousResult,
      const DeepCollectionEquality().hash(_allTypes));

  /// Create a copy of AptitudeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AptitudeStateImplCopyWith<_$AptitudeStateImpl> get copyWith =>
      __$$AptitudeStateImplCopyWithImpl<_$AptitudeStateImpl>(this, _$identity);
}

abstract class _AptitudeState extends AptitudeState {
  const factory _AptitudeState(
      {final bool isLoading,
      final String? errorMessage,
      final List<AptitudeQuestion> questions,
      final Map<int, int> answers,
      final AptitudeResult? myResult,
      final AptitudeResult? currentResult,
      final bool hasPreviousResult,
      final List<AptitudeTypeSummary> allTypes}) = _$AptitudeStateImpl;
  const _AptitudeState._() : super._();

  /// 로딩 중
  @override
  bool get isLoading;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// 질문 목록
  @override
  List<AptitudeQuestion> get questions;

  /// 답변 맵 (questionId → value)
  @override
  Map<int, int> get answers;

  /// 내 검사 결과 (마지막 저장된 결과)
  @override
  AptitudeResult? get myResult;

  /// 현재 보고 있는 결과 (상세 보기용)
  @override
  AptitudeResult? get currentResult;

  /// 이전 검사 결과 존재 여부
  @override
  bool get hasPreviousResult;

  /// 모든 성향 타입 목록
  @override
  List<AptitudeTypeSummary> get allTypes;

  /// Create a copy of AptitudeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AptitudeStateImplCopyWith<_$AptitudeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
