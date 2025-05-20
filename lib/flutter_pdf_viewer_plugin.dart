// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativePdfView extends StatefulWidget {
  /// Path to the PDF file (local asset or file path)
  final String? filePath;

  /// URL of the PDF to load from the internet
  final String? url;

  /// Optional placeholder widget to show while loading
  final Widget? placeholder;

  /// Optional error widget to show when PDF loading fails
  final Widget Function(String error)? errorBuilder;

  /// Search query to highlight in the PDF
  final String? searchQuery;

  /// Current index of the search match to highlight
  final int currentMatchIndex;

  /// Callback for search results changes
  final Function(int totalMatches, String? error)? onSearchResultsChanged;

  const NativePdfView({
    super.key,
    this.filePath,
    this.url,
    this.placeholder,
    this.errorBuilder,
    this.searchQuery,
    this.currentMatchIndex = 0,
    this.onSearchResultsChanged,
  })  : assert(filePath != null || url != null,
            'Either filePath or url must be provided');

  @override
  State<NativePdfView> createState() => _NativePdfViewState();
}

class _NativePdfViewState extends State<NativePdfView> {
  bool _isLoading = true;
  String? _errorMessage;
  MethodChannel? _channel;
  int? _platformViewId;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _errorMessage = null;
  }

  @override
  void didUpdateWidget(covariant NativePdfView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If search query changed, update the native view
    if (widget.searchQuery != oldWidget.searchQuery) {
      _performSearch();
    }

    // If current match index changed, navigate to it
    if (widget.currentMatchIndex != oldWidget.currentMatchIndex &&
        widget.searchQuery != null) {
      _navigateToMatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there's an error, show the error widget
    if (_errorMessage != null) {
      return widget.errorBuilder != null
          ? widget.errorBuilder!(_errorMessage!)
          : _buildDefaultErrorView();
    }

    // Only supported on Android for now
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Stack(
        children: [
          AndroidView(
            viewType: 'native_pdf_view',
            layoutDirection: TextDirection.ltr,
            creationParams: {
              if (widget.filePath != null) 'filePath': widget.filePath,
              if (widget.url != null) 'url': widget.url,
            },
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
            // Make sure the view takes all available space
            gestureRecognizers: const {}, // Let the native view handle all gestures
          ),
          if (_isLoading && widget.placeholder != null) widget.placeholder!,
          if (_isLoading && widget.placeholder == null)
            _buildDefaultLoadingView(),
        ],
      );
    }

    return _buildUnsupportedPlatformView();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    _channel = MethodChannel('native_pdf_view_$id');

    // Set up method call handler for events from native side
    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPdfLoaded':
          setState(() {
            _isLoading = false;
          });
          // Perform initial search if query exists
          if (widget.searchQuery != null) {
            _performSearch();
          }
          break;
        case 'onPdfError':
          final error = call.arguments as String;
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
          break;
        case 'onSearchResults':
          final results = Map<String, dynamic>.from(call.arguments);
          final totalMatches = results['totalMatches'] as int;
          final error = results['error'] as String?;
          widget.onSearchResultsChanged?.call(totalMatches, error);
          break;
      }
    });
  }

  void _performSearch() {
    if (_channel == null || widget.searchQuery == null) return;

    _channel!.invokeMethod('searchText', {
      'query': widget.searchQuery,
    });
  }

  void _navigateToMatch() {
    if (_channel == null || widget.searchQuery == null) return;

    _channel!.invokeMethod('navigateToMatch', {
      'index': widget.currentMatchIndex,
    });
  }

  Widget _buildDefaultLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultErrorView() {
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
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedPlatformView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Platform not supported',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This PDF viewer is currently only available on Android.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
