import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../attendance/presentation/provider/attendance_provider.dart';
import '../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../wrong_note/presentation/wrong_note_provider.dart';
import '../../note/presentation/provider/note_provider.dart';
import 'widgets/date_header_widget.dart';
import 'widgets/stats_cards_widget.dart';
import 'widgets/quiz_section_widget.dart';
import 'widgets/feature_cards_widget.dart';

/// 중심적인 메인 대시보드 화면 - 모든 기능에 접근할 수 있는 허브
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 모든 provider 초기화
      context.read<AttendanceProvider>().initialize();
      context.read<AptitudeProvider>().checkPreviousResult();
      context.read<WrongNoteProvider>().loadWrongNotes();
      context.read<NoteProvider>().fetchAllNotes();
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
              SizedBox(height: 20.h),

              // 상단: 날짜 정보
              const DateHeaderWidget(),

              SizedBox(height: 32.h),

              // 중간: 통계 카드들
              const StatsCardsWidget(),

              SizedBox(height: 20.h),

              // 기능별 접근 카드들
              const FeatureCardsWidget(),

              SizedBox(height: 32.h),
              // 퀴즈 섹션
              const QuizSectionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
