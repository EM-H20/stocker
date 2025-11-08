// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  /// 현재 로그인된 사용자 정보
  User? get user => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 로딩 상태 (로그인, 회원가입 등)
  bool get isLoading => throw _privateConstructorUsedError;

  /// 초기화 중 상태 (앱 시작 시 토큰 확인)
  bool get isInitializing => throw _privateConstructorUsedError;

  /// 프로필 업데이트 중 상태
  bool get isUpdatingProfile => throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call(
      {User? user,
      String? errorMessage,
      bool isLoading,
      bool isInitializing,
      bool isUpdatingProfile});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? errorMessage = freezed,
    Object? isLoading = null,
    Object? isInitializing = null,
    Object? isUpdatingProfile = null,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _value.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingProfile: null == isUpdatingProfile
          ? _value.isUpdatingProfile
          : isUpdatingProfile // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {User? user,
      String? errorMessage,
      bool isLoading,
      bool isInitializing,
      bool isUpdatingProfile});
}

/// @nodoc
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? errorMessage = freezed,
    Object? isLoading = null,
    Object? isInitializing = null,
    Object? isUpdatingProfile = null,
  }) {
    return _then(_$AuthStateImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitializing: null == isInitializing
          ? _value.isInitializing
          : isInitializing // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdatingProfile: null == isUpdatingProfile
          ? _value.isUpdatingProfile
          : isUpdatingProfile // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
      {this.user,
      this.errorMessage,
      this.isLoading = false,
      this.isInitializing = true,
      this.isUpdatingProfile = false})
      : super._();

  /// 현재 로그인된 사용자 정보
  @override
  final User? user;

  /// 에러 메시지
  @override
  final String? errorMessage;

  /// 로딩 상태 (로그인, 회원가입 등)
  @override
  @JsonKey()
  final bool isLoading;

  /// 초기화 중 상태 (앱 시작 시 토큰 확인)
  @override
  @JsonKey()
  final bool isInitializing;

  /// 프로필 업데이트 중 상태
  @override
  @JsonKey()
  final bool isUpdatingProfile;

  @override
  String toString() {
    return 'AuthState(user: $user, errorMessage: $errorMessage, isLoading: $isLoading, isInitializing: $isInitializing, isUpdatingProfile: $isUpdatingProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitializing, isInitializing) ||
                other.isInitializing == isInitializing) &&
            (identical(other.isUpdatingProfile, isUpdatingProfile) ||
                other.isUpdatingProfile == isUpdatingProfile));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, errorMessage, isLoading,
      isInitializing, isUpdatingProfile);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {final User? user,
      final String? errorMessage,
      final bool isLoading,
      final bool isInitializing,
      final bool isUpdatingProfile}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  /// 현재 로그인된 사용자 정보
  @override
  User? get user;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// 로딩 상태 (로그인, 회원가입 등)
  @override
  bool get isLoading;

  /// 초기화 중 상태 (앱 시작 시 토큰 확인)
  @override
  bool get isInitializing;

  /// 프로필 업데이트 중 상태
  @override
  bool get isUpdatingProfile;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
