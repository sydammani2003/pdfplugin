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
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'native_pdf_view',
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'filePath': filePath,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return const Center(
      child: Text('Platform not supported'),
    );
  }
}
