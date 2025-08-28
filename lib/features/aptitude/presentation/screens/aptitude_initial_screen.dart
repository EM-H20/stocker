import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../provider/aptitude_provider.dart';

class AptitudeInitialScreen extends StatefulWidget {
  const AptitudeInitialScreen({super.key});

  @override
  State<AptitudeInitialScreen> createState() => _AptitudeInitialScreenState();
}

class _AptitudeInitialScreenState extends State<AptitudeInitialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AptitudeProvider>().checkPreviousResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AptitudeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 투자 성향 분석'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.main);
          },
        ),
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: provider.isLoading
            ? Center(
                child: SpinKitFadingCircle(
                    color: Theme.of(context).colorScheme.primary))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.insights,
                            size: 60.r,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            '나에게 꼭 맞는 투자 스타일 찾기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '몇 가지 간단한 질문을 통해\n당신의 투자 성향을 진단해 드립니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 40.h),
                          ElevatedButton(
                            onPressed: () {
                              // ✅ [수정] 검사 화면으로 이동
                              context.push(AppRoutes.aptitudeQuiz);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              provider.hasPreviousResult
                                  ? '재검사하고 새로운 성향 찾기'
                                  : '투자 성향 분석 시작하기',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (provider.hasPreviousResult)
                    TextButton(
                      onPressed: () {
                        // ✅ [수정] 결과 화면으로 이동
                        // currentResult를 null로 만들어 myResult를 보도록 함
                        provider.currentResult = null;
                        context.push(AppRoutes.aptitudeResult);
                      },
                      child: Text(
                        '이전 결과 다시보기',
                        style: TextStyle(
                          fontSize: 16.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
