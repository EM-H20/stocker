import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_routes.dart';

/// 라우팅 에러 시 표시되는 페이지
class ErrorPage extends StatelessWidget {
  final String? errorPath;

  const ErrorPage({super.key, this.errorPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('페이지 오류'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('🔙 [ERROR_PAGE] 뒤로가기 버튼 클릭 - 홈으로 이동');
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontSize: 16.sp),
            ),
            const SizedBox(height: 8),
            Text(
              '경로: ${errorPath ?? "알 수 없음"}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontSize: 12.sp),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('🏠 [ERROR_PAGE] 홈으로 돌아가기 버튼 클릭 - MainDashboardScreen으로 이동');
                debugPrint('📍 [ERROR_PAGE] 이동 경로: ${AppRoutes.home}');
                context.go(AppRoutes.home);
              },
              icon: const Icon(Icons.home, size: 20),
              label: Text(
                '홈으로 돌아가기',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
