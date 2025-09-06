import 'package:flutter/foundation.dart';
import 'tap_item.dart';

/// BottomNavigationBar의 탭 상태를 관리하는 Provider
class HomeNavigationProvider extends ChangeNotifier {
  TabItem _currentTab = TabItem.education;

  /// 현재 선택된 탭
  TabItem get currentTab => _currentTab;

  /// 현재 선택된 탭의 인덱스
  int get currentIndex => TabItem.values.indexOf(_currentTab);

  /// 탭을 변경하는 메서드
  void changeTab(TabItem tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
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
    return _currentTab == tab;
  }
}
