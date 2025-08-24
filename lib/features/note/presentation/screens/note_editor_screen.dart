// FILE: lib/features/note/presentation/screens/note_editor_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// ✅ Provider에 데이터를 전달하기 위한 DTO import를 추가합니다.
import '../../data/dto/note_update_request.dart'; 
import '../../domain/model/note.dart';
import '../constants/note_templates.dart';
import '../provider/note_provider.dart';

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
      context.pop();
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
      appBar: AppBar(
        title: Text(_isNewNote ? '새 노트 작성' : '노트 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          quill.QuillSimpleToolbar(
            controller: _controller,
            config: const quill.QuillSimpleToolbarConfig(
              multiRowsDisplay: true,
              showAlignmentButtons: true,
              showFontFamily: true,
              showFontSize: true,
              showListCheck: true,
              showCodeBlock: true,
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: quill.QuillEditor.basic(
              controller: _controller,
              config: const quill.QuillEditorConfig(
                expands: true,
                padding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}