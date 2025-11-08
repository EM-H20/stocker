import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository interfaces
import '../../../../features/auth/domain/auth_repository.dart';
import '../../../../features/attendance/domain/repository/attendance_repository.dart';
import '../../../../features/aptitude/domain/repository/aptitude_repository.dart';
import '../../../../features/note/domain/repository/note_repository.dart';
import '../../../../features/education/domain/education_repository.dart';
import '../../../../features/quiz/domain/quiz_repository.dart';
import '../../../../features/wrong_note/domain/wrong_note_repository.dart';
import '../../../../features/learning/domain/repository/learning_progress_repository.dart';

// Mock implementations
import '../../../../features/auth/data/repository/auth_mock_repository.dart';
import '../../../../features/attendance/data/repository/attendance_mock_repository.dart';
import '../../../../features/aptitude/data/repository/aptitude_mock_repository.dart';
import '../../../../features/note/data/repository/note_mock_repository.dart';
import '../../../../features/education/domain/education_mock_repository.dart';
import '../../../../features/quiz/domain/quiz_mock_repository.dart';
import '../../../../features/wrong_note/data/wrong_note_mock_repository.dart';
import '../../../../features/learning/data/repository/learning_progress_mock_repository.dart';

// API implementations
import '../../../../features/auth/data/repository/auth_api_repository.dart';
import '../../../../features/attendance/data/repository/attendance_api_repository.dart';
import '../../../../features/aptitude/data/repository/aptitude_api_repository.dart';
import '../../../../features/note/data/repository/note_api_repository.dart';
import '../../../../features/learning/data/repository/learning_progress_api_repository.dart';

// API sources
import '../../../../features/auth/data/source/auth_api.dart';
import '../../../../features/attendance/data/source/attendance_api.dart';
import '../../../../features/aptitude/data/source/aptitude_api.dart';
import '../../../../features/note/data/source/note_api.dart';
import '../../../../features/education/data/education_api.dart';
import '../../../../features/quiz/data/quiz_api.dart';
import '../../../../features/wrong_note/data/wrong_note_api.dart';
import '../../../../features/learning/data/source/learning_progress_api.dart';

// Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Network
import 'package:stocker/app/core/network/dio.dart' show dio;
import 'package:stocker/main.dart' show useMock;

part 'repository_providers.g.dart';

/// 🔥 Riverpod 기반 Repository Providers
/// Mock/Real API 전환을 위한 Repository 제공자들

/// 인증 Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return useMock
      ? AuthMockRepository()
      : AuthApiRepository(AuthApi(dio));
}

/// 출석 Repository Provider
@riverpod
AttendanceRepository attendanceRepository(Ref ref) {
  return useMock
      ? AttendanceMockRepository()
      : AttendanceApiRepository(AttendanceApi(dio));
}

/// 성향분석 Repository Provider
@riverpod
AptitudeRepository aptitudeRepository(Ref ref) {
  return useMock
      ? AptitudeMockRepository()
      : AptitudeApiRepository(AptitudeApi(dio));
}

/// 노트 Repository Provider
@riverpod
NoteRepository noteRepository(Ref ref) {
  return useMock
      ? NoteMockRepository()
      : NoteApiRepository(NoteApi(dio));
}

/// 교육 Repository Provider
@riverpod
Object educationRepository(Ref ref) {
  const storage = FlutterSecureStorage();
  return useMock
      ? EducationMockRepository()
      : EducationRepository(EducationApi(dio), storage);
}

/// 퀴즈 Repository Provider
@riverpod
Object quizRepository(Ref ref) {
  const storage = FlutterSecureStorage();
  return useMock
      ? QuizMockRepository()
      : QuizRepository(QuizApi(dio), storage);
}

/// 오답노트 Repository Provider
@riverpod
Object wrongNoteRepository(Ref ref) {
  return useMock
      ? WrongNoteMockRepository()
      : WrongNoteRepository(WrongNoteApi(dio));
}

/// 학습 진도 Repository Provider
@riverpod
LearningProgressRepository learningProgressRepository(Ref ref) {
  return useMock
      ? LearningProgressMockRepository()
      : LearningProgressApiRepository(LearningProgressApi(dio));
}
