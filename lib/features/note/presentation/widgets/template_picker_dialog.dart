
// FILE: lib/features/note/presentation/widgets/template_picker_dialog.dart
import 'package:flutter/material.dart';
import '../constants/note_templates.dart';

/// 새 노트 작성 시 템플릿을 선택하는 다이얼로그
class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('템플릿 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: NoteTemplates.templates.length,
          itemBuilder: (context, index) {
            final template = NoteTemplates.templates[index];
            return ListTile(
              title: Text(template.name),
              onTap: () {
                // 선택한 템플릿을 이전 화면으로 반환하며 다이얼로그를 닫음
                Navigator.of(context).pop(template);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
      ],
    );
  }
}