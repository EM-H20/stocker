import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../learning/presentation/provider/learning_progress_provider.dart';
import '../../../education/presentation/education_provider.dart';
import '../../../auth/presentation/auth_provider.dart';

/// 🎯 "이어서 학습하기" 위젯
///
/// 넷플릭스의 "계속 시청하기"처럼 사용자가 마지막으로 학습한 지점부터
/// 바로 이어갈 수 있도록 도와주는 핵심 위젯
class ContinueLearningWidget extends StatelessWidget {
  const ContinueLearningWidget({super.key});

  // Provider에서 데이터를 가져오므로 더 이상 매개변수 불필요

  @override
  Widget build(BuildContext context) {
    return Consumer3<LearningProgressProvider, EducationProvider, AuthProvider>(
      builder:
          (context, progressProvider, educationProvider, authProvider, child) {
        // 🔐 로그인 상태 체크 - 가장 먼저 확인
        if (!authProvider.isLoggedIn) {
          return _buildLoginRequiredUI(context);
        }

        if (!progressProvider.isInitialized) {
          // 로딩 중일 때 스켈레톤 UI
          return _buildLoadingSkeleton(context);
        }

        // 🚨 Education API 에러 상태 처리
        if (educationProvider.chaptersError != null &&
            educationProvider.isAuthenticationError) {
          // 인증 에러인 경우는 이미 위에서 처리되므로 여기는 다른 에러들
          debugPrint('🔐 [CONTINUE_LEARNING] 인증 에러로 로그인 필요 UI 표시');
          return _buildLoginRequiredUI(context);
        }

        final lastChapterId = progressProvider.lastChapterId;
        final lastStep = progressProvider.lastStep;
        final progress = progressProvider.getCurrentChapterProgress();

        // ✅ Repository 패턴으로 실제 데이터 사용
        final chapterTitle = authProvider.isLoggedIn
            ? progressProvider.getChapterTitle(lastChapterId)
            : '로그인 후 이용 가능';

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎬 상단 헤더
              _buildHeader(),

              SizedBox(height: 16.h),

              // 📊 진도 정보
              _buildProgressInfo(
                  context, lastChapterId, lastStep, progress, chapterTitle),

              SizedBox(height: 20.h),

              // 🚀 액션 버튼들
              _buildActionButtons(
                  context, authProvider, lastChapterId, lastStep),
            ],
          ),
        );
      },
    );
  }

  /// 🔐 로그인 필요 UI
  Widget _buildLoginRequiredUI(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
            Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔒 헤더
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '학습을 시작해보세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 📝 안내 메시지
          Text(
            '로그인하면 개인 맞춤 학습을 시작할 수 있어요!\n진도를 저장하고 퀴즈에 도전해보세요.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 20.h),

          // 🚀 로그인 버튼
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: '로그인하고 학습 시작',
                  icon: Icons.login_rounded,
                  color: Colors.white,
                  width: double.infinity,
                  height: 44.h,
                  onPressed: () {
                    debugPrint('🚀 [CONTINUE_LEARNING] 비로그인 상태에서 로그인 페이지로 이동');
                    context.go(AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      height: 200.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스켈레톤 헤더
          Container(
            width: 150.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          // 스켈레톤 진도바
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 20.h),
          // 스켈레톤 버튼
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 🎯 아이콘
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 24.sp,
          ),
        ),

        SizedBox(width: 12.w),

        // 📝 텍스트
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이어서 학습하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '마지막으로 학습한 곳부터 계속해요! 🚀',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(BuildContext context, int lastChapterId,
      String lastStep, double progress, String chapterTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📚 챕터 정보
        Row(
          children: [
            Text(
              'Chapter $lastChapterId',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _getStepLabel(lastStep),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // 📖 챕터 제목
        Text(
          chapterTitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
          ),
        ),

        SizedBox(height: 12.h),

        // 📊 진도 바
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행률',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider,
      int lastChapterId, String lastStep) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // 🚀 계속하기 버튼 (메인) - ActionButton 사용
        Expanded(
          flex: 2,
          child: ActionButton(
            text: '계속하기',
            icon: Icons.play_arrow_rounded,
            color: Colors.white,
            width: double.infinity,
            height: 44.h,
            onPressed: () => _handleContinueLearning(
                context, authProvider, lastChapterId, lastStep),
          ),
        ),

        SizedBox(width: 12.w),

        // 📚 전체보기 버튼 - ActionButton 사용
        Expanded(
          flex: 1,
          child: ActionButton(
            text: '전체보기',
            icon: Icons.list_rounded,
            color: theme.brightness == Brightness.dark
                ? AppTheme.successColor
                : AppTheme.successColor,
            width: double.infinity,
            height: 44.h,
            onPressed: () => _handleViewAll(context, authProvider),
          ),
        ),
      ],
    );
  }

  String _getStepLabel(String step) {
    switch (step) {
      case 'theory':
        return '📖 이론';
      case 'quiz':
        return '🎯 퀴즈';
      case 'result':
        return '📊 결과';
      default:
        return '📚 학습';
    }
  }

  // 🔗 실제 데이터는 이제 LearningProgressProvider의 Repository 패턴을 통해 자동으로 처리됨

  /// 🔐 "계속하기" 버튼 처리 (로그인 체크 포함)
  void _handleContinueLearning(BuildContext context, AuthProvider authProvider,
      int lastChapterId, String lastStep) {
    if (authProvider.isLoggedIn) {
      // 로그인된 경우: 실제 존재하는 Education 경로로 이동
      debugPrint(
          '✅ [CONTINUE_LEARNING] 로그인 상태 확인됨 - Chapter $lastChapterId ($lastStep)으로 이동');

      // 🔧 실제 존재하는 라우트로 이동 (레거시 경로 사용)
      String targetRoute;
      switch (lastStep) {
        case 'theory':
          targetRoute =
              '${AppRoutes.quiz}?chapterId=$lastChapterId'; // 이론 완료 후 퀴즈로
          break;
        case 'quiz':
          targetRoute =
              '${AppRoutes.quizResult}?chapterId=$lastChapterId'; // 퀴즈 완료 후 결과로
          break;
        case 'result':
        default:
          targetRoute =
              '${AppRoutes.theory}?chapterId=$lastChapterId'; // 결과 확인 후 다음 이론으로
          break;
      }

      debugPrint('🎯 [CONTINUE_LEARNING] 이동할 경로: $targetRoute');
      context.go(targetRoute);
    } else {
      // 로그인 안된 경우: 로그인 안내 다이얼로그
      debugPrint('🔒 [CONTINUE_LEARNING] 비로그인 상태 - 학습 기능 접근 차단');
      _showLoginRequiredDialog(context, '학습 기능');
    }
  }

  /// 🔐 "전체보기" 버튼 처리 (로그인 체크 포함)
  void _handleViewAll(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isLoggedIn) {
      // 로그인된 경우: Education 메인 페이지로 이동
      debugPrint('✅ [CONTINUE_LEARNING] 로그인 상태 확인됨 - Education 메인으로 이동');
      context.go(AppRoutes.education);
    } else {
      // 로그인 안된 경우: 로그인 안내 다이얼로그
      debugPrint('🔒 [CONTINUE_LEARNING] 비로그인 상태 - Education 기능 접근 차단');
      _showLoginRequiredDialog(context, 'Education 기능');
    }
  }

  /// 🔑 로그인 필요 다이얼로그
  void _showLoginRequiredDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Theme.of(context).primaryColor,
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '로그인 필요',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앗! 로그인 먼저 해주세요! 🔒',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '$featureName을 사용하려면 로그인이 필요해요.\n지금 로그인하시겠어요?',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        actions: [
          // 나중에 버튼
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '나중에',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14.sp,
              ),
            ),
          ),
          // 로그인하기 버튼
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              debugPrint('🚀 [LOGIN_DIALOG] 로그인 페이지로 이동');
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              '로그인하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎓 학습 현황 요약 위젯
class LearningOverviewWidget extends StatelessWidget {
  const LearningOverviewWidget({super.key});

  // Provider에서 데이터를 가져오므로 매개변수 불필요

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProgressProvider>(
      builder: (context, progressProvider, child) {
        if (!progressProvider.isInitialized) {
          return Container(height: 120.h); // 로딩시 빈 공간
        }

        final totalChapters = 10;
        final completedChapters = progressProvider.completedChaptersCount;
        final totalQuizzes = 15;
        final completedQuizzes = progressProvider.completedQuizzesCount;
        final studyStreak = progressProvider.getStudyStreak();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🏆 헤더
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '학습 현황',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // 📊 통계 그리드
              Row(
                children: [
                  // 챕터 완료율
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.menu_book_rounded,
                      label: '챕터',
                      value: '$completedChapters / $totalChapters',
                      progress: completedChapters / totalChapters,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 퀴즈 완료율
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.quiz_rounded,
                      label: '퀴즈',
                      value: '$completedQuizzes / $totalQuizzes',
                      progress: completedQuizzes / totalQuizzes,
                      color: AppTheme.warningColor,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 연속 학습
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.local_fire_department_rounded,
                      label: '연속',
                      value: '$studyStreak일',
                      progress: (studyStreak / 7).clamp(0.0, 1.0),
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
