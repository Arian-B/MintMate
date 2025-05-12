import 'package:flutter/material.dart';

class DocumentAnalysisScreen extends StatelessWidget {
  const DocumentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Analysis'),
      ),
      body: const Center(
        child: Text('Document Analysis Screen'),
      ),
    );
  }
} 