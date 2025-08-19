
// features/aptitude/presentation/screens/aptitude_result_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/aptitude_provider.dart';
import '../widgets/master_portfolio_chart.dart';
import '../../domain/model/aptitude_result.dart';

class AptitudeResultScreen extends StatelessWidget {
  const AptitudeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider로부터 현재 표시할 결과 데이터를 가져옴
    // 검사 직후에는 currentResult, '내 결과 보기' 시에는 myResult를 사용
    final AptitudeResult? result = context.select(
      (AptitudeProvider p) => p.currentResult ?? p.myResult
    );

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('분석 결과가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 투자 성향 결과'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 성향 타입 이름
            Text(
              result.typeName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 2. 성향 설명
            Text(
              result.typeDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
            ),
            const SizedBox(height: 48),

            // 3. 추천 투자 거장
            _buildSectionTitle('나와 비슷한 성향의 투자 거장'),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(result.master.imageUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(result.master.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(result.master.description, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    const Text('포트폴리오 예시', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    MasterPortfolioChart(portfolio: result.master.portfolio),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // 4. 추천 교육 과정
            _buildSectionTitle('이런 교육은 어때요?'),
            const SizedBox(height: 24),
            // TODO: 추천 교육 위젯 구현
            ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text('초보자를 위한 주식 용어 마스터'),
              subtitle: const Text('기초부터 탄탄하게 시작해요'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.show_chart, color: Colors.green),
              title: const Text('차트 분석 심화 과정'),
              subtitle: const Text('기술적 분석의 모든 것'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const SizedBox(height: 48),

            // 5. 하단 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 다른 성향 목록 보기 화면으로 이동
              },
              child: const Text('다른 성향 보러가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}
