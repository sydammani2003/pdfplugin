import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativePdfView extends StatelessWidget {
  final String filePath;

  const NativePdfView({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only supported on Android for now
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'native_pdf_view',
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'filePath': filePath,
        },
        creationParamsCodec: const StandardMessageCodec(),
        // Make sure the view takes all available space
        gestureRecognizers: const {}, // Let the native view handle all gestures
      );
    }

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