import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../provider/aptitude_provider.dart';
import '../widgets/master_portfolio_chart.dart';
import '../../domain/model/aptitude_result.dart';

class AptitudeResultScreen extends StatelessWidget {
  /// 이 화면이 '나의 결과'를 보여주는지, '다른 성향'을 보여주는지 구분하는 플래그
  final bool isMyResult;

  const AptitudeResultScreen({super.key, this.isMyResult = true});

  @override
  Widget build(BuildContext context) {
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
        // ✅ [수정] isMyResult 값에 따라 제목을 동적으로 변경
        title: Text(isMyResult ? '나의 투자 성향 결과' : result.typeName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (상단 UI는 동일)
            Text(
              result.typeName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              result.typeDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
            ),
            const SizedBox(height: 48),
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
            _buildSectionTitle('이런 교육은 어때요?'),
            const SizedBox(height: 24),
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

            // ✅ [수정] '나의 결과'를 볼 때만 하단 버튼들이 보이도록 처리
            if (isMyResult) ...[
              ElevatedButton(
                onPressed: () {
                  // ✅ [수정] 다른 성향 목록 보기 화면으로 이동하는 기능 구현
                  context.push(AppRoutes.aptitudeTypesList);
                },
                child: const Text('다른 성향 보러가기'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // 재검사를 위해 퀴즈 화면으로 이동
                  context.push(AppRoutes.aptitudeQuiz);
                },
                child: const Text('재검사하기'),
              ),
            ]
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
