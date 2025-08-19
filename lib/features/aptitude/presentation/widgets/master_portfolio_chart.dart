// features/aptitude/presentation/widgets/master_portfolio_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 투자 거장의 포트폴리오를 보여주는 파이 차트 위젯
class MasterPortfolioChart extends StatelessWidget {
  final Map<String, double> portfolio;
  const MasterPortfolioChart({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    // 차트에 사용할 색상 목록
    final List<Color> colorList = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.yellow.shade700,
    ];

    int colorIndex = 0;
    final chartSections = portfolio.entries.map((entry) {
      final color = colorList[colorIndex % colorList.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: chartSections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 범례
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(portfolio.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colorList[index % colorList.length],
                ),
                const SizedBox(width: 6),
                Text(portfolio.keys.elementAt(index)),
              ],
            );
          }),
        ),
      ],
    );
  }
}