import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../provider/aptitude_provider.dart';

/// 모든 투자 성향 종류를 보여주는 목록 화면
class AptitudeTypesListScreen extends StatefulWidget {
  const AptitudeTypesListScreen({super.key});

  @override
  State<AptitudeTypesListScreen> createState() => _AptitudeTypesListScreenState();
}

class _AptitudeTypesListScreenState extends State<AptitudeTypesListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 빌드될 때, Provider를 통해 모든 성향 타입 목록을 가져옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AptitudeProvider>().fetchAllTypes();
    });
  }

  // 각 성향 타입에 맞는 아이콘을 매핑하는 함수
  IconData _getIconForType(String typeCode) {
    switch (typeCode) {
      case 'STABLE':
        return Icons.shield_outlined;
      case 'AGGRESSIVE':
        return Icons.trending_up;
      case 'NEUTRAL':
        return Icons.balance;
      case 'LONG_TERM':
        return Icons.hourglass_bottom;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AptitudeProvider>();
    final allTypes = provider.allTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('모든 투자 성향 둘러보기'),
      ),
      body: provider.isLoading
          ? Center(child: SpinKitFadingCircle(color: Theme.of(context).colorScheme.primary))
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: allTypes.length,
              itemBuilder: (context, index) {
                final type = allTypes[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                      child: Icon(
                        _getIconForType(type.typeCode),
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.r,
                      ),
                    ),
                    title: Text(
                      type.typeName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    subtitle: Text(
                      type.description,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16.r, color: Theme.of(context).iconTheme.color),
                    onTap: () async {
                      final success = await provider.fetchResultByType(type.typeCode);
                      if (mounted && success) {
                        // 상세 결과 화면으로 이동할 때, '나의 결과'가 아님을 알림 (extra: false)
                        context.push(AppRoutes.aptitudeResult, extra: false);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
