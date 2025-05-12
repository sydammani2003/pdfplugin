package com.example.pdfplugin

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class PdfViewWrapper(private val context: Context, filePath: String) : PlatformView {
    private val pdfView = PdfView(context)
    private val TAG = "PdfViewWrapper"

    init {
        Log.d(TAG, "Initializing with filePath: $filePath")
        
        // First, let's list all available assets to debug
        try {
            val assetManager = context.assets
            Log.d(TAG, "Listing all assets in root:")
            assetManager.list("")?.forEach { asset ->
                Log.d(TAG, "Root asset: $asset")
            }
            
            Log.d(TAG, "Listing all assets in pdfs folder:")
            assetManager.list("pdfs")?.forEach { asset ->
                Log.d(TAG, "PDF asset: $asset")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error listing assets", e)
        }
        
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
    }

    private fun copyAssetToTempFile(assetPath: String): String {
        // Try multiple path variations to find the asset
        val pathsToTry = listOf(
            assetPath.removePrefix("assets/"),
            assetPath,
            "flutter_assets/$assetPath",
            "flutter_assets/${assetPath.removePrefix("assets/")}"
        )
        
        val tempFile = File(context.cacheDir, "temp_pdf_${System.currentTimeMillis()}.pdf")
        
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
    }
}