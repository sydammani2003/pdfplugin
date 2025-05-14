package com.example.pdfplugin

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import java.util.concurrent.Executors
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class PdfViewWrapper(
    private val context: Context, 
    private val id: Int, 
    private val args: Map<String, Any>?, 
    private val messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformView {
    private val pdfView = PdfView(context)
    private val TAG = "PdfViewWrapper"
    private val methodChannel = MethodChannel(messenger, "native_pdf_view_$id")
    private val executorService = Executors.newSingleThreadExecutor()

    init {
        Log.d(TAG, "Initializing PdfViewWrapper")
        
        val filePath = args?.get("filePath") as? String
        val url = args?.get("url") as? String
        
        if (url != null) {
            loadFromUrl(url)
        } else if (filePath != null) {
            loadFromFilePath(filePath)
        } else {
            Log.e(TAG, "Neither filePath nor url provided")
            methodChannel.invokeMethod("onPdfError", "No PDF source specified")
        }
    }

    private fun loadFromFilePath(filePath: String) {
        Log.d(TAG, "Loading from filePath: $filePath")
        
        try {
            val actualPath = when {
                filePath.startsWith("assets/") -> {
                    // Handle Flutter asset files
                    copyAssetToTempFile(filePath)
                }
                filePath.startsWith("/") -> {
                    // Absolute path
                    filePath
                }
                else -> {
                    // Assume it's a relative path from app's files directory
                    "${context.filesDir}/$filePath"
                }
            }

            Log.d(TAG, "Opening PDF at: $actualPath")
            pdfView.openPdf(actualPath)
            methodChannel.invokeMethod("onPdfLoaded", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error loading PDF from file path", e)
            methodChannel.invokeMethod("onPdfError", "Failed to load PDF: ${e.message}")
        }
    }

    private fun loadFromUrl(url: String) {
        Log.d(TAG, "Loading from URL: $url")
        
        // Use a background thread for downloading
        executorService.execute {
            try {
                val tempFile = File(context.cacheDir, "pdf_${System.currentTimeMillis()}.pdf")
                
                // Download the file
                URL(url).openStream().use { input ->
                    FileOutputStream(tempFile).use { output ->
                        val buffer = ByteArray(4 * 1024) // 4K buffer
                        var read: Int
                        while (input.read(buffer).also { read = it } != -1) {
                            output.write(buffer, 0, read)
                        }
                        output.flush()
                    }
                }
                
                // Load the PDF on the main thread
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    try {
                        Log.d(TAG, "Opening downloaded PDF at: ${tempFile.absolutePath}")
                        pdfView.openPdf(tempFile.absolutePath)
                        methodChannel.invokeMethod("onPdfLoaded", null)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error opening downloaded PDF", e)
                        methodChannel.invokeMethod("onPdfError", "Failed to open PDF: ${e.message}")
                    }
                }
            } catch (e: IOException) {
                Log.e(TAG, "Error downloading PDF", e)
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    methodChannel.invokeMethod("onPdfError", "Failed to download PDF: ${e.message}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error", e)
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    methodChannel.invokeMethod("onPdfError", "Unexpected error: ${e.message}")
                }
            }
        }
    }

    private fun copyAssetToTempFile(assetPath: String): String {
        // Try multiple path variations to find the asset
        val pathsToTry = listOf(
            assetPath.removePrefix("assets/"),
            assetPath,
            "flutter_assets/$assetPath",
            "flutter_assets/${assetPath.removePrefix("assets/")}"
        )

        val tempFile = File(context.cacheDir, "temppdf${System.currentTimeMillis()}.pdf")

        for (path in pathsToTry) {
            try {
                Log.d(TAG, "Attempting to open asset at path: $path")
                val inputStream = context.assets.open(path)
                val outputStream = FileOutputStream(tempFile)

                inputStream.use { input ->
                    outputStream.use { output ->
                        input.copyTo(output)
                    }
                }

                Log.d(TAG, "Successfully copied asset from $path to: ${tempFile.absolutePath}")
                return tempFile.absolutePath
            } catch (e: Exception) {
                Log.w(TAG, "Failed to open asset at path: $path - ${e.message}")
            }
        }

        throw RuntimeException("Failed to find asset at any tried path. Original path: $assetPath")
    }

    override fun getView(): View = pdfView

    override fun dispose() {
        Log.d(TAG, "Disposing PdfViewWrapper")
        // Clean up resources when the view is disposed
        executorService.shutdown()
        (getView() as PdfView).onDestroy()
    }
}