import 'package:flutter/material.dart';

class AptitudeInitialScreen extends StatelessWidget {
  const AptitudeInitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성향분석탭'),
      ),
      body: const Center(
        child: Text(
          '성향분석탭',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}