import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../note/presentation/riverpod/note_notifier.dart';
import '../../auth/presentation/riverpod/auth_notifier.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../../../app/core/widgets/custom_snackbar.dart'; // 🎨 커스텀 SnackBar
import 'widgets/profile_header.dart';
import 'widgets/aptitude_analysis_card.dart';
import 'widgets/attendance_status_card.dart';
import 'widgets/wrong_note_card.dart';
import 'widgets/note_section.dart';
import 'widgets/theme_toggle_widget.dart';
import '../../home/presentation/widgets/stats_cards_widget.dart';

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(noteNotifierProvider.notifier).fetchAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Riverpod: ref.watch로 상태 구독
    final authAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              authAsync.when(
                data: (authState) => ProfileHeader(
                  nickname: authState.user?.nickname ?? '사용자',
                  onEditPressed: () => _showNicknameEditDialog(context),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 8.h),

              // 학습 현황 통계
              const StatsCardsWidget(),

              SizedBox(height: 16.h),

              // 투자성향 분석
              const AptitudeAnalysisCard(),

              SizedBox(height: 16.h),

              // 출석현황
              const AttendanceStatusCard(),

              SizedBox(height: 16.h),

              // 오답노트
              const WrongNoteCard(),

              SizedBox(height: 16.h),

              // 노트 섹션
              const NoteSection(),

              SizedBox(height: 16.h),

              // 테마 설정
              const ThemeToggleWidget(),

              SizedBox(height: 16.h),

              // 로그아웃 버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildLogoutButton(context),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 로그아웃 버튼 위젯
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 24.sp,
                      color: Colors.red[600],
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.red[600]?.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleLogout(context);
            },
            child: Text(
              '로그아웃',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // 🔥 Riverpod: 로그아웃 실행
      await ref.read(authNotifierProvider.notifier).logout();

      if (context.mounted) {
        // 🎨 로그아웃 성공 메시지
        CustomSnackBar.show(
          context: context,
          type: SnackBarType.success,
          message: '로그아웃되었습니다',
          duration: const Duration(seconds: 2),
        );

        // 로그인 화면으로 이동
        context.go(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('❌ [LOGOUT] 로그아웃 처리 중 오류 발생: $e');

      if (context.mounted) {
        // 🎨 로그아웃 실패 메시지
        CustomSnackBar.show(
          context: context,
          type: SnackBarType.error,
          message: '로그아웃 처리 중 오류가 발생했습니다',
        );
      }
    }
  }

  /// 닉네임 수정 다이얼로그 (실제 API 연동)
  void _showNicknameEditDialog(BuildContext context) {
    final authAsync = ref.read(authNotifierProvider);
    final authState = authAsync.value;

    final TextEditingController controller = TextEditingController();
    controller.text = authState?.user?.nickname ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final authAsync = ref.watch(authNotifierProvider);
            final authState = authAsync.value;

            return AlertDialog(
              title: Text(
                '닉네임 변경',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: '새 닉네임',
                      hintText: '변경할 닉네임을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      // 로딩 중이면 입력 비활성화
                      enabled: !(authState?.isUpdatingProfile ?? false),
                    ),
                    maxLength: 20,
                    onSubmitted: (value) =>
                        _updateNickname(context, value.trim()),
                  ),

                  // 로딩 상태 표시
                  if (authState?.isUpdatingProfile ?? false) ...[
                    SizedBox(height: 8.h),
                    const LoadingWidget.small(
                      message: '닉네임 변경 중...',
                    ),
                  ],

                  // 에러 메시지 표시
                  if (authState?.errorMessage != null &&
                      authState!.errorMessage!.contains('프로필')) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 25),
                        borderRadius: BorderRadius.circular(6.r),
                        border:
                            Border.all(color: Colors.red.withValues(alpha: 25)),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: (authState?.isUpdatingProfile ?? false)
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: (authState?.isUpdatingProfile ?? false)
                          ? Colors.grey
                          : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (authState?.isUpdatingProfile ?? false)
                      ? null
                      : () => _updateNickname(context, controller.text.trim()),
                  child: Text(
                    (authState?.isUpdatingProfile ?? false) ? '변경 중...' : '변경',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 실제 API를 통한 닉네임 업데이트 처리
  void _updateNickname(BuildContext context, String newNickname) async {
    final authAsync = ref.read(authNotifierProvider);
    final authState = authAsync.value;

    // 입력 검증
    if (newNickname.isEmpty) {
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: '닉네임을 입력해주세요',
      );
      return;
    }

    if (newNickname.length < 2) {
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: '닉네임은 2글자 이상 입력해주세요',
      );
      return;
    }

    // 기존 닉네임과 같으면 변경 안함
    if (newNickname == authState?.user?.nickname) {
      Navigator.of(context).pop();
      return;
    }

    debugPrint(
        '🔄 [NICKNAME_UPDATE] 닉네임 변경 요청: ${authState?.user?.nickname} → $newNickname');

    // 🔥 Riverpod: 실제 API 호출
    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateNickname(newNickname);

    if (context.mounted) {
      if (success) {
        // 성공 시 다이얼로그 닫고 성공 메시지
        Navigator.of(context).pop();
        CustomSnackBar.show(
          context: context,
          type: SnackBarType.success,
          message: '닉네임이 "$newNickname"으로 변경되었습니다',
          duration: const Duration(seconds: 2),
        );
        debugPrint('✅ [NICKNAME_UPDATE] 닉네임 변경 성공: $newNickname');
      } else {
        final errorMessage = ref.read(authNotifierProvider).value?.errorMessage;

        // 실패 시 에러 메시지는 다이얼로그 내에서 표시 (Consumer로 처리됨)
        debugPrint('❌ [NICKNAME_UPDATE] 닉네임 변경 실패: $errorMessage');

        // 다이얼로그가 닫혀있다면 스낵바로도 표시
        CustomSnackBar.show(
          context: context,
          type: SnackBarType.error,
          message: '닉네임 변경에 실패했습니다: ${errorMessage ?? "알 수 없는 오류"}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
