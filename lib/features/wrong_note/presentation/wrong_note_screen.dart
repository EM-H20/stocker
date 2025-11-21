import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/wrong_answer_card.dart';
import 'widgets/wrong_note_empty_state.dart';
import 'riverpod/wrong_note_notifier.dart';
import '../../quiz/presentation/riverpod/quiz_notifier.dart';
import '../../../app/config/app_theme.dart';
import '../../../app/core/utils/theme_utils.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../../../app/core/widgets/error_message_widget.dart';

/// 오답노트 메인 화면
///
/// 사용자가 틀린 퀴즈 문제들을 모아서 복습할 수 있는 화면입니다.
/// 챕터별로 분류되어 있으며, 다시 풀기 기능을 제공합니다.
class WrongNoteScreen extends ConsumerStatefulWidget {
  const WrongNoteScreen({super.key});

  @override
  ConsumerState<WrongNoteScreen> createState() => _WrongNoteScreenState();
}

class _WrongNoteScreenState extends ConsumerState<WrongNoteScreen>
    with WidgetsBindingObserver {
  bool _hasLoadedOnce = false; // 🎯 중복 로드 방지 플래그
  DateTime? _lastQuizCompletionTime; // 🕐 마지막 퀴즈 완료 시간 추적

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 화면 로드 시 오답노트 데이터 한 번만 로드 (중복 방지)
    debugPrint('📝 [WrongNote] Screen 초기화 - 오답노트 로드 시작');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadWrongNotesWithCheck();
        _hasLoadedOnce = true;
        debugPrint('📝 [WrongNote] initState에서 오답노트 로드 완료');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 🚨 ReadOnly 퀴즈 완료 직후에는 새로고침 방지 (무한루프 방지!)
    if (state == AppLifecycleState.resumed && mounted && _hasLoadedOnce) {
      final now = DateTime.now();
      // 🕐 마지막 퀴즈 완료 후 5초 이내에는 새로고침 안 함
      if (_lastQuizCompletionTime != null &&
          now.difference(_lastQuizCompletionTime!).inSeconds < 5) {
        debugPrint('🛡️ [WrongNote] 퀴즈 완료 직후 - 새로고침 건너뜀 (무한루프 방지)');
        return;
      }

      debugPrint('📱 [WrongNote] 앱 포어그라운드 복귀 - 오답노트 새로고침');
      _loadWrongNotesWithCheck();
    }
  }

  // didChangeDependencies에서 중복 호출 제거 - initState에서만 로드하도록 변경

  /// 🛡️ 안전한 오답노트 로드 (무한루프 방지 로직 포함)
  Future<void> _loadWrongNotesWithCheck() async {
    debugPrint('🔍 [WrongNote] 안전한 로드 시작');

    // 🚨 ReadOnly 모드에서 돌아온 직후인지 확인
    final quizState = ref.read(quizNotifierProvider);
    if (quizState.isReadOnlyMode) {
      debugPrint('🛡️ [WrongNote] ReadOnly 모드 활성 - 로드 스킵 (상태 안정화 대기)');
      return;
    }

    await ref.read(wrongNoteNotifierProvider.notifier).loadWrongNotes();
    debugPrint('✅ [WrongNote] 안전한 로드 완료');
  }

  /// 🕐 퀴즈 완료 시간 기록 (외부에서 호출 가능)
  void markQuizCompletion() {
    _lastQuizCompletionTime = DateTime.now();
    debugPrint('🕐 [WrongNote] 퀴즈 완료 시간 기록: $_lastQuizCompletionTime');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wrongNoteNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // 로딩 중일 때
            if (state.isLoading) {
              return const Center(
                child: LoadingWidget(
                  message: '오답노트를 불러오는 중...',
                ),
              );
            }

            // 에러가 있을 때
            if (state.hasError) {
              return ErrorMessageWidget.server(
                message: _getUserFriendlyErrorMessage(state.errorMessage),
                onRetry: () {
                  ref.read(wrongNoteNotifierProvider.notifier).clearError();
                  _loadWrongNotesWithCheck();
                },
              );
            }

            final wrongNotes = state.wrongNotes;

            // 오답노트가 비어있을 때
            if (wrongNotes.isEmpty) {
              return WrongNoteEmptyState(
                onGoToQuiz: () {
                  // 교육 탭으로 이동 (실제로는 Navigator나 context.go 사용)
                },
              );
            }

            // 정상적으로 데이터가 있을 때
            return Column(
              children: [
                // 커스텀 헤더
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '오답노트',
                        style: TextStyle(
                          color: ThemeUtils.getColorByTheme(
                            context,
                            lightColor: AppTheme.grey900,
                            darkColor: Colors.white,
                          ),
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${wrongNotes.length}개',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 💡 친절한 안내 배너
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.infoColor.withValues(alpha: 0.1),
                        AppTheme.successColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.infoColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.infoColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 복습용 문제는 여기서 계속 확인하세요!',
                              style: TextStyle(
                                color: ThemeUtils.getColorByTheme(
                                  context,
                                  lightColor: AppTheme.grey900,
                                  darkColor: Colors.white,
                                ),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '완전히 정리하려면 교육 → 해당 챕터 → 퀴즈풀기에서 정답을 맞춰주세요! 📚',
                              style: TextStyle(
                                color: ThemeUtils.getColorByTheme(
                                  context,
                                  lightColor: AppTheme.grey600,
                                  darkColor: AppTheme.grey300,
                                ),
                                fontSize: 12.sp,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 오답 목록
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: wrongNotes.length,
                    itemBuilder: (context, index) {
                      final wrongNote = wrongNotes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: WrongAnswerCard(
                          wrongNote: wrongNote,
                          isRetried:
                              state.retriedQuizIds.contains(wrongNote.quizId),
                          onRetry: () => ref
                              .read(wrongNoteNotifierProvider.notifier)
                              .markAsRetried(wrongNote.quizId),
                          onRemove: () => ref
                              .read(wrongNoteNotifierProvider.notifier)
                              .removeWrongNote(wrongNote.quizId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 사용자 친화적인 에러 메시지로 변환
  String _getUserFriendlyErrorMessage(String? errorMessage) {
    if (errorMessage == null) return '알 수 없는 오류가 발생했습니다.';

    if (errorMessage.contains('chapter_id는 필수입니다')) {
      return '챕터 정보를 불러올 수 없어요.\n잠시 후 다시 시도해주세요.';
    }

    if (errorMessage.contains('네트워크') || errorMessage.contains('연결')) {
      return '네트워크 연결을 확인해주세요.\n인터넷 연결 상태를 점검해보세요.';
    }

    if (errorMessage.contains('401') || errorMessage.contains('인증')) {
      return '로그인이 만료되었습니다.\n다시 로그인해주세요.';
    }

    if (errorMessage.contains('500') || errorMessage.contains('서버')) {
      return '서버에 일시적인 문제가 발생했어요.\n잠시 후 다시 시도해주세요.';
    }

    // 기본 메시지
    return '오답노트를 불러올 수 없어요.\n잠시 후 다시 시도해주세요.';
  }
}

/// 오답 아이템 모델
class WrongAnswerItem {
  final int id;
  final int chapterId;
  final String chapterTitle;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final String explanation;
  final DateTime wrongDate;
  bool isRetried;

  WrongAnswerItem({
    required this.id,
    required this.chapterId,
    required this.chapterTitle,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    required this.explanation,
    required this.wrongDate,
    this.isRetried = false,
  });
}
