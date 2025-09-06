import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'widgets/wrong_answer_card.dart';
import 'widgets/wrong_note_empty_state.dart';
import 'wrong_note_provider.dart';
import '../../../app/config/app_theme.dart';

/// 오답노트 메인 화면
///
/// 사용자가 틀린 퀴즈 문제들을 모아서 복습할 수 있는 화면입니다.
/// 챕터별로 분류되어 있으며, 다시 풀기 기능을 제공합니다.
class WrongNoteScreen extends StatefulWidget {
  const WrongNoteScreen({super.key});

  @override
  State<WrongNoteScreen> createState() => _WrongNoteScreenState();
}

class _WrongNoteScreenState extends State<WrongNoteScreen> 
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 화면 로드 시 오답노트 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WrongNoteProvider>().loadWrongNotes();
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
    // 앱이 포어그라운드로 돌아올 때 새로고침
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<WrongNoteProvider>().loadWrongNotes();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면에 다시 돌아올 때마다 새로고침 (go_router에서 유용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WrongNoteProvider>().loadWrongNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<WrongNoteProvider>(
          builder: (context, provider, child) {
            // 로딩 중일 때
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryColor),
                    SizedBox(height: 16.h),
                    Text(
                      '오답노트를 불러오는 중...',
                      style: TextStyle(
                        color: AppTheme.grey600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 에러가 있을 때
            if (provider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _getUserFriendlyErrorMessage(provider.errorMessage),
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.loadWrongNotes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(
                        '다시 시도',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final wrongNotes = provider.wrongNotes;

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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.grey900,
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
                          isRetried: provider.retriedQuizIds
                              .contains(wrongNote.quizId),
                          onRetry: () =>
                              provider.markAsRetried(wrongNote.quizId),
                          onRemove: () =>
                              provider.removeWrongNote(wrongNote.quizId),
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
