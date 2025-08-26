import 'package:flutter/material.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: provider.isLoading
            ? const Center(child: SpinKitFadingCircle(color: Colors.blue))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.insights,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '나에게 꼭 맞는 투자 스타일 찾기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '몇 가지 간단한 질문을 통해\n당신의 투자 성향을 진단해 드립니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              // ✅ [수정] 검사 화면으로 이동
                              context.push(AppRoutes.aptitudeQuiz);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              provider.hasPreviousResult ? '재검사하고 새로운 성향 찾기' : '투자 성향 분석 시작하기',
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
                  const SizedBox(height: 24),
                  if (provider.hasPreviousResult)
                    TextButton(
                      onPressed: () {
                        // ✅ [수정] 결과 화면으로 이동
                        // currentResult를 null로 만들어 myResult를 보도록 함
                        provider.currentResult = null; 
                        context.push(AppRoutes.aptitudeResult);
                      },
                      child: const Text(
                        '이전 결과 다시보기',
                        style: TextStyle(
                          fontSize: 16,
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