// Screen for viewing PDFs from local assets
// Handles loading, searching, and annotations for local PDF files

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widget/pdf_search_overlay.dart';
import '../widget/error_view.dart';
import '../flutter_pdf_viewer_plugin.dart';

class LocalPdfViewerScreen extends StatefulWidget {
  const LocalPdfViewerScreen({super.key});

  @override
  State<LocalPdfViewerScreen> createState() => _LocalPdfViewerScreenState();
}

class _LocalPdfViewerScreenState extends State<LocalPdfViewerScreen> {
  final String filePath =
      'assets/pdfs/Updated_Passport_application_Narayana.pdf';
  bool _pdfExists = false;
  String _errorMessage = '';
  String? _searchQuery;
  int _totalMatches = 0;
  int _currentMatchIndex = 0;
  String? _annotationMode; // "draw", "highlight", "erase"
  int _annotationColor = 0xFFFF0000;
  double _annotationStrokeWidth = 6.0;

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

  void _showSearchDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Text'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter text to search',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = textController.text.trim();
              if (query.isNotEmpty) {
                setState(() {
                  _searchQuery = query;
                  _currentMatchIndex = 0;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = null;
      _totalMatches = 0;
      _currentMatchIndex = 0;
    });
  }

  void _navigateToMatch(int index) {
    if (index >= 0 && index < _totalMatches) {
      setState(() {
        _currentMatchIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local PDF Viewer'),
        actions: [
          if (_searchQuery != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'draw' ||
                    value == 'highlight' ||
                    value == 'erase') {
                  _annotationMode = value;
                } else if (value == 'clear') {
                  _annotationMode = null;
                  // Clear annotations via method channel
                  // Use a key or state management to call clearAnnotations on NativePdfView
                } else {
                  _annotationMode = null;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'draw', child: Text('Draw')),
              const PopupMenuItem(value: 'highlight', child: Text('Highlight')),
              const PopupMenuItem(value: 'erase', child: Text('Erase')),
              // const PopupMenuItem(value: 'clear', child: Text('Clear All')),
              // const PopupMenuItem(value: 'none', child: Text('Disable Annotation')),
            ],
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _pdfExists
          ? FloatingActionButton(
              onPressed: _showSearchDialog,
              child: const Icon(Icons.search),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_pdfExists) {
      return Stack(
        children: [
          _buildPdfView(),
          if (_searchQuery != null) PdfSearchOverlay(
            totalMatches: _totalMatches,
            currentMatchIndex: _currentMatchIndex,
            onNavigate: _navigateToMatch,
          ),
        ],
      );
    } else {
      return ErrorView(errorMessage: _errorMessage, onRetry: _checkAssetExists);
    }
  }

  Widget _buildPdfView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: NativePdfView(
        filePath: filePath,
        searchQuery: _searchQuery,
        currentMatchIndex: _currentMatchIndex,
        onSearchResultsChanged: (total, error) {
          setState(() {
            _totalMatches = total;
            if (total == 0 && _searchQuery != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No matching text found')),
              );
            }
          });
        },
        annotationMode: _annotationMode,
        annotationColor: _annotationColor,
        annotationStrokeWidth: _annotationStrokeWidth,
        enableTextSearch: true,
        enablePanAndZoom: true,
        enableAnnotations: true,
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
}