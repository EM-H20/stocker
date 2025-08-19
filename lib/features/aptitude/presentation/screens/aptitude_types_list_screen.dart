import 'package:flutter/material.dart';
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
    // 화면이 처음 빌드될 때, 모든 성향 타입 목록을 가져옵니다.
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
          ? const Center(child: SpinKitFadingCircle(color: Colors.blue))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: allTypes.length,
              itemBuilder: (context, index) {
                final type = allTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        _getIconForType(type.typeCode),
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      type.typeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      type.description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final success = await provider.fetchResultByType(type.typeCode);
                      if (mounted && success) {
                        // 상세 결과 화면으로 이동
                        context.push(AppRoutes.aptitudeResult);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}