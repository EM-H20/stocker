import 'package:flutter/material.dart';

class AptitudeScreen extends StatelessWidget {
  const AptitudeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '성향분석',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
