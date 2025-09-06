import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../wrong_note/presentation/wrong_note_provider.dart';
import '../../note/presentation/provider/note_provider.dart';
import '../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../attendance/presentation/provider/attendance_provider.dart';
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
              // 프로필 헤더
              ProfileHeader(
                nickname: '닉네임',
                onEditPressed: () {
                  // TODO: 닉네임 편집 기능 구현
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
}
