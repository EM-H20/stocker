import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../attendance/presentation/provider/attendance_provider.dart';
import '../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../wrong_note/presentation/wrong_note_provider.dart';
import '../../note/presentation/provider/note_provider.dart';
import '../../education/presentation/education_provider.dart';
import 'widgets/date_header_widget.dart';
import 'widgets/stats_cards_widget.dart';
import 'widgets/quiz_section_widget.dart';
import 'widgets/feature_cards_widget.dart';
import 'widgets/continue_learning_widget.dart';

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
      context.read<EducationProvider>().loadChapters();
      // LearningProgressProvider는 생성자에서 자동 초기화됨
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

              // 🏠 상단: 간단한 인사 헤더
              const DateHeaderWidget(),

              SizedBox(height: 20.h),

              // 🎯 PRIORITY 1: 이어서 학습하기 (가장 중요한 기능을 최상단에!)
              const ContinueLearningWidget(),

              SizedBox(height: 24.h),

              // 📊 PRIORITY 2: 통합된 학습 대시보드
              const LearningOverviewWidget(),

              SizedBox(height: 20.h),

              // 📊 PRIORITY 3: 출석 및 활동 통계
              const StatsCardsWidget(),

              SizedBox(height: 24.h),

              // 🎯 PRIORITY 4: 빠른 기능 접근
              const FeatureCardsWidget(),

              SizedBox(height: 20.h),

              // 📝 PRIORITY 5: 퀴즈 및 추가 학습
              const QuizSectionWidget(),

              // 하단 여백
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
