import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';

class TheoryScreen extends StatefulWidget {
  const TheoryScreen({super.key});

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  // PageView 컨트롤러
  final PageController _pageController = PageController();

  // 현재 페이지 인덱스
  int _currentPage = 0;

  // Mock 데이터 - 이론 페이지들
  final List<Map<String, dynamic>> _theoryPages = [
    {
      'page_no': 1,
      'content': '''
# 주식 투자의 기본 개념

## 주식이란?

주식(股式, Stock)은 주식회사가 자본을 조달하기 위해 발행하는 증권입니다. 주식을 구매한다는 것은 해당 회사의 일부를 소유하게 되는 것을 의미합니다.

### 주요 특징
• **소유권**: 회사의 일정 지분을 소유
• **배당권**: 회사 이익의 일부를 배당으로 받을 권리
• **의결권**: 주주총회에서 회사 경영에 참여할 권리
• **잔여재산분배권**: 회사 청산 시 남은 재산을 분배받을 권리

투자자는 주식을 통해 회사의 성장과 함께 수익을 얻을 수 있지만, 동시에 손실의 위험도 감수해야 합니다.
      ''',
    },
    {
      'page_no': 2,
      'content': '''
# 주식 시장의 구조

## 1차 시장 vs 2차 시장

### 1차 시장 (Primary Market)
- **IPO(기업공개)**: 회사가 처음으로 주식을 공개 발행
- **유상증자**: 기존 회사가 추가 자본 조달을 위해 신주 발행
- 투자자가 회사로부터 직접 주식을 구매

### 2차 시장 (Secondary Market)
- **거래소**: 코스피(KOSPI), 코스닥(KOSDAQ)
- **장외시장**: 거래소 밖에서 이루어지는 거래
- 투자자 간 주식 매매가 이루어지는 시장

## 주요 참여자
• **개인투자자**: 일반 개인들
• **기관투자자**: 은행, 보험회사, 연기금 등
• **외국인투자자**: 해외 투자자들
      ''',
    },
    {
      'page_no': 3,
      'content': '''
# 투자 전 준비사항

## 투자 목표 설정

### 1. 투자 기간 결정
• **단기투자**: 1년 이내 (높은 위험, 높은 수익 가능성)
• **중기투자**: 1-5년 (적정 위험, 안정적 수익)
• **장기투자**: 5년 이상 (낮은 위험, 복리 효과)

### 2. 위험 성향 파악
• **보수형**: 안정성을 중시하는 투자자
• **적극형**: 높은 수익을 위해 위험을 감수하는 투자자
• **중립형**: 적정한 위험과 수익을 추구하는 투자자

### 3. 투자 자금 준비
• **여유자금**: 당분간 사용하지 않을 돈으로 투자
• **비상자금**: 생활비 6개월분은 별도 보관
• **분산투자**: 한 번에 모든 자금을 투자하지 않기
      ''',
    },
    {
      'page_no': 4,
      'content': '''
# 기본적 분석 vs 기술적 분석

## 기본적 분석 (Fundamental Analysis)

### 정의
회사의 내재가치를 평가하여 주식의 적정 가격을 산출하는 분석 방법

### 주요 지표
• **PER(주가수익비율)**: 주가 ÷ 주당순이익
• **PBR(주가순자산비율)**: 주가 ÷ 주당순자산
• **ROE(자기자본이익률)**: 순이익 ÷ 자기자본
• **부채비율**: 부채 ÷ 자기자본

## 기술적 분석 (Technical Analysis)

### 정의
과거 주가와 거래량 데이터를 바탕으로 미래 주가를 예측하는 분석 방법

### 주요 도구
• **차트 패턴**: 헤드앤숄더, 삼각형 등
• **이동평균선**: 5일, 20일, 60일 이평선
• **보조지표**: RSI, MACD, 스토캐스틱
      ''',
    },
    {
      'page_no': 5,
      'content': '''
# 포트폴리오 구성과 리스크 관리

## 분산투자의 중요성

### "계란을 한 바구니에 담지 마라"
- 여러 종목에 투자하여 위험을 분산
- 업종별, 시가총액별, 지역별 분산
- 투자 시기도 분산 (적립식 투자)

## 포트폴리오 구성 예시

### 보수형 포트폴리오
• **대형주**: 60% (안정성 중시)
• **중소형주**: 20% (성장성 추구)
• **채권/현금**: 20% (안전자산)

### 적극형 포트폴리오
• **대형주**: 40%
• **중소형주**: 40%
• **성장주**: 15%
• **현금**: 5%

## 손절과 익절
• **손절**: 손실을 제한하기 위한 매도 (-10~20%)
• **익절**: 이익을 확정하기 위한 매도 (+20~30%)
• **감정적 판단 금지**: 미리 정한 규칙 준수
      ''',
    },
  ];

  // 총 페이지 수
  int get totalPages => _theoryPages.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 다음 페이지로 이동
  void _nextPage() {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 이전 페이지로 이동
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이론 학습'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.education),
        ),
      ),
      body: Column(
        children: [
          // 진행률 표시
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 페이지 번호 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '페이지 ${_currentPage + 1} / $totalPages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / totalPages * 100).toInt()}% 완료',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // 진행률 바
                LinearProgressIndicator(
                  value: (_currentPage + 1) / totalPages,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // 페이지 뷰
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: totalPages,
              itemBuilder: (context, index) {
                final page = _theoryPages[index];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 페이지 번호 뱃지
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Page ${page['page_no']}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // 콘텐츠
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildContentText(page['content']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 네비게이션 버튼
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 이전 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('이전'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.1),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // 다음 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentPage < totalPages - 1 ? _nextPage : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_currentPage < totalPages - 1 ? '다음' : '완료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 1),
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 1),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 마크다운 스타일 텍스트를 위젯으로 변환
  Widget _buildContentText(String content) {
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      // 제목 스타일 (# ## ###)
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
            child: Text(
              line.substring(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 1),
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, top: 16.h),
            child: Text(
              line.substring(3),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, top: 12.h),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        );
      }
      // 불릿 포인트 (•)
      else if (line.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // 일반 텍스트
      else {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              line,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
