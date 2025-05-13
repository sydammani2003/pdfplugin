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
import android.view.GestureDetector
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
    private val gestureDetector = GestureDetector(context, GestureListener())
    
    // For panning
    private var posX = 0f
    private var posY = 0f
    private var lastTouchX = 0f
    private var lastTouchY = 0f
    private var isDragging = false
    
    // Bitmap cache for performance
    private var cachedBitmap: Bitmap? = null
    private var cacheScale = 0f
    
    // Store PDF dimensions
    private var pdfWidth = 0
    private var pdfHeight = 0
    
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

    // Screen fit mode
    private var fitToScreen = true
    private var initialScaleFactor = 1.0f

    fun openPdf(filePath: String) {
        val file = File(filePath)
        val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        renderer = PdfRenderer(fd)
        page = renderer?.openPage(0)
        
        // Store PDF dimensions
        page?.let {
            pdfWidth = it.width
            pdfHeight = it.height
        }
        
        // Clear cache when opening new PDF
        cachedBitmap?.recycle()
        cachedBitmap = null
        
        // Reset position and scale
        posX = 0f
        posY = 0f
        scaleFactor = 1.0f
        
        invalidate()
    }
    
    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        
        // Calculate initial scale factor to fit the screen
        page?.let {
            val screenAspect = w.toFloat() / h.toFloat()
            val pageAspect = it.width.toFloat() / it.height.toFloat()
            
            initialScaleFactor = if (pageAspect > screenAspect) {
                // Fit to width
                w.toFloat() / it.width.toFloat()
            } else {
                // Fit to height
                h.toFloat() / it.height.toFloat()
            }
            
            // Apply initial scale if we're in fit to screen mode
            if (fitToScreen) {
                scaleFactor = initialScaleFactor
                
                // Center PDF on screen
                posX = (w - it.width * scaleFactor) / 2
                posY = (h - it.height * scaleFactor) / 2
                
                // Clear cache as scale changed
                cachedBitmap?.recycle()
                cachedBitmap = null
            }
        }
        
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
                
                // Apply translation for panning
                canvas.translate(posX, posY)
                
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
        // Let the gesture detectors handle the event
        scaleDetector.onTouchEvent(event)
        gestureDetector.onTouchEvent(event)
        
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                lastTouchX = event.x
                lastTouchY = event.y
                isDragging = true
            }
            
            MotionEvent.ACTION_MOVE -> {
                if (!scaleDetector.isInProgress && isDragging) {
                    val dx = event.x - lastTouchX
                    val dy = event.y - lastTouchY
                    
                    // Only allow panning when zoomed in
                    if (scaleFactor > initialScaleFactor * 0.95f) {
                        posX += dx
                        posY += dy
                        
                        // Apply constraints to prevent panning too far
                        constrainPan()
                        
                        invalidate()
                    }
                    
                    lastTouchX = event.x
                    lastTouchY = event.y
                }
            }
            
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isDragging = false
            }
        }
        
        return true
    }
    
    private fun constrainPan() {
        // Constrain panning to keep some part of the document visible
        page?.let {
            val scaledWidth = it.width * scaleFactor
            val scaledHeight = it.height * scaleFactor
            
            // Limit horizontal panning
            if (scaledWidth > width) {
                // Document wider than screen - constrain to keep some part visible
                posX = posX.coerceIn(-(scaledWidth - width / 2), width / 2.toFloat())
            } else {
                // Document narrower than screen - keep centered horizontally
                posX = (width - scaledWidth) / 2
            }
            
            // Limit vertical panning
            if (scaledHeight > height) {
                // Document taller than screen - constrain to keep some part visible
                posY = posY.coerceIn(-(scaledHeight - height / 2), height / 2.toFloat())
            } else {
                // Document shorter than screen - keep centered vertically
                posY = (height - scaledHeight) / 2
            }
        }
    }

    private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScale(detector: ScaleGestureDetector): Boolean {
            val oldScale = scaleFactor
            
            // Focus zoom on pinch center point
            val focusX = detector.focusX
            val focusY = detector.focusY
            
            // Save pre-scale values
            val unscaledFocusX = (focusX - posX) / oldScale
            val unscaledFocusY = (focusY - posY) / oldScale
            
            // Apply scale change
            scaleFactor *= detector.scaleFactor
            
            // Constrain scale
            scaleFactor = scaleFactor.coerceIn(initialScaleFactor * 0.5f, initialScaleFactor * 10.0f)
            
            // Recalculate position to zoom into focus point
            posX = focusX - unscaledFocusX * scaleFactor
            posY = focusY - unscaledFocusY * scaleFactor
            
            // Apply constraints to panning
            constrainPan()
            
            // Clear cache if scale changed significantly
            if (kotlin.math.abs(scaleFactor - oldScale) > 0.1f) {
                cachedBitmap?.recycle()
                cachedBitmap = null
            }
            
            // Turn off fitToScreen mode when manually zooming
            if (kotlin.math.abs(scaleFactor - initialScaleFactor) > 0.1f) {
                fitToScreen = false
            }
            
            invalidate()
            return true
        }
    }
    
    private inner class GestureListener : GestureDetector.SimpleOnGestureListener() {
        override fun onDoubleTap(e: MotionEvent): Boolean {
            // Double tap to toggle between fit-to-screen and 100% zoom
            fitToScreen = !fitToScreen
            
            if (fitToScreen) {
                // Reset to screen-fitting scale
                scaleFactor = initialScaleFactor
                
                // Center the PDF
                page?.let {
                    posX = (width - it.width * scaleFactor) / 2
                    posY = (height - it.height * scaleFactor) / 2
                }
            } else {
                // Zoom to actual size (100%)
                val targetScale = 1.0f // 1:1 pixel ratio
                
                // Focus zoom on tap location
                val focusX = e.x
                val focusY = e.y
                
                // Save pre-scale values
                val unscaledFocusX = (focusX - posX) / scaleFactor
                val unscaledFocusY = (focusY - posY) / scaleFactor
                
                // Apply new scale
                scaleFactor = targetScale
                
                // Recalculate position to zoom into focus point
                posX = focusX - unscaledFocusX * scaleFactor
                posY = focusY - unscaledFocusY * scaleFactor
            }
            
            // Clear cache as scale changed
            cachedBitmap?.recycle()
            cachedBitmap = null
            
            invalidate()
            return true
        }
        
        override fun onLongPress(e: MotionEvent) {
            // Reset to fit-to-screen on long press
            fitToScreen = true
            scaleFactor = initialScaleFactor
            
            // Center the PDF
            page?.let {
                posX = (width - it.width * scaleFactor) / 2
                posY = (height - it.height * scaleFactor) / 2
            }
            
            // Clear cache as scale changed
            cachedBitmap?.recycle()
            cachedBitmap = null
            
            invalidate()
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