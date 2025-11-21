// FILE: lib/features/note/presentation/screens/note_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/config/app_routes.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../../app/core/widgets/custom_snackbar.dart'; // 🎨 커스텀 SnackBar
import '../constants/note_templates.dart';
import '../riverpod/note_notifier.dart';
import '../widgets/note_card.dart';
import '../widgets/template_picker_dialog.dart';

/// 전체 노트 목록을 보여주는 화면
class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때, 모든 노트를 불러옵니다.
    Future.microtask(
        () => ref.read(noteNotifierProvider.notifier).fetchAllNotes());
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteNotifierProvider);
    final notes = noteState.notes;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
            size: 20.sp,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.mypage);
            }
          },
        ),
        title: Text(
          '나의 투자 노트',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: noteState.isLoading
          ? const Center(
              child: LoadingWidget(
                message: '노트를 불러오는 중...',
              ),
            )
          : notes.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(noteNotifierProvider.notifier).fetchAllNotes(),
                  color: Theme.of(context).primaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          // 기존 노트를 편집하기 위해 에디터 화면으로 이동
                          context.push(AppRoutes.noteEditor, extra: note);
                        },
                        onDelete: () => _showDeleteDialog(context, note),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 80.w,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.5),
            ),
            SizedBox(height: 24.h),
            Text(
              '아직 작성된 노트가 없어요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.8),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              '아래 버튼을 눌러 첫 노트를 작성해보세요!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => _showTemplateDialog(context),
              icon: Icon(Icons.add, size: 20.sp),
              label: Text(
                '첫 노트 작성하기',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '노트 삭제',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          '정말로 이 노트를 삭제하시겠습니까?\n삭제된 노트는 복구할 수 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                height: 1.4,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(noteNotifierProvider.notifier).deleteNote(note.id);
              Navigator.of(context).pop();
              // 🎨 커스텀 SnackBar로 노트 삭제 성공 메시지 표시
              CustomSnackBar.show(
                context: context,
                type: SnackBarType.success,
                message: '노트가 삭제되었습니다',
              );
            },
            child: Text(
              '삭제',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTemplateDialog(BuildContext context) async {
    final selectedTemplate = await showDialog<NoteTemplate>(
      context: context,
      builder: (_) => ProviderScope(
        child: const TemplatePickerDialog(),
      ),
    );

    if (mounted && selectedTemplate != null && context.mounted) {
      context.push(AppRoutes.noteEditor, extra: selectedTemplate);
    }
  }
}
