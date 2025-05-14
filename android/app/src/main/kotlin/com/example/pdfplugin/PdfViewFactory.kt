package com.example.pdfplugin

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class PdfViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        Log.d("PdfViewFactory", "Creating PdfViewWrapper with args: $args")
        @Suppress("UNCHECKED_CAST")
        return PdfViewWrapper(context, id, args as? Map<String, Any>, messenger)
    }
}