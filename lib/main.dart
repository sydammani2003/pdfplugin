import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfplugin/Mdarticle.dart';
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
            const SizedBox(height: 16),
            _buildCard(
              'View Article',
              'Open a Markdown Article',
              Icons.cloud_download,
              () =>_openMdAr(context) , // Directly pass the URL here
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

  void _openUrlPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlinePdfViewerScreen(url: url),
      ),
    );
  }

  void _openMdAr(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mdarticle(),
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
                if (value == 'draw' || value == 'highlight' || value == 'erase') {
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
              const PopupMenuItem(value: 'clear', child: Text('Clear All')),
              const PopupMenuItem(value: 'none', child: Text('Disable Annotation')),
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
          if (_searchQuery != null) _buildSearchOverlay(),
        ],
      );
    } else {
      return _buildErrorView();
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
        // Add a key and expose clearAnnotations if you want to clear from Flutter
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

  Widget _buildSearchOverlay() {
    if (_totalMatches > 0) {
      return Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentMatchIndex + 1} / $_totalMatches',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _totalMatches > 1
                      ? () => _navigateToMatch(_currentMatchIndex - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  onPressed: _totalMatches > 1
                      ? () => _navigateToMatch(_currentMatchIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
          if (_searchQuery != null) _buildSearchOverlay(),
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

  Widget _buildSearchOverlay() {
    if (_totalMatches > 0) {
      return Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentMatchIndex + 1} / $_totalMatches',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  onPressed: _totalMatches > 1
                      ? () => _navigateToMatch(_currentMatchIndex - 1)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  onPressed: _totalMatches > 1
                      ? () => _navigateToMatch(_currentMatchIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}