//두 Repository가 구현할 인터페이스

//presentation 계층이 어떤 함수를 통해 데이터에 접근할지를 정의하는 
//'설계도' 또는 '인터페이스'입니다. 실제 데이터가 서버에서 오는지, 
//더미 데이터인지 신경 쓰지 않고 일관된 방식으로 함수를 호출할 수 있게 해줍니다.

import '../model/attendance_day.dart';
import '../model/attendance_quiz.dart';
import '../../data/dto/quiz_submission_dto.dart';

/// 출석 관련 데이터 처리를 위한 Repository 추상 클래스
abstract class AttendanceRepository {
  /// 특정 월의 출석 현황을 가져옵니다.
  Future<List<AttendanceDay>> getAttendanceStatus(DateTime month);

  /// 오늘의 출석 퀴즈 목록을 가져옵니다.
  Future<List<AttendanceQuiz>> getTodaysQuiz();

  /// 퀴즈 답변을 제출하고 출석을 완료합니다.
  Future<void> submitAttendance(QuizSubmissionDto submission);
}
