import 'package:flutter/material.dart';

/// BottomNavigationBar에서 사용할 탭 아이템 정의
enum TabItem {
  education,
  attendance,
  aptitude,
  wrongNote,
  mypage;

  /// 탭 아이템의 라벨 반환
  String get label {
    switch (this) {
      case TabItem.education:
        return '교육';
      case TabItem.attendance:
        return '출석';
      case TabItem.aptitude:
        return '성향분석';
      case TabItem.wrongNote:
        return '오답노트';
      case TabItem.mypage:
        return '마이페이지';
    }
  }

  /// 탭 아이템의 아이콘 반환
  IconData get icon {
    switch (this) {
      case TabItem.education:
        return Icons.school;
      case TabItem.attendance:
        return Icons.calendar_today;
      case TabItem.aptitude:
        return Icons.psychology;
      case TabItem.wrongNote:
        return Icons.note_alt;
      case TabItem.mypage:
        return Icons.person;
    }
  }

  /// 탭 아이템의 선택된 아이콘 반환
  IconData get selectedIcon {
    switch (this) {
      case TabItem.education:
        return Icons.school_outlined;
      case TabItem.attendance:
        return Icons.calendar_today_outlined;
      case TabItem.aptitude:
        return Icons.psychology_outlined;
      case TabItem.wrongNote:
        return Icons.note_alt_outlined;
      case TabItem.mypage:
        return Icons.person_outline;
    }
  }
}