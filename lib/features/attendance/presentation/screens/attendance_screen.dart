import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../provider/attendance_provider.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_quiz_dialog.dart';
import '../../../../app/core/utils/theme_utils.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAttendanceStatus(DateTime.now());
    });
  }

  Future<void> _onStartQuizPressed() async {
    final provider = context.read<AttendanceProvider>();

    await provider.setQuizLoading(true);

    final success = await provider.fetchTodaysQuiz();

    if (!mounted) {
      return;
    }

    if (success && provider.quizzes.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return ChangeNotifierProvider.value(
            value: provider,
            child: AttendanceQuizDialog(quizzes: provider.quizzes),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '퀴즈를 불러오는 데 실패했습니다.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
    await provider.setQuizLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final today = DateTime.utc(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final isAlreadyAttended = provider.attendanceStatus[today] ?? false;

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
                if (provider.isQuizLoading)
                  const LoadingWidget(
                    message: '퀴즈를 불러오는 중...',
                  )
                else
                  ActionButton(
                    text:
                        isAlreadyAttended ? '오늘은 이미 출석했습니다' : '오늘의 퀴즈 풀고 출석하기',
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
      },
    );
  }
}
