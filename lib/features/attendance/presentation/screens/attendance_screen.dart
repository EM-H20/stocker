// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';

// import '../../../../app/core/widgets/action_button.dart';
// import '../provider/attendance_provider.dart';
// import '../widgets/attendance_calendar.dart';
// import '../widgets/attendance_quiz_dialog.dart';

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // ✅ [수정] 화면이 처음 로드될 때, 오늘 날짜의 출석 현황을 가져옵니다.
//       context.read<AttendanceProvider>().fetchAttendanceStatus(DateTime.now());
//     });
//   }

//   /// '퀴즈 풀기' 버튼을 눌렀을 때의 동작
//   Future<void> _onStartQuizPressed() async {
//     final provider = context.read<AttendanceProvider>();
//     // ✅ [수정] 버튼을 누르면 바로 퀴즈를 가져오는 로직 실행
//     final success = await provider.fetchTodaysQuiz();

//     // ✅ [수정] 퀴즈를 성공적으로 가져왔을 때만 다이얼로그를 띄웁니다.
//     if (mounted && success && provider.quizzes.isNotEmpty) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AttendanceQuizDialog(quizzes: provider.quizzes),
//       );
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.errorMessage ?? '퀴즈를 불러오는 데 실패했습니다.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AttendanceProvider>();
//     final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//     // ✅ [수정] attendanceStatus 맵에서 오늘 날짜의 출석 여부를 확인합니다.
//     final isAlreadyAttended = provider.attendanceStatus[today] ?? false;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('출석 체크'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const AttendanceCalendar(),
//             const Spacer(),
            
//             // ✅ [수정] 로딩 상태를 isInitializing이 아닌 isLoading으로 확인
//             if (provider.isLoading && provider.attendanceStatus.isEmpty)
//               const SpinKitFadingCircle(color: Colors.blue, size: 50.0)
//             else
//               ActionButton(
//                 text: isAlreadyAttended ? '오늘은 이미 출석했습니다' : '오늘의 퀴즈 풀고 출석하기',
//                 icon: isAlreadyAttended ? Icons.check_circle : Icons.quiz,
//                 color: isAlreadyAttended ? Colors.grey : Colors.blue,
//                 // ✅ [수정] 로딩 중이거나 이미 출석했으면 버튼 비활성화
//                 onPressed: isAlreadyAttended || provider.isLoading ? null : _onStartQuizPressed,
//                 width: double.infinity,
//                 height: 50,
//               ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../app/core/widgets/action_button.dart';
import '../provider/attendance_provider.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/attendance_quiz_dialog.dart';

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
    print("[DEBUG] 3. '퀴즈 풀기' 버튼 눌림");
    final provider = context.read<AttendanceProvider>();
    
    await provider.setQuizLoading(true);
    print("[DEBUG] 4. 퀴즈 로딩 시작 (setQuizLoading(true))");

    final success = await provider.fetchTodaysQuiz();
    print("[DEBUG] 5. fetchTodaysQuiz 완료. 성공 여부: $success");

    if (!mounted) {
      print("[DEBUG] 6. 위젯이 unmounted 상태라 작업 중단.");
      return;
    }

    if (success && provider.quizzes.isNotEmpty) {
      print("[DEBUG] 6. 퀴즈 데이터 확인 완료. 다이얼로그 표시 시도.");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          print("[DEBUG] 7. showDialog의 builder 실행됨.");
          return ChangeNotifierProvider.value(
            value: provider,
            child: AttendanceQuizDialog(quizzes: provider.quizzes),
          );
        },
      );
    } else {
      print("[DEBUG] 6. 퀴즈가 없거나 가져오기 실패. 에러 메시지 표시.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '퀴즈를 불러오는 데 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    await provider.setQuizLoading(false);
    print("[DEBUG] 8. 퀴즈 로딩 종료 (setQuizLoading(false))");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final isAlreadyAttended = provider.attendanceStatus[today] ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text('출석 체크'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const AttendanceCalendar(),
                const Spacer(),
                if (provider.isQuizLoading)
                  const SpinKitFadingCircle(color: Colors.blue, size: 50.0)
                else
                  ActionButton(
                    text: isAlreadyAttended ? '오늘은 이미 출석했습니다' : '오늘의 퀴즈 풀고 출석하기',
                    icon: isAlreadyAttended ? Icons.check_circle : Icons.quiz,
                    color: isAlreadyAttended ? Colors.grey : Colors.blue,
                    onPressed: isAlreadyAttended ? null : _onStartQuizPressed,
                    width: double.infinity,
                    height: 50,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}