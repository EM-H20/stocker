// FILE: lib/features/note/presentation/screens/note_editor_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// ✅ Provider에 데이터를 전달하기 위한 DTO import를 추가합니다.
import '../../data/dto/note_update_request.dart'; 
import '../../domain/model/note.dart';
import '../constants/note_templates.dart';
import '../provider/note_provider.dart';
import '../../../../app/config/app_routes.dart';

class NoteEditorScreen extends StatefulWidget {
  final dynamic initialData;
  const NoteEditorScreen({super.key, this.initialData});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  quill.QuillController _controller = quill.QuillController.basic(); // ✅ 기본값
  TextEditingController _titleController = TextEditingController();   // ✅ 기본값
  bool _isNewNote = true;
  Note? _existingNote;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // 사용자님이 주신 초기화 로직을 그대로 사용합니다.
  void _initializeControllers() {
    final initialData = widget.initialData;
    String title = '';
    String contentJson = '';

    if (initialData is Note) {
      _isNewNote = false;
      _existingNote = initialData;
      title = _existingNote!.title;
      contentJson = _existingNote!.content;
    } else if (initialData is NoteTemplate) {
      _isNewNote = true;
      title = initialData.name == '빈 노트' ? '' : initialData.name;
      contentJson = initialData.content;
    } else {
      _isNewNote = true;
      contentJson = NoteTemplates.templates[0].content;
    }

    _controller.readOnly = false;       // ✅ 11.4.2에선 여기서 편집모드
    _titleController = TextEditingController(text: title);
    setState(() {});                    // ✅ 새 컨트롤러로 교체했으니 리빌드


    try {
      final doc = quill.Document.fromJson(jsonDecode(contentJson));
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      debugPrint("컨트롤러 초기화 실패, 빈 에디터 시작: $e");
      _controller = quill.QuillController.basic();
    }
  }

  // ✅ [수정] 이 부분의 로직만 Provider와 맞도록 수정합니다.
  Future<void> _saveNote() async {
    final provider = context.read<NoteProvider>();
    final title = _titleController.text.trim();
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    // [핵심 수정] title과 content를 NoteUpdateRequest 객체로 묶어서 전달합니다.
    final request = NoteUpdateRequest(title: title, content: content);
    bool success;

    if (_isNewNote) {
      // Provider의 createNote 메소드에 request 객체 하나만 전달합니다.
      final newNote = await provider.createNote(request);
      success = newNote != null;
    } else {
      // Provider의 updateNote 메소드에 id와 request 객체를 전달합니다.
      success = await provider.updateNote(_existingNote!.id, request);
    }

    if (mounted && success) {
      // ✅ GoError 방지: 안전한 네비게이션으로 변경
      if (context.canPop()) {
        context.pop();
      } else {
        // 스택에 이전 화면이 없으면 노트 목록으로 이동
        context.go(AppRoutes.noteList);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '저장에 실패했습니다.')),
      );
    }
  }

  // ✅ UI 부분은
  @override
  Widget build(BuildContext context) {
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
            _showExitConfirmDialog(context);
          },
        ),
        title: Text(
          _isNewNote ? '새 노트 작성' : '노트 편집',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save_outlined,
              size: 24.sp,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: Theme.of(context).dividerColor,
          ),
          Container(
            color: Theme.of(context).cardColor,
            child: quill.QuillSimpleToolbar(
              controller: _controller,
              config: quill.QuillSimpleToolbarConfig(
                multiRowsDisplay: true,
                showAlignmentButtons: true,
                showFontFamily: true,
                showFontSize: true,
                showListCheck: true,
                showCodeBlock: true,
                toolbarIconAlignment: WrapAlignment.start,
                toolbarIconCrossAlignment: WrapCrossAlignment.center,
                toolbarSectionSpacing: 8.w,
              ),
            ),
          ),
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: quill.QuillEditor.basic(
                controller: _controller,
                config: quill.QuillEditorConfig(
                  expands: true,
                  padding: EdgeInsets.all(16.w),
                  placeholder: '여기에 내용을 입력하세요...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmDialog(BuildContext context) {
    // 내용이 변경되었는지 확인
    final hasTitle = _titleController.text.trim().isNotEmpty;
    final hasContent = _controller.document.toPlainText().trim().isNotEmpty;
    
    if (hasTitle || hasContent) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            '작성 중인 내용이 있습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '저장하지 않고 나가시겠습니까?\n작성 중인 내용은 모두 사라집니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '계속 작성',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exitEditor();
              },
              child: Text(
                '나가기',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _exitEditor();
    }
  }

  void _exitEditor() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.noteList);
    }
  }
}