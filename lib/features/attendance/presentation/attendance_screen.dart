import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('AppTheme 디자인 샘플')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트 스타일 샘플
            Text('Headline Large', style: theme.textTheme.headlineLarge),
            Text('Headline Medium', style: theme.textTheme.headlineMedium),
            Text('Headline Small', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Title Large', style: theme.textTheme.titleLarge),
            Text('Title Medium', style: theme.textTheme.titleMedium),
            Text('Title Small', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Text('Body Large', style: theme.textTheme.bodyLarge),
            Text('Body Medium', style: theme.textTheme.bodyMedium),
            Text('Body Small', style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Text('Label Large', style: theme.textTheme.labelLarge),
            Text('Label Medium', style: theme.textTheme.labelMedium),
            Text('Label Small', style: theme.textTheme.labelSmall),
            const Divider(height: 32),

            // 버튼 스타일 샘플
            Text('ElevatedButtonTheme', style: theme.textTheme.titleMedium),
            Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                const SizedBox(width: 12),
                TextButton(onPressed: () {}, child: const Text('TextButton')),
              ],
            ),
            const Divider(height: 32),

            // 카드 스타일 샘플
            Text('CardTheme', style: theme.textTheme.titleMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Card Sample', style: theme.textTheme.bodyLarge),
              ),
            ),
            const Divider(height: 32),

            // 입력 필드 테마 샘플
            Text('InputDecorationTheme', style: theme.textTheme.titleMedium),
            TextField(
              decoration: InputDecoration(
                labelText: '입력 필드',
                hintText: '여기에 입력하세요',
              ),
            ),
            const Divider(height: 32),

            // 컬러 샘플
            Text('ColorScheme 샘플', style: theme.textTheme.titleMedium),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _colorBox('Primary', colorScheme.primary),
                _colorBox('Secondary', colorScheme.secondary),
                _colorBox('Error', colorScheme.error),
                _colorBox('Surface', colorScheme.surface),
                _colorBox('Background', colorScheme.surface),
                _colorBox('On Primary', colorScheme.onPrimary),
                _colorBox('On Surface', colorScheme.onSurface),
                _colorBox('On Background', colorScheme.onSurface),
              ],
            ),
            const Divider(height: 32),

            // 아이콘 샘플
            Text('IconTheme', style: theme.textTheme.titleMedium),
            Row(
              children: [
                Icon(Icons.star, color: theme.iconTheme.color, size: 32),
                const SizedBox(width: 12),
                Icon(Icons.favorite, color: colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Icon(Icons.error, color: colorScheme.error, size: 32),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 컬러 샘플 박스 위젯
  Widget _colorBox(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
