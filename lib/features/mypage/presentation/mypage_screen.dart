import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../note/presentation/riverpod/note_notifier.dart';
import '../../auth/presentation/riverpod/auth_notifier.dart';
import '../../../app/core/widgets/loading_widget.dart';
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

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newNickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 2글자 이상 입력해주세요'),
          backgroundColor: Colors.red,
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임이 "$newNickname"으로 변경되었습니다'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        debugPrint('✅ [NICKNAME_UPDATE] 닉네임 변경 성공: $newNickname');
      } else {
        final errorMessage = ref.read(authNotifierProvider).value?.errorMessage;

        // 실패 시 에러 메시지는 다이얼로그 내에서 표시 (Consumer로 처리됨)
        debugPrint('❌ [NICKNAME_UPDATE] 닉네임 변경 실패: $errorMessage');

        // 다이얼로그가 닫혀있다면 스낵바로도 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '닉네임 변경에 실패했습니다: ${errorMessage ?? "알 수 없는 오류"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
