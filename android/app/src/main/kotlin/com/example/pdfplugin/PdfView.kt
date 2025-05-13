package com.example.pdfplugin

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PaintFlagsDrawFilter
import android.graphics.Rect
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import java.io.File
import kotlin.math.min

class PdfView(context: Context) : View(context) {
    private var renderer: PdfRenderer? = null
    private var page: PdfRenderer.Page? = null
    private var scaleFactor = 1.0f
    private val scaleDetector = ScaleGestureDetector(context, ScaleListener())
    
    // Bitmap cache for performance
    private var cachedBitmap: Bitmap? = null
    private var cacheScale = 0f
    
    // High-quality paint settings
    private val paint = Paint().apply {
        isAntiAlias = true
        isFilterBitmap = true
        isDither = true
        // Additional quality flags
        flags = Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG or Paint.DITHER_FLAG
    }
    
    // Render scale factor - increase this for higher quality
    // 4x or even 8x for ultra-high quality (but uses more memory)
    private var renderScale = 4
    
    // Maximum bitmap size to prevent out of memory errors
    private val maxBitmapSize = 4096 // Typical GPU texture size limit

    fun openPdf(filePath: String) {
        val file = File(filePath)
        val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        renderer = PdfRenderer(fd)
        page = renderer?.openPage(0)
        // Clear cache when opening new PDF
        cachedBitmap?.recycle()
        cachedBitmap = null
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        page?.let { currentPage ->
            // Set the highest quality draw filter
            canvas.setDrawFilter(PaintFlagsDrawFilter(0, 
                Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG or Paint.DITHER_FLAG))
            
            // Calculate actual render scale based on current zoom
            val effectiveScale = scaleFactor * renderScale
            
            // Check if we need to recreate the cached bitmap
            if (cachedBitmap == null || cacheScale != effectiveScale) {
                // Recycle old bitmap
                cachedBitmap?.recycle()
                
                // Calculate render dimensions
                var renderWidth = (currentPage.width * effectiveScale).toInt()
                var renderHeight = (currentPage.height * effectiveScale).toInt()
                
                // Constrain to maximum size to prevent memory issues
                if (renderWidth > maxBitmapSize || renderHeight > maxBitmapSize) {
                    val scale = min(
                        maxBitmapSize.toFloat() / renderWidth,
                        maxBitmapSize.toFloat() / renderHeight
                    )
                    renderWidth = (renderWidth * scale).toInt()
                    renderHeight = (renderHeight * scale).toInt()
                }
                
                // Create high-resolution bitmap
                cachedBitmap = Bitmap.createBitmap(renderWidth, renderHeight, Bitmap.Config.ARGB_8888)
                
                // Create a matrix for scaling
                val matrix = Matrix()
                matrix.setScale(
                    renderWidth.toFloat() / currentPage.width,
                    renderHeight.toFloat() / currentPage.height
                )
                
                // Render PDF page to high-resolution bitmap
                currentPage.render(cachedBitmap!!, null, matrix, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                
                cacheScale = effectiveScale
            }
            
            // Draw the cached high-resolution bitmap
            cachedBitmap?.let { bitmap ->
                canvas.save()
                
                // Calculate destination size
                val destWidth = currentPage.width * scaleFactor
                val destHeight = currentPage.height * scaleFactor
                
                // Create destination rectangle
                val destRect = Rect(0, 0, destWidth.toInt(), destHeight.toInt())
                
                // Draw with high-quality settings
                canvas.drawBitmap(bitmap, null, destRect, paint)
                
                canvas.restore()
            }
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val result = scaleDetector.onTouchEvent(event)
        // Only invalidate if scale changed
        if (result) {
            invalidate()
        }
        return true
    }

    private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScale(detector: ScaleGestureDetector): Boolean {
            val oldScale = scaleFactor
            scaleFactor *= detector.scaleFactor
            scaleFactor = scaleFactor.coerceIn(0.5f, 10.0f) // Increased max zoom
            
            // Clear cache if scale changed significantly
            if (kotlin.math.abs(scaleFactor - oldScale) > 0.1f) {
                cachedBitmap?.recycle()
                cachedBitmap = null
            }
            
            return scaleFactor != oldScale
        }
    }
    
    // Clean up resources
    fun onDestroy() {
        cachedBitmap?.recycle()
        cachedBitmap = null
        page?.close()
        renderer?.close()
    }
    
    // Optional: Method to adjust render quality dynamically
    fun setRenderQuality(quality: RenderQuality) {
        cachedBitmap?.recycle()
        cachedBitmap = null
        when (quality) {
            RenderQuality.LOW -> renderScale = 1
            RenderQuality.MEDIUM -> renderScale = 2
            RenderQuality.HIGH -> renderScale = 4
            RenderQuality.ULTRA -> renderScale = 8
        }
        invalidate()
    }
    
    enum class RenderQuality {
        LOW, MEDIUM, HIGH, ULTRA
    }
}