// FILE: lib/features/note/presentation/screens/note_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../constants/note_templates.dart';
import '../provider/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/template_picker_dialog.dart';

/// 전체 노트 목록을 보여주는 화면
class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때, 모든 노트를 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().fetchAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 투자 노트'),
      ),
      body: provider.isLoading
          ? const Center(child: SpinKitFadingCircle(color: Colors.blue))
          : notes.isEmpty
              ? const Center(
                  child: Text(
                    '아직 작성된 노트가 없어요.\n아래 버튼을 눌러 첫 노트를 작성해보세요!',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.fetchAllNotes(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          // 기존 노트를 편집하기 위해 에디터 화면으로 이동
                          context.push(AppRoutes.noteEditor, extra: note);
                        },
                        onDelete: () {
                          // 삭제 확인 다이얼로그 표시
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('노트 삭제'),
                              content: const Text('정말로 이 노트를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.deleteNote(note.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 템플릿 선택 다이얼로그를 띄우고 결과를 받음
          final selectedTemplate = await showDialog<NoteTemplate>(
            context: context,
            builder: (_) => const TemplatePickerDialog(),
          );

          if (mounted && selectedTemplate != null) {
            // 템플릿을 선택했다면, 새 노트 작성을 위해 에디터 화면으로 이동
            context.push(AppRoutes.noteEditor, extra: selectedTemplate);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}