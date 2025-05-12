package com.example.pdfplugin

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class PdfViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val filePath = (args as? Map<*, *>)?.get("filePath") as? String ?: ""
        Log.d("PdfViewFactory", "Creating PdfViewWrapper with filePath: $filePath")
        return PdfViewWrapper(context, filePath)
    }
}