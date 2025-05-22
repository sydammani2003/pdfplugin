// Screen for viewing PDFs from online URLs
// Handles downloading, caching, and searching for online PDF files

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/pdf_search_overlay.dart';
import '../flutter_pdf_viewer_plugin.dart';

class OnlinePdfViewerScreen extends StatefulWidget {
  final String url;

  const OnlinePdfViewerScreen({super.key, required this.url});

  @override
  State<OnlinePdfViewerScreen> createState() => _OnlinePdfViewerScreenState();
}

class _OnlinePdfViewerScreenState extends State<OnlinePdfViewerScreen> {
  String? _searchQuery;
  int _totalMatches = 0;
  int _currentMatchIndex = 0;

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
  void dispose() {
    _clearCache();
    super.dispose();
  }

  Future<void> _clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final files = cacheDir.listSync();

      for (var file in files) {
        if (file.path.contains('pdf_')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online PDF Viewer'),
        actions: _searchQuery != null
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          _buildPdfView(),
          if (_searchQuery != null) PdfSearchOverlay(
            totalMatches: _totalMatches,
            currentMatchIndex: _currentMatchIndex,
            onNavigate: _navigateToMatch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildPdfView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: NativePdfView(
        url: widget.url,
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
    );
  }
}