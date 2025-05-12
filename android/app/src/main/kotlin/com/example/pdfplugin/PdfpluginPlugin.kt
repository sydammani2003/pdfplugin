package com.example.pdfplugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

class PdfpluginPlugin : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
            "native_pdf_view",
            PdfViewFactory(binding.binaryMessenger)
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}
}
