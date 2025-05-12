import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'flutter_pdf_viewer_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native PDF Viewer Plugin Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Native PDF Viewer')),
        body: const PdfScreen(),
      ),
    );
  }
}

class PdfScreen extends StatelessWidget {
  const PdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // First, let's verify the asset exists
    _checkAssetExists();

    const filePath = 'assets/pdfs/Get_Started_With_Smallpdf.pdf';

    return NativePdfView(filePath: filePath);
  }

  Future<void> _checkAssetExists() async {
    try {
      // Try to load the asset to verify it exists
      final bytes = await rootBundle
          .load('assets/pdfs/Get_Started_With_Smallpdf.pdf');
      print('PDF asset exists! Size: ${bytes.lengthInBytes} bytes');
    } catch (e) {
      print('PDF asset not found: $e');
    }
  }
}
