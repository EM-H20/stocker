import 'dart:convert';
import 'package:flutter/material.dart';

/// 오답노트 응답 모델
class WrongNoteResponse {
  final List<WrongNoteItem> wrongNotes;

  const WrongNoteResponse({
    required this.wrongNotes,
  });

  /// JSON에서 객체 생성 (백엔드 응답 형식)
  factory WrongNoteResponse.fromJson(Map<String, dynamic> json) {
    return WrongNoteResponse(
      wrongNotes: (json['wrong_notes'] as List)
          .map((item) => WrongNoteItem.fromBackendJson(item))
          .toList(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'wrong_notes': wrongNotes.map((item) => item.toJson()).toList(),
    };
  }
}

/// 오답노트 항목 모델 (백엔드 구조와 매칭)
/// 백엔드: id, quiz_id, chapter_id, user_id, selected_option, created_date
class WrongNoteItem {
  final int id;
  final int quizId;
  final int chapterId;
  final int userId;
  final int selectedOption; // 1~4 (백엔드와 동일)
  final DateTime createdDate;

  // UI 표시용 추가 정보 (JOIN으로 조회되는 데이터)
  final String? chapterTitle;
  final String? question;
  final List<String>? options;
  final String? explanation;
  final int? correctAnswerIndex; // 정답 인덱스 (0-based)
  final String? correctAnswerText; // 정답 텍스트

  const WrongNoteItem({
    required this.id,
    required this.quizId,
    required this.chapterId,
    required this.userId,
    required this.selectedOption,
    required this.createdDate,
    this.chapterTitle,
    this.question,
    this.options,
    this.explanation,
    this.correctAnswerIndex,
    this.correctAnswerText,
  });

  /// 백엔드 JSON에서 객체 생성 (JOIN 데이터 포함)
  factory WrongNoteItem.fromBackendJson(Map<String, dynamic> json) {
    debugPrint('🔍 [WrongNote] API 응답 파싱 중: ${json.keys.join(', ')}');

    // selected_option null 처리 (API에서 null이 올 수 있음)
    final selectedOpt = json['selected_option'];
    final selectedOption = selectedOpt is int
        ? selectedOpt
        : (selectedOpt is String ? int.tryParse(selectedOpt) : null) ?? 1;

    // correct_option을 correct_answer_index로 변환 (1~4 → 0~3)
    final correctOpt = json['correct_option'];
    int? correctAnswerIndex;
    if (correctOpt is int && correctOpt >= 1 && correctOpt <= 4) {
      correctAnswerIndex = correctOpt - 1; // 1-based to 0-based
    }

    // options 파싱 (JSON 문자열일 수도 있고, 배열일 수도 있음)
    List<String>? optionsList;
    final optionsData = json['options'];
    if (optionsData != null) {
      if (optionsData is List) {
        optionsList = List<String>.from(optionsData);
      } else if (optionsData is String) {
        try {
          // JSON 문자열인 경우 파싱 시도
          final parsed = jsonDecode(optionsData);
          if (parsed is List) {
            optionsList = List<String>.from(parsed);
          }
        } catch (e) {
          debugPrint('⚠️ [WrongNote] options 파싱 실패: $e');
        }
      }
    }

    final result = WrongNoteItem(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      chapterId: json['chapter_id'] as int,
      userId: json['user_id'] as int,
      selectedOption: selectedOption,
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'] as String)
          : DateTime.now(),
      // JOIN된 추가 정보
      chapterTitle: json['chapter_title'] as String?,
      question: json['question'] as String?,
      options: optionsList,
      explanation: json['explanation'] as String?,
      correctAnswerIndex: correctAnswerIndex,
      correctAnswerText: correctAnswerIndex != null &&
              optionsList != null &&
              correctAnswerIndex >= 0 &&
              correctAnswerIndex < optionsList.length
          ? optionsList[correctAnswerIndex]
          : null,
    );

    debugPrint(
        '✅ [WrongNote] 파싱 완료 - ID: ${result.id}, Quiz: ${result.quizId}, Selected: ${result.selectedOption}, Correct: ${result.correctAnswerIndex}');
    return result;
  }

  /// Mock/기존 JSON 변환 (하위 호환성)
  factory WrongNoteItem.fromJson(Map<String, dynamic> json) {
    return WrongNoteItem(
      id: json['id'] as int,
      chapterId: json['chapter_id'] as int,
      quizId: json['quiz_id'] as int,
      userId: json['user_id'] as int? ?? 0,
      selectedOption: json['selected_option'] as int? ?? 1,
      createdDate: json['created_date'] != null || json['wrong_date'] != null
          ? DateTime.parse(
              (json['created_date'] ?? json['wrong_date']) as String)
          : DateTime.now(),
      chapterTitle: json['chapter_title'] as String?,
      question: json['question'] as String?,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      explanation: json['explanation'] as String?,
      correctAnswerIndex: json['correct_answer_index'] as int?,
      correctAnswerText: json['correct_answer_text'] as String?,
    );
  }

  /// 백엔드 형태로 JSON 변환
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'chapter_id': chapterId,
      'user_id': userId,
      'selected_option': selectedOption,
      'created_date': createdDate.toIso8601String(),
    };
  }

  /// Mock/기존 형태로 JSON 변환 (하위 호환성)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'chapter_id': chapterId,
      'user_id': userId,
      'selected_option': selectedOption,
      'created_date': createdDate.toIso8601String(),
      'chapter_title': chapterTitle,
      'question': question,
      'options': options,
      'explanation': explanation,
      'correct_answer_index': correctAnswerIndex,
      'correct_answer_text': correctAnswerText,
    };
  }

  /// 복사본 생성
  WrongNoteItem copyWith({
    int? id,
    int? quizId,
    int? chapterId,
    int? userId,
    int? selectedOption,
    DateTime? createdDate,
    String? chapterTitle,
    String? question,
    List<String>? options,
    String? explanation,
    int? correctAnswerIndex,
    String? correctAnswerText,
  }) {
    return WrongNoteItem(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      chapterId: chapterId ?? this.chapterId,
      userId: userId ?? this.userId,
      selectedOption: selectedOption ?? this.selectedOption,
      createdDate: createdDate ?? this.createdDate,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      question: question ?? this.question,
      options: options ?? this.options,
      explanation: explanation ?? this.explanation,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      correctAnswerText: correctAnswerText ?? this.correctAnswerText,
    );
  }

  /// 정답 여부 확인
  bool get isCorrect => false; // selected_option이 정답이 아니므로 항상 false

  /// 선택한 답안 텍스트
  String get selectedAnswerText {
    if (options == null ||
        selectedOption < 1 ||
        selectedOption > options!.length) {
      return '선택 $selectedOption번';
    }
    return options![selectedOption - 1]; // 1-based → 0-based
  }
}
