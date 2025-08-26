import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../wrong_note/data/wrong_note_mock_repository.dart';
import '../../wrong_note/data/models/wrong_note_response.dart';
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
  final WrongNoteMockRepository _wrongNoteRepository =
      WrongNoteMockRepository();
  List<WrongNoteItem> _wrongNotes = [];
  bool _isLoading = true;

  // Mock 노트 데이터
  final List<NoteItem> _mockNotes = [
    NoteItem(
      title: '노트 이름',
      preview: '노트 첫 줄 미리보기',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NoteItem(
      title: '노트 이름',
      preview: '노트 첫 줄 미리보기',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadWrongNotes();
  }

  Future<void> _loadWrongNotes() async {
    try {
      final response = await _wrongNoteRepository.getWrongNotes('user123');
      setState(() {
        _wrongNotes = response.wrongNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                      AptitudeAnalysisCard(
                        onTap: () {
                          // TODO: 투자성향 분석 페이지로 이동
                        },
                      ),

                      SizedBox(height: 16.h),

                      // 출석현황
                      AttendanceStatusCard(
                        onViewAllPressed: () {
                          // TODO: 전체 출석현황 페이지로 이동
                        },
                      ),

                      SizedBox(height: 16.h),

                      // 오답노트
                      WrongNoteCard(
                        wrongNotes: _wrongNotes,
                        onViewAllPressed: () {
                          // TODO: 오답노트 페이지로 이동
                        },
                      ),

                      SizedBox(height: 16.h),

                      // 노트 섹션
                      NoteSection(
                        notes: _mockNotes,
                        onAddPressed: () {
                          // TODO: 새 노트 추가 기능 구현
                        },
                      ),
                    
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
