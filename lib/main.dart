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
      home: const PdfViewerHomeScreen(),
    );
  }
}

class PdfViewerHomeScreen extends StatelessWidget {
  const PdfViewerHomeScreen({super.key});

  // Define your PDF URL directly here
  final String pdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              'View Local PDF',
              'Open a PDF from your app assets',
              Icons.insert_drive_file,
              () => _openLocalPdf(context),
            ),
            const SizedBox(height: 16),
            _buildCard(
              'View PDF from URL',
              'Open a PDF from the internet',
              Icons.cloud_download,
              () => _openUrlPdf(context, pdfUrl), // Directly pass the URL here
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLocalPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalPdfViewerScreen(),
      ),
    );
  }

  // This method is no longer needed
  // void _openUrlInputDialog(BuildContext context) { ... }

  void _openUrlPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlinePdfViewerScreen(url: url),
      ),
    );
  }
}

class LocalPdfViewerScreen extends StatefulWidget {
  const LocalPdfViewerScreen({super.key});

  @override
  State<LocalPdfViewerScreen> createState() => _LocalPdfViewerScreenState();
}

class _LocalPdfViewerScreenState extends State<LocalPdfViewerScreen> {
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
        title: const Text('Local PDF Viewer'),
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
      child: NativePdfView(
        filePath: filePath,
        placeholder: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading PDF from assets...'),
            ],
          ),
        ),
      ),
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

class OnlinePdfViewerScreen extends StatelessWidget {
  final String url;

  const OnlinePdfViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online PDF Viewer'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: NativePdfView(
          url: url,
          placeholder: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading and loading PDF...'),
              ],
            ),
          ),
          errorBuilder: (error) => Center(
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
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}