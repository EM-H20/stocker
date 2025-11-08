import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../wrong_note/presentation/wrong_note_provider.dart';
import '../../note/presentation/provider/note_provider.dart';
import '../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../attendance/presentation/provider/attendance_provider.dart';
import '../../auth/presentation/auth_provider.dart'; // AuthProvider 추가
import '../../../app/core/widgets/loading_widget.dart';
import 'widgets/profile_header.dart';
import 'widgets/aptitude_analysis_card.dart';
import 'widgets/attendance_status_card.dart';
import 'widgets/wrong_note_card.dart';
import 'widgets/note_section.dart';
import 'widgets/theme_toggle_widget.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 모든 provider 초기화
      context.read<NoteProvider>().fetchAllNotes();
      context.read<WrongNoteProvider>().loadWrongNotes();
      context.read<AptitudeProvider>().checkPreviousResult();
      context.read<AttendanceProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 헤더 (실제 사용자 닉네임 표시 + 수정 기능)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ProfileHeader(
                    nickname: authProvider.user?.nickname ?? '사용자', // 실제 닉네임 표시
                    onEditPressed: () => _showNicknameEditDialog(context, authProvider),
                  );
                },
              ),

              SizedBox(height: 8.h),

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
  void _showNicknameEditDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController controller = TextEditingController();
    controller.text = authProvider.user?.nickname ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      enabled: !authProvider.isUpdatingProfile,
                    ),
                    maxLength: 20,
                    onSubmitted: (value) => _updateNickname(context, authProvider, value.trim()),
                  ),
                  
                  // 로딩 상태 표시
                  if (authProvider.isUpdatingProfile) ...[
                    SizedBox(height: 8.h),
                    const LoadingWidget.small(
                      message: '닉네임 변경 중...',
                    ),
                  ],
                  
                  // 에러 메시지 표시
                  if (authProvider.errorMessage != null && authProvider.errorMessage!.contains('프로필')) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 25),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.red.withValues(alpha: 25)),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
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
                  onPressed: authProvider.isUpdatingProfile ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      color: authProvider.isUpdatingProfile ? Colors.grey : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: authProvider.isUpdatingProfile 
                    ? null 
                    : () => _updateNickname(context, authProvider, controller.text.trim()),
                  child: Text(
                    authProvider.isUpdatingProfile ? '변경 중...' : '변경',
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
  void _updateNickname(BuildContext context, AuthProvider authProvider, String newNickname) async {
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
    if (newNickname == authProvider.user?.nickname) {
      Navigator.of(context).pop();
      return;
    }

    debugPrint('🔄 [NICKNAME_UPDATE] 닉네임 변경 요청: ${authProvider.user?.nickname} → $newNickname');

    // 실제 API 호출
    final success = await authProvider.updateNickname(newNickname);

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
        // 실패 시 에러 메시지는 다이얼로그 내에서 표시 (StatefulBuilder로 처리됨)
        debugPrint('❌ [NICKNAME_UPDATE] 닉네임 변경 실패: ${authProvider.errorMessage}');
        
        // 다이얼로그가 닫혀있다면 스낵바로도 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('닉네임 변경에 실패했습니다: ${authProvider.errorMessage ?? "알 수 없는 오류"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}