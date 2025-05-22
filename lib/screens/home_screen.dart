// Home screen that displays options to view PDFs from different sources
// Provides navigation to local PDF viewer and online PDF viewer

import 'package:flutter/material.dart';
import 'local_pdf_viewer_screen.dart';
import 'online_pdf_viewer_screen.dart';
import '../widgets/option_card.dart';

class PdfViewerHomeScreen extends StatefulWidget {
  const PdfViewerHomeScreen({super.key});

  @override
  State<PdfViewerHomeScreen> createState() => _PdfViewerHomeScreenState();
}

class _PdfViewerHomeScreenState extends State<PdfViewerHomeScreen> {
  // Define your PDF URL directly here
  final String pdfUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

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
            OptionCard(
              title: 'View Local PDF',
              subtitle: 'Open a PDF from your app assets',
              icon: Icons.insert_drive_file,
              onTap: () => _openLocalPdf(context),
            ),
            const SizedBox(height: 16),
            OptionCard(
              title: 'View PDF from URL',
              subtitle: 'Open a PDF from the internet',
              icon: Icons.cloud_download,
              onTap: () => _openUrlPdf(context, pdfUrl),
            ),
          ],
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

  void _openUrlPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlinePdfViewerScreen(url: url),
      ),
    );
  }
}