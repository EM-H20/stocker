// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'education_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EducationState {
  /// 챕터 목록
  List<ChapterInfo> get chapters => throw _privateConstructorUsedError;

  /// 현재 이론 세션
  TheorySession? get currentTheorySession => throw _privateConstructorUsedError;

  /// 선택된 챕터 ID
  int? get selectedChapterId => throw _privateConstructorUsedError;

  /// 검색어 (실시간 검색용)
  String get searchQuery => throw _privateConstructorUsedError;

  /// 챕터 로딩 중
  bool get isLoadingChapters => throw _privateConstructorUsedError;

  /// 이론 로딩 중
  bool get isLoadingTheory => throw _privateConstructorUsedError;

  /// 진도 업데이트 중
  bool get isUpdatingProgress => throw _privateConstructorUsedError;

  /// 이론 완료 처리 중
  bool get isCompletingTheory => throw _privateConstructorUsedError;

  /// 챕터 에러 메시지
  String? get chaptersError => throw _privateConstructorUsedError;

  /// 이론 에러 메시지
  String? get theoryError => throw _privateConstructorUsedError;

  /// Create a copy of EducationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducationStateCopyWith<EducationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducationStateCopyWith<$Res> {
  factory $EducationStateCopyWith(
          EducationState value, $Res Function(EducationState) then) =
      _$EducationStateCopyWithImpl<$Res, EducationState>;
  @useResult
  $Res call(
      {List<ChapterInfo> chapters,
      TheorySession? currentTheorySession,
      int? selectedChapterId,
      String searchQuery,
      bool isLoadingChapters,
      bool isLoadingTheory,
      bool isUpdatingProgress,
      bool isCompletingTheory,
      String? chaptersError,
      String? theoryError});
}

/// @nodoc
class _$EducationStateCopyWithImpl<$Res, $Val extends EducationState>
    implements $EducationStateCopyWith<$Res> {
  _$EducationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EducationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapters = null,
    Object? currentTheorySession = freezed,
    Object? selectedChapterId = freezed,
    Object? searchQuery = null,
    Object? isLoadingChapters = null,
    Object? isLoadingTheory = null,
    Object? isUpdatingProgress = null,
    Object? isCompletingTheory = null,
    Object? chaptersError = freezed,
    Object? theoryError = freezed,
  }) {
    return _then(_value.copyWith(
      chapters: null == chapters
          ? _value.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<ChapterInfo>,
      currentTheorySession: freezed == currentTheorySession
          ? _value.currentTheorySession
          : currentTheorySession // ignore: cast_nullable_to_non_nullable
              as TheorySession?,
      selectedChapterId: freezed == selectedChapterId
          ? _value.selectedChapterId
          : selectedChapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isLoadingChapters: null == isLoadingChapters
          ? _value.isLoadingChapters
          : isLoadingChapters // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTheory: null == isLoadingTheory
          ? _value.isLoadingTheory
          : isLoadingTheory // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingProgress: null == isUpdatingProgress
          ? _value.isUpdatingProgress
          : isUpdatingProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompletingTheory: null == isCompletingTheory
          ? _value.isCompletingTheory
          : isCompletingTheory // ignore: cast_nullable_to_non_nullable
              as bool,
      chaptersError: freezed == chaptersError
          ? _value.chaptersError
          : chaptersError // ignore: cast_nullable_to_non_nullable
              as String?,
      theoryError: freezed == theoryError
          ? _value.theoryError
          : theoryError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EducationStateImplCopyWith<$Res>
    implements $EducationStateCopyWith<$Res> {
  factory _$$EducationStateImplCopyWith(_$EducationStateImpl value,
          $Res Function(_$EducationStateImpl) then) =
      __$$EducationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ChapterInfo> chapters,
      TheorySession? currentTheorySession,
      int? selectedChapterId,
      String searchQuery,
      bool isLoadingChapters,
      bool isLoadingTheory,
      bool isUpdatingProgress,
      bool isCompletingTheory,
      String? chaptersError,
      String? theoryError});
}

/// @nodoc
class __$$EducationStateImplCopyWithImpl<$Res>
    extends _$EducationStateCopyWithImpl<$Res, _$EducationStateImpl>
    implements _$$EducationStateImplCopyWith<$Res> {
  __$$EducationStateImplCopyWithImpl(
      _$EducationStateImpl _value, $Res Function(_$EducationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EducationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapters = null,
    Object? currentTheorySession = freezed,
    Object? selectedChapterId = freezed,
    Object? searchQuery = null,
    Object? isLoadingChapters = null,
    Object? isLoadingTheory = null,
    Object? isUpdatingProgress = null,
    Object? isCompletingTheory = null,
    Object? chaptersError = freezed,
    Object? theoryError = freezed,
  }) {
    return _then(_$EducationStateImpl(
      chapters: null == chapters
          ? _value._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<ChapterInfo>,
      currentTheorySession: freezed == currentTheorySession
          ? _value.currentTheorySession
          : currentTheorySession // ignore: cast_nullable_to_non_nullable
              as TheorySession?,
      selectedChapterId: freezed == selectedChapterId
          ? _value.selectedChapterId
          : selectedChapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isLoadingChapters: null == isLoadingChapters
          ? _value.isLoadingChapters
          : isLoadingChapters // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingTheory: null == isLoadingTheory
          ? _value.isLoadingTheory
          : isLoadingTheory // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingProgress: null == isUpdatingProgress
          ? _value.isUpdatingProgress
          : isUpdatingProgress // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompletingTheory: null == isCompletingTheory
          ? _value.isCompletingTheory
          : isCompletingTheory // ignore: cast_nullable_to_non_nullable
              as bool,
      chaptersError: freezed == chaptersError
          ? _value.chaptersError
          : chaptersError // ignore: cast_nullable_to_non_nullable
              as String?,
      theoryError: freezed == theoryError
          ? _value.theoryError
          : theoryError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$EducationStateImpl extends _EducationState {
  const _$EducationStateImpl(
      {final List<ChapterInfo> chapters = const [],
      this.currentTheorySession,
      this.selectedChapterId,
      this.searchQuery = '',
      this.isLoadingChapters = false,
      this.isLoadingTheory = false,
      this.isUpdatingProgress = false,
      this.isCompletingTheory = false,
      this.chaptersError,
      this.theoryError})
      : _chapters = chapters,
        super._();

  /// 챕터 목록
  final List<ChapterInfo> _chapters;

  /// 챕터 목록
  @override
  @JsonKey()
  List<ChapterInfo> get chapters {
    if (_chapters is EqualUnmodifiableListView) return _chapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chapters);
  }

  /// 현재 이론 세션
  @override
  final TheorySession? currentTheorySession;

  /// 선택된 챕터 ID
  @override
  final int? selectedChapterId;

  /// 검색어 (실시간 검색용)
  @override
  @JsonKey()
  final String searchQuery;

  /// 챕터 로딩 중
  @override
  @JsonKey()
  final bool isLoadingChapters;

  /// 이론 로딩 중
  @override
  @JsonKey()
  final bool isLoadingTheory;

  /// 진도 업데이트 중
  @override
  @JsonKey()
  final bool isUpdatingProgress;

  /// 이론 완료 처리 중
  @override
  @JsonKey()
  final bool isCompletingTheory;

  /// 챕터 에러 메시지
  @override
  final String? chaptersError;

  /// 이론 에러 메시지
  @override
  final String? theoryError;

  @override
  String toString() {
    return 'EducationState(chapters: $chapters, currentTheorySession: $currentTheorySession, selectedChapterId: $selectedChapterId, searchQuery: $searchQuery, isLoadingChapters: $isLoadingChapters, isLoadingTheory: $isLoadingTheory, isUpdatingProgress: $isUpdatingProgress, isCompletingTheory: $isCompletingTheory, chaptersError: $chaptersError, theoryError: $theoryError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducationStateImpl &&
            const DeepCollectionEquality().equals(other._chapters, _chapters) &&
            (identical(other.currentTheorySession, currentTheorySession) ||
                other.currentTheorySession == currentTheorySession) &&
            (identical(other.selectedChapterId, selectedChapterId) ||
                other.selectedChapterId == selectedChapterId) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.isLoadingChapters, isLoadingChapters) ||
                other.isLoadingChapters == isLoadingChapters) &&
            (identical(other.isLoadingTheory, isLoadingTheory) ||
                other.isLoadingTheory == isLoadingTheory) &&
            (identical(other.isUpdatingProgress, isUpdatingProgress) ||
                other.isUpdatingProgress == isUpdatingProgress) &&
            (identical(other.isCompletingTheory, isCompletingTheory) ||
                other.isCompletingTheory == isCompletingTheory) &&
            (identical(other.chaptersError, chaptersError) ||
                other.chaptersError == chaptersError) &&
            (identical(other.theoryError, theoryError) ||
                other.theoryError == theoryError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_chapters),
      currentTheorySession,
      selectedChapterId,
      searchQuery,
      isLoadingChapters,
      isLoadingTheory,
      isUpdatingProgress,
      isCompletingTheory,
      chaptersError,
      theoryError);

  /// Create a copy of EducationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducationStateImplCopyWith<_$EducationStateImpl> get copyWith =>
      __$$EducationStateImplCopyWithImpl<_$EducationStateImpl>(
          this, _$identity);
}

abstract class _EducationState extends EducationState {
  const factory _EducationState(
      {final List<ChapterInfo> chapters,
      final TheorySession? currentTheorySession,
      final int? selectedChapterId,
      final String searchQuery,
      final bool isLoadingChapters,
      final bool isLoadingTheory,
      final bool isUpdatingProgress,
      final bool isCompletingTheory,
      final String? chaptersError,
      final String? theoryError}) = _$EducationStateImpl;
  const _EducationState._() : super._();

  /// 챕터 목록
  @override
  List<ChapterInfo> get chapters;

  /// 현재 이론 세션
  @override
  TheorySession? get currentTheorySession;

  /// 선택된 챕터 ID
  @override
  int? get selectedChapterId;

  /// 검색어 (실시간 검색용)
  @override
  String get searchQuery;

  /// 챕터 로딩 중
  @override
  bool get isLoadingChapters;

  /// 이론 로딩 중
  @override
  bool get isLoadingTheory;

  /// 진도 업데이트 중
  @override
  bool get isUpdatingProgress;

  /// 이론 완료 처리 중
  @override
  bool get isCompletingTheory;

  /// 챕터 에러 메시지
  @override
  String? get chaptersError;

  /// 이론 에러 메시지
  @override
  String? get theoryError;

  /// Create a copy of EducationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducationStateImplCopyWith<_$EducationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
