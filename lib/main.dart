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
      debugShowCheckedModeBanner: false,
      title: 'Native PDF Viewer Plugin Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PdfViewerScreen(),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final String filePath = 'assets/pdfs/Updated_Passport_application_Narayana.pdf';
  bool _pdfExists = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAssetExists();
  }

  Future<void> _checkAssetExists() async {
    try {
      // Try to load the asset to verify it exists
      final bytes = await rootBundle.load(filePath);
      setState(() {
        _pdfExists = true;
      });
      debugPrint('PDF asset exists! Size: ${bytes.lengthInBytes} bytes');
    } catch (e) {
      setState(() {
        _pdfExists = false;
        _errorMessage = 'PDF asset not found: $e';
      });
      debugPrint('PDF asset not found: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native PDF Viewer'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pdfExists) {
      return _buildPdfView();
    } else {
      return _buildErrorView();
    }
  }

  Widget _buildPdfView() {
    // Use the full screen for the PDF view
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: NativePdfView(filePath: filePath),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Error Loading PDF',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkAssetExists,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}