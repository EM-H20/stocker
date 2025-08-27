// features/aptitude/presentation/widgets/master_portfolio_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        radius: 80.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: PieChart(
            PieChartData(
              sections: chartSections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40.r,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // 범례
        Wrap(
          spacing: 16.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: List.generate(portfolio.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  color: colorList[index % colorList.length],
                ),
                SizedBox(width: 6.w),
                Text(
                  portfolio.keys.elementAt(index),
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}