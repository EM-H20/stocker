import 'package:flutter/foundation.dart';
import 'models/chapter_info.dart';
import 'models/theory_info.dart';
import 'models/theory_session.dart';

/// 교육 기능 Mock Repository
/// UI 개발 및 테스트용 더미 데이터 제공
class EducationMockRepository {
  /// 더미 챕터 목록 조회
  ///
  /// 사용자별 챕터 진행 상황과 함께 더미 데이터 반환
  Future<List<ChapterInfo>> getChaptersForUser() async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const ChapterInfo(
        id: 1,
        title: '주식 기초 이론',
        isTheoryCompleted: false,
        isQuizCompleted: false,
      ),
      const ChapterInfo(
        id: 2,
        title: '기술적 분석 입문',
        isTheoryCompleted: false,
        isQuizCompleted: false,
      ),
      const ChapterInfo(
        id: 3,
        title: '재무제표 분석',
        isTheoryCompleted: true,
        isQuizCompleted: true,
      ),
      const ChapterInfo(
        id: 4,
        title: '포트폴리오 관리',
        isTheoryCompleted: false,
        isQuizCompleted: false,
      ),
    ];
  }

  /// 더미 이론 세션 시작
  ///
  /// 특정 챕터의 이론 학습 세션 시작 시뮬레이션
  Future<TheorySession> enterTheory(int chapterId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 챕터별 더미 이론 데이터
    final theories = _getTheoriesForChapter(chapterId);
    
    return TheorySession(
      chapterId: chapterId,
      chapterTitle: '챕터 $chapterId',
      theories: theories,
      currentTheoryIndex: 0,
    );
  }

  /// 더미 이론 진도 업데이트
  ///
  /// 이론 학습 진도 업데이트 시뮬레이션
  Future<void> updateTheoryProgress(
    int chapterId,
    int theoryIndex,
    double progressPercentage,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    debugPrint('Mock: 이론 진도 업데이트 - 챕터: $chapterId, 이론: $theoryIndex, 진도: $progressPercentage%');
  }

  /// 더미 이론 완료
  ///
  /// 특정 이론 완료 처리 시뮬레이션
  Future<void> completeTheory(int chapterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    debugPrint('Mock: 이론 완료 - 챕터: $chapterId');
  }

  /// 챕터별 더미 이론 데이터 생성
  List<TheoryInfo> _getTheoriesForChapter(int chapterId) {
    switch (chapterId) {
      case 1:
        return [
          const TheoryInfo(
            id: 1,
            word: '주식이란 무엇인가?',
            content: '''
# 주식의 기본 개념

주식(Stock)은 기업의 소유권을 나타내는 증권입니다. 주식을 보유한다는 것은 해당 기업의 일부를 소유한다는 의미입니다.

## 주요 특징

### 1. 소유권
- 주주는 기업의 소유자 중 한 명
- 의결권을 통해 기업 경영에 참여 가능
- 배당금 수령 권리

### 2. 수익성
- **자본 이득**: 주가 상승으로 인한 수익
- **배당 수익**: 기업이 지급하는 배당금

### 3. 위험성
- 주가 변동에 따른 손실 가능성
- 기업 파산 시 투자금 손실 위험

주식 투자를 시작하기 전에 충분한 학습과 준비가 필요합니다.
            ''',
          ),
          const TheoryInfo(
            id: 2,
            word: '주식 시장의 구조',
            content: '''
# 주식 시장의 구조

주식 시장은 주식의 발행과 거래가 이루어지는 시장입니다.

## 시장의 분류

### 1. 발행 시장 (Primary Market)
- 기업이 새로운 주식을 발행하는 시장
- IPO(Initial Public Offering) 진행
- 자금 조달 목적

### 2. 유통 시장 (Secondary Market)
- 이미 발행된 주식이 거래되는 시장
- 투자자 간 매매 거래
- 가격 발견 기능

시장의 구조를 이해하면 더 효과적인 투자가 가능합니다.
            ''',
          ),
          const TheoryInfo(
            id: 3,
            word: '주식 투자 용어',
            content: '''
# 주식 투자 필수 용어

주식 투자를 위해 반드시 알아야 할 기본 용어들을 정리했습니다.

## 기본 용어

### 주가 관련
- **시가**: 장 시작 시 첫 거래 가격
- **고가**: 하루 중 가장 높은 가격
- **저가**: 하루 중 가장 낮은 가격
- **종가**: 장 마감 시 마지막 거래 가격

용어를 정확히 이해하고 사용하는 것이 성공적인 투자의 첫걸음입니다.
            ''',
          ),
        ];
      case 2:
        return [
          const TheoryInfo(
            id: 6,
            word: '차트의 기본 이해',
            content: '''
# 차트의 기본 이해

기술적 분석의 첫걸음은 차트를 올바르게 읽는 것입니다.

## 차트의 종류

### 1. 선 차트 (Line Chart)
- 종가만을 연결한 단순한 차트
- 전체적인 추세 파악에 유용

### 2. 캔들스틱 차트 (Candlestick Chart)
- 일본에서 개발된 차트 방식
- 시각적으로 직관적
- 가장 널리 사용됨

차트 분석은 과거 데이터를 바탕으로 하므로, 다른 지표와 함께 종합적으로 판단해야 합니다.
            ''',
          ),
        ];
      default:
        return [
          TheoryInfo(
            id: 100 + chapterId,
            word: '챕터 $chapterId 기본 이론',
            content: '''
# 챕터 $chapterId 기본 이론

이것은 챕터 $chapterId의 기본 이론 내용입니다.

## 학습 목표
- 기본 개념 이해
- 실무 적용 방법 학습
- 투자 전략 수립

더 자세한 내용은 실제 서비스에서 제공됩니다.
            ''',
          ),
        ];
    }
  }
}
