import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/core/widgets/custom_snackbar.dart'; // 🎨 커스텀 SnackBar
import '../../../../app/core/widgets/loading_widget.dart';
import '../riverpod/attendance_notifier.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_quiz_dialog.dart';
import '../../../../app/core/utils/theme_utils.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(attendanceNotifierProvider.notifier)
        .fetchAttendanceStatus(DateTime.now()));
  }

  Future<void> _onStartQuizPressed() async {
    final notifier = ref.read(attendanceNotifierProvider.notifier);

    notifier.setQuizLoading(true);

    final success = await notifier.fetchTodaysQuiz();

    if (!mounted) {
      return;
    }

    final attendanceState = ref.read(attendanceNotifierProvider);
    if (success && attendanceState.quizzes.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return ProviderScope(
            child: AttendanceQuizDialog(quizzes: attendanceState.quizzes),
          );
        },
      );
    } else {
      // 🎨 퀴즈 로드 실패 에러 메시지 (커스텀 SnackBar)
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: attendanceState.errorMessage ?? '퀴즈를 불러오는 데 실패했습니다.',
      );
    }
    notifier.setQuizLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final today = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final isAlreadyAttended = attendanceState.attendanceStatus[today] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('출석 체크'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const AttendanceCalendar(),
            const Spacer(),
            if (attendanceState.isQuizLoading)
              const LoadingWidget(
                message: '퀴즈를 불러오는 중...',
              )
            else
              ActionButton(
                text: isAlreadyAttended ? '오늘은 이미 출석했습니다' : '오늘의 퀴즈 풀고 출석하기',
                icon: isAlreadyAttended ? Icons.check_circle : Icons.quiz,
                color: isAlreadyAttended
                    ? (ThemeUtils.isDarkMode(context)
                        ? AppTheme.grey600
                        : AppTheme.grey400)
                    : Theme.of(context).primaryColor,
                onPressed: isAlreadyAttended ? null : _onStartQuizPressed,
                width: double.infinity,
                height: 50.h,
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
