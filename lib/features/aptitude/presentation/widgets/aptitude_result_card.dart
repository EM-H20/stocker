import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../app/config/app_routes.dart';
import '../riverpod/aptitude_notifier.dart';
import '../widgets/quiz_option_button.dart';

/// 24개의 성향 분석 질문에 답변하는 화면
class AptitudeQuizScreen extends ConsumerStatefulWidget {
  const AptitudeQuizScreen({super.key});

  @override
  ConsumerState<AptitudeQuizScreen> createState() =>
      _AptitudeQuizScreenState();
}

class _AptitudeQuizScreenState extends ConsumerState<AptitudeQuizScreen> {
  // 여러 페이지의 질문을 관리하기 위한 PageController
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드된 후, Riverpod Notifier를 통해 검사 질문지를 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aptitudeNotifierProvider.notifier).startTest();
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // 위젯이 사라질 때 컨트롤러 리소스 해제
    super.dispose();
  }

  /// 결과 제출 로직
  Future<void> _submit() async {
    final notifier = ref.read(aptitudeNotifierProvider.notifier);
    final success = await notifier.submitAnswers();

    if (mounted && success) {
      // pushReplacement를 사용하여 뒤로가기 시 퀴즈 화면으로 돌아오지 않도록 함
      context.pushReplacement(AppRoutes.aptitudeResult);
    } else if (mounted) {
      // 실패 시 에러 메시지 표시
      final errorMessage = ref.read(aptitudeNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? '결과 제출에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Riverpod: ref.watch로 상태 구독
    final aptitudeState = ref.watch(aptitudeNotifierProvider);
    final questions = aptitudeState.questions;
    final totalQuestions = questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 성향 분석'),
      ),
      body: aptitudeState.isLoading && questions.isEmpty
          ? const Center(
              child: LoadingWidget(
              message: '퀴즈를 불러오는 중...',
            ))
          : Column(
              children: [
                // 1. 진행률 표시 바
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearPercentIndicator(
                    percent: totalQuestions > 0
                        ? (aptitudeState.answers.length / totalQuestions)
                        : 0,
                    lineHeight: 12.0,
                    center: Text(
                      '${aptitudeState.answers.length} / $totalQuestions',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.grey[300],
                    progressColor: Theme.of(context).primaryColor,
                    barRadius: const Radius.circular(6),
                  ),
                ),
                // 2. 질문 페이지 뷰
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // 사용자가 직접 스와이프하는 것 방지
                    itemCount: totalQuestions,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 질문 텍스트
                            Text(
                              'Q${index + 1}. ${question.text}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.5, // 줄 간격
                              ),
                            ),
                            const SizedBox(height: 48),
                            // 답변 선택지 목록
                            ...question.choices.map((choice) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: QuizOptionButton(
                                  text: choice.text,
                                  isSelected: aptitudeState
                                          .answers[question.id] ==
                                      choice.value,
                                  onPressed: () {
                                    // 답변을 Notifier에 저장
                                    ref
                                        .read(aptitudeNotifierProvider.notifier)
                                        .answerQuestion(
                                            question.id, choice.value);

                                    // 마지막 문제가 아니면 다음 페이지로 자동 이동
                                    if (index < totalQuestions - 1) {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // 3. 결과 제출 버튼 (모든 질문에 답했을 때만 활성화)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: (aptitudeState.answers.length ==
                                totalQuestions &&
                            totalQuestions > 0)
                        ? _submit
                        : null, // 모든 질문에 답하지 않으면 버튼 비활성화
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: aptitudeState.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.0)
                        : const Text('결과 분석하기',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
