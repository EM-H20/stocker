import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../provider/aptitude_provider.dart';

/// 모든 투자 성향 종류를 보여주는 목록 화면
class AptitudeTypesListScreen extends StatefulWidget {
  const AptitudeTypesListScreen({super.key});

  @override
  State<AptitudeTypesListScreen> createState() =>
      _AptitudeTypesListScreenState();
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
    switch (typeCode.toUpperCase()) {
      case 'STABLE':
      case 'CONSERVATIVE':
        return Icons.shield_outlined;
      case 'AGGRESSIVE':
        return Icons.trending_up;
      case 'NEUTRAL':
      case 'BALANCED':
        return Icons.balance;
      case 'LONG_TERM':
      case 'GROWTH':
        return Icons.hourglass_bottom;
      case 'DIVIDEND':
        return Icons.account_balance;
      default:
        return Icons.help_outline;
    }
  }

  // 각 성향 타입에 맞는 색상을 매핑하는 함수
  Color _getColorForType(String typeCode, BuildContext context) {
    switch (typeCode.toUpperCase()) {
      case 'STABLE':
      case 'CONSERVATIVE':
        return Colors.green;
      case 'AGGRESSIVE':
        return Colors.red;
      case 'NEUTRAL':
      case 'BALANCED':
        return Colors.blue;
      case 'LONG_TERM':
      case 'GROWTH':
        return Colors.purple;
      case 'DIVIDEND':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
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
          ? const Center(
              child: LoadingWidget(
                message: '투자 성향 유형을 불러오는 중...',
              ))
          : allTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.r,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '성향 목록을 불러올 수 없습니다',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AptitudeProvider>().fetchAllTypes();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: allTypes.length,
                  itemBuilder: (context, index) {
                    final type = allTypes[index];
                    final typeColor = _getColorForType(type.typeCode, context);
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 16.h),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h, horizontal: 20.w),
                        leading: CircleAvatar(
                          radius: 24.r,
                          backgroundColor: typeColor.withAlpha(25),
                          child: Icon(
                            _getIconForType(type.typeCode),
                            color: typeColor,
                            size: 28.r,
                          ),
                        ),
                        title: Text(
                          type.typeName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            type.description,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () async {
                          debugPrint('🎯 [APTITUDE_TYPES] ${type.typeName} 클릭됨');
                          debugPrint('📝 [APTITUDE_TYPES] TypeCode: ${type.typeCode}');
                          
                          // 로딩 표시
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(20.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const LoadingWidget.small(
                                        message: '분석 중...',
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        '${type.typeName} 정보를 불러오는 중...',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          try {
                            // currentResult 초기화 (이전 결과 제거)
                            provider.clearCurrentResult();
                            
                            // 해당 성향의 상세 정보 가져오기
                            final success = await provider.fetchResultByType(type.typeCode);
                            
                            // 로딩 다이얼로그 닫기
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            
                            if (success && context.mounted) {
                              debugPrint('✅ [APTITUDE_TYPES] 데이터 로드 성공, 화면 이동');
                              // 상세 결과 화면으로 이동 (다른 성향 보기 모드)
                              context.push(AppRoutes.aptitudeResult, extra: false);
                            } else if (context.mounted) {
                              debugPrint('❌ [APTITUDE_TYPES] 데이터 로드 실패');
                              // 에러 처리
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ?? '정보를 불러오는데 실패했습니다'
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('💥 [APTITUDE_TYPES] 예외 발생: $e');
                            // 로딩 다이얼로그 닫기
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('오류가 발생했습니다: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}