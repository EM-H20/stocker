// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeModeHash() => r'14266417f6880d2fa56044608ed5147abe0545d5';

/// 🎨 ThemeMode 변환을 위한 Provider
///
/// Copied from [themeMode].
@ProviderFor(themeMode)
final themeModeProvider = AutoDisposeProvider<ThemeMode>.internal(
  themeMode,
  name: r'themeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeRef = AutoDisposeProviderRef<ThemeMode>;
String _$isDarkModeHash() => r'dc7a52543f2cb6d0e7f215696ff15314413f1ab9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
/// 사용법: ref.watch(isDarkModeProvider(context))
///
/// Copied from [isDarkMode].
@ProviderFor(isDarkMode)
const isDarkModeProvider = IsDarkModeFamily();

/// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
/// 사용법: ref.watch(isDarkModeProvider(context))
///
/// Copied from [isDarkMode].
class IsDarkModeFamily extends Family<bool> {
  /// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
  /// 사용법: ref.watch(isDarkModeProvider(context))
  ///
  /// Copied from [isDarkMode].
  const IsDarkModeFamily();

  /// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
  /// 사용법: ref.watch(isDarkModeProvider(context))
  ///
  /// Copied from [isDarkMode].
  IsDarkModeProvider call(
    BuildContext context,
  ) {
    return IsDarkModeProvider(
      context,
    );
  }

  @override
  IsDarkModeProvider getProviderOverride(
    covariant IsDarkModeProvider provider,
  ) {
    return call(
      provider.context,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isDarkModeProvider';
}

/// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
/// 사용법: ref.watch(isDarkModeProvider(context))
///
/// Copied from [isDarkMode].
class IsDarkModeProvider extends AutoDisposeProvider<bool> {
  /// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
  /// 사용법: ref.watch(isDarkModeProvider(context))
  ///
  /// Copied from [isDarkMode].
  IsDarkModeProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => isDarkMode(
            ref as IsDarkModeRef,
            context,
          ),
          from: isDarkModeProvider,
          name: r'isDarkModeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isDarkModeHash,
          dependencies: IsDarkModeFamily._dependencies,
          allTransitiveDependencies:
              IsDarkModeFamily._allTransitiveDependencies,
          context: context,
        );

  IsDarkModeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(IsDarkModeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsDarkModeProvider._internal(
        (ref) => create(ref as IsDarkModeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsDarkModeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDarkModeProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsDarkModeRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _IsDarkModeProviderElement extends AutoDisposeProviderElement<bool>
    with IsDarkModeRef {
  _IsDarkModeProviderElement(super.provider);

  @override
  BuildContext get context => (origin as IsDarkModeProvider).context;
}

String _$themeNotifierHash() => r'113e4f3c524bba641ac2996a4ed929bb4cb32294';

/// 🔥 Riverpod 기반 테마 상태 관리 Notifier
///
/// Copied from [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeNotifier, AppThemeMode>.internal(
  ThemeNotifier.new,
  name: r'themeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeNotifier = AutoDisposeNotifier<AppThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
