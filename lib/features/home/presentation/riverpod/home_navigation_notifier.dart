import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../tap_item.dart';

part 'home_navigation_notifier.g.dart';

/// 🔥 Riverpod 기반 홈 내비게이션 상태 관리 Notifier
/// BottomNavigationBar의 탭 상태를 관리합니다
@riverpod
class HomeNavigationNotifier extends _$HomeNavigationNotifier {
  @override
  TabItem build() {
    return TabItem.education; // 기본 탭: 교육
  }

  /// 탭을 변경하는 메서드
  void changeTab(TabItem tab) {
    if (state != tab) {
      state = tab; // 🔥 Riverpod: state 직접 할당 (자동 notifyListeners!)
    }
  }

  /// 인덱스로 탭을 변경하는 메서드
  void changeTabByIndex(int index) {
    if (index >= 0 && index < TabItem.values.length) {
      final newTab = TabItem.values[index];
      changeTab(newTab);
    }
  }

  /// 특정 탭이 현재 선택되어 있는지 확인
  bool isCurrentTab(TabItem tab) {
    return state == tab;
  }

  /// 현재 선택된 탭의 인덱스
  int get currentIndex => TabItem.values.indexOf(state);
}
