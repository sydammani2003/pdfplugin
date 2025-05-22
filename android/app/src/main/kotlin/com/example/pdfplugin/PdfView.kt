package com.example.pdfplugin

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PaintFlagsDrawFilter
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.util.AttributeSet
import android.util.Log
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import android.widget.Scroller
import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import com.tom_roush.pdfbox.text.TextPosition
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

class PdfView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
    private val enableAnnotations: Boolean = true,
    private val enableTextSearch: Boolean = true,
    private val enablePanAndZoom: Boolean = true
) : View(context, attrs, defStyleAttr) {
    private val TAG = "PdfView"
    
    // Rendering and display properties
    private var renderer: PdfRenderer? = null
    private var pageCount = 0
    private var currentPageIndex = 0
    private var scaleFactor = 1.0f
    private val scaleDetector = ScaleGestureDetector(context, ScaleListener())
    private val gestureDetector = GestureDetector(context, GestureListener())
    private val scroller = Scroller(context)
    
    // For panning and scrolling
    private var posX = 0f
    private var posY = 0f
    private var lastTouchX = 0f
    private var lastTouchY = 0f
    private var isDragging = false
    
    // Page rendering and caching
    private val pageBitmaps = HashMap<Int, Bitmap>()
    private val pageScales = HashMap<Int, Float>()
    private val visiblePages = mutableSetOf<Int>()
    
    // Page dimensions
    private val pageWidths = HashMap<Int, Int>()
    private val pageHeights = HashMap<Int, Int>()
    private var totalContentHeight = 0
    
    // Spacing between pages
    private val pageSpacing = 20
    
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
    
    // Scrollbar paint settings
    private val scrollbarPaint = Paint().apply {
        color = 0x66666666  // Semitransparent gray
        isAntiAlias = true
    }
    private val scrollbarWidth = 8
    private val scrollbarMinHeight = 50
    private var isScrollbarDragging = false
    
    // Render scale factor for quality
    private var renderScale = 2
    
    // Maximum bitmap size to prevent out of memory errors
    private val maxBitmapSize = 4096
    
    // Screen fit mode
    private var fitToScreen = true
    private var initialScaleFactor = 1.0f
    
    // For tracking velocity for flinging
    private var velocityTracker: android.view.VelocityTracker? = null
    private val maxFlingVelocity = 8000
    
    // Off-screen page buffer (number of pages to keep in memory beyond visible ones)
    private val offScreenPageBuffer = 1
    
    // Search functionality
    private var pdfBoxDocument: PDDocument? = null
    private val executorService = Executors.newSingleThreadExecutor()
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var searchQuery: String? = null
    private var searchResults: List<SearchResult> = emptyList()
    private var currentMatchIndex = 0
    
    // Search highlight paints
    private val highlightPaint = Paint().apply {
        color = Color.parseColor("#80FFFF00") // Semi-transparent yellow
        style = Paint.Style.FILL
    }
    private val currentHighlightPaint = Paint().apply {
        color = Color.parseColor("#80FF9500") // Semi-transparent orange for current match
        style = Paint.Style.FILL
    }
    
    // Annotation data classes
    sealed class Annotation {
        data class Path(val points: MutableList<Pair<Float, Float>>, val color: Int, val strokeWidth: Float) : Annotation()
        data class Highlight(val rect: RectF, val color: Int) : Annotation()
    }

    private val annotations = mutableListOf<Annotation>()
    private var currentPath: Annotation.Path? = null
    private var annotationMode: AnnotationMode = AnnotationMode.NONE

    enum class AnnotationMode { NONE, DRAW, HIGHLIGHT, ERASE }
    private var annotationColor: Int = Color.RED
    private var annotationStrokeWidth: Float = 6f
    
    init {
        // Initialize PDFBox for text search
        executorService.execute {
            try {
                PDFBoxResourceLoader.init(context)
                Log.d(TAG, "PDFBox ResourceLoader initialized")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to initialize PDFBox", e)
            }
        }
    }
    
    data class SearchResult(
        val pageIndex: Int,
        val text: String,
        val bounds: RectF
    )

    fun openPdf(filePath: String) {
        try {
            val file = File(filePath)
            
            // Open with Android's PdfRenderer for rendering
            val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            renderer = PdfRenderer(fd)
            pageCount = renderer?.pageCount ?: 0
            
            // Clear existing resources
            clearResources()
            
            // Reset position and scale
            posX = 0f
            posY = 0f
            scaleFactor = 1.0f
            currentPageIndex = 0
            
            // Measure all pages and calculate total height
            calculatePageDimensions()
            
            // Also open with PDFBox for text search
            executorService.execute {
                try {
                    if (!file.exists()) {
                        Log.e(TAG, "PDF file not found: $filePath")
                        return@execute
                    }
                    pdfBoxDocument?.close()
                    pdfBoxDocument = PDDocument.load(file)
                } catch (e: Exception) {
                    Log.e(TAG, "Error opening PDF with PDFBox", e)
                }
            }
            
            invalidate()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun calculatePageDimensions() {
        totalContentHeight = 0
        pdfWidth = 0
        renderer?.let { pdfRenderer ->
            for (i in 0 until pageCount) {
                val page = pdfRenderer.openPage(i)
                pageWidths[i] = page.width
                pageHeights[i] = page.height
                
                // Update PDF width to be the maximum page width
                pdfWidth = max(pdfWidth, page.width)
                
                // Add to total content height
                if (i > 0) totalContentHeight += pageSpacing
                totalContentHeight += page.height
                
                page.close()
            }
        }
        
        // Calculate pdfHeight as the sum of all page heights plus spacing
        pdfHeight = totalContentHeight
    }
    
    private fun clearResources() {
        // Clean up all bitmap resources
        for (bitmap in pageBitmaps.values) {
            bitmap.recycle()
        }
        pageBitmaps.clear()
        pageScales.clear()
        visiblePages.clear()
    }
    
    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        
        // Calculate initial scale factor to fit the screen width
        if (pdfWidth > 0) {
            initialScaleFactor = w.toFloat() / pdfWidth.toFloat()
            
            // Apply initial scale if we're in fit to screen mode
            if (fitToScreen) {
                scaleFactor = initialScaleFactor
                
                // Center PDF horizontally
                posX = (w - pdfWidth * scaleFactor) / 2
                
                // Clear cache as scale changed
                clearResources()
            }
        }
        
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        if (pageCount == 0) return
        
        // Set high quality drawing
        canvas.setDrawFilter(PaintFlagsDrawFilter(0, 
            Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG or Paint.DITHER_FLAG))
        
        // Calculate which pages are visible
        calculateVisiblePages()
        
        // Render all visible pages
        canvas.save()
        canvas.translate(posX, posY)
        
        var currentY = 0f
        
        for (i in 0 until pageCount) {
            val pageWidth = pageWidths[i] ?: continue
            val pageHeight = pageHeights[i] ?: continue
            
            // Draw page if it's in the visible set
            if (i in visiblePages) {
                // Make sure the page is rendered
                if (!pageBitmaps.containsKey(i)) {
                    renderPage(i)
                }
                
                // Draw the page bitmap
                pageBitmaps[i]?.let { bitmap ->
                    val destWidth = pageWidth * scaleFactor
                    val destHeight = pageHeight * scaleFactor
                    
                    val destRect = Rect(
                        0,
                        currentY.toInt(),
                        destWidth.toInt(),
                        (currentY + destHeight).toInt()
                    )
                    
                    // Draw with high-quality settings
                    canvas.drawBitmap(bitmap, null, destRect, paint)
                    
                    // Draw search highlights for this page
                    if (searchQuery != null) {
                        drawSearchHighlights(canvas, i, currentY)
                    }
                }
            }
            
            // Update Y position for next page
            currentY += pageHeight * scaleFactor + pageSpacing * scaleFactor
        }
        
        canvas.restore()
        
        // Draw scrollbar
        drawScrollbar(canvas)

        // Draw annotations overlay
        drawAnnotations(canvas)
    }
    
    private fun drawSearchHighlights(canvas: Canvas, pageIndex: Int, pageY: Float) {
        // Draw highlights for search results on this page
        val highlights = searchResults.filter { it.pageIndex == pageIndex }
        
        highlights.forEach { result ->
            // Determine if this is the current match
            val isCurrentMatch = searchResults.indexOf(result) == currentMatchIndex
            val highlightPaintToUse = if (isCurrentMatch) currentHighlightPaint else highlightPaint
            
            // Scale the bounds to match current zoom level
            val scaledBounds = RectF(
                result.bounds.left * scaleFactor,
                result.bounds.top * scaleFactor + pageY,
                result.bounds.right * scaleFactor,
                result.bounds.bottom * scaleFactor + pageY
            )
            
            canvas.drawRect(scaledBounds, highlightPaintToUse)
        }
    }
    
    private fun drawScrollbar(canvas: Canvas) {
        if (totalContentHeight * scaleFactor <= height) return // No need for scrollbar
        
        val scrollbarHeight = max(scrollbarMinHeight, 
            (height * height / (totalContentHeight * scaleFactor)).toInt())
        
        val scrollableRange = totalContentHeight * scaleFactor - height
        val scrollProgress = min(1f, max(0f, -posY / scrollableRange))
        
        val scrollbarY = (height - scrollbarHeight) * scrollProgress
        
        // Draw scrollbar track
        val trackRect = Rect(
            width - scrollbarWidth * 2, 
            0, 
            width, 
            height
        )
        scrollbarPaint.alpha = 40
        canvas.drawRect(trackRect, scrollbarPaint)
        
        // Draw scrollbar thumb
        val thumbRect = Rect(
            width - scrollbarWidth * 2,
            scrollbarY.toInt(),
            width,
            (scrollbarY + scrollbarHeight).toInt()
        )
        scrollbarPaint.alpha = 120
        canvas.drawRect(thumbRect, scrollbarPaint)
    }

    private fun drawAnnotations(canvas: Canvas) {
        canvas.save()
        canvas.translate(posX, posY)
        // Draw all annotations
        for (ann in annotations) {
            when (ann) {
                is Annotation.Path -> {
                    val paint = Paint().apply {
                        color = ann.color
                        style = Paint.Style.STROKE
                        strokeWidth = ann.strokeWidth * scaleFactor
                        isAntiAlias = true
                    }
                    val path = android.graphics.Path()
                    ann.points.forEachIndexed { i, pt ->
                        val x = pt.first * scaleFactor
                        val y = pt.second * scaleFactor
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    canvas.drawPath(path, paint)
                }
                is Annotation.Highlight -> {
                    val paint = Paint().apply {
                        color = ann.color
                        style = Paint.Style.FILL
                        alpha = 80
                    }
                    val rect = RectF(
                        ann.rect.left * scaleFactor,
                        ann.rect.top * scaleFactor,
                        ann.rect.right * scaleFactor,
                        ann.rect.bottom * scaleFactor
                    )
                    canvas.drawRect(rect, paint)
                }
            }
        }
        // Draw current drawing path
        currentPath?.let { ann ->
            val paint = Paint().apply {
                color = ann.color
                style = Paint.Style.STROKE
                strokeWidth = ann.strokeWidth * scaleFactor
                isAntiAlias = true
            }
            val path = android.graphics.Path()
            ann.points.forEachIndexed { i, pt ->
                val x = pt.first * scaleFactor
                val y = pt.second * scaleFactor
                if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
            }
            canvas.drawPath(path, paint)
        }
        canvas.restore()
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!enablePanAndZoom) {
            return false
        }

        // Initialize velocity tracker if needed
        if (velocityTracker == null && event.actionMasked == MotionEvent.ACTION_DOWN) {
            velocityTracker = android.view.VelocityTracker.obtain()
        }
        
        // Add movement to velocity tracker
        velocityTracker?.addMovement(event)
        
        // Let the gesture detectors handle the event
        val scaleDetectorHandled = scaleDetector.onTouchEvent(event)
        val gestureDetectorHandled = gestureDetector.onTouchEvent(event)
        
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                // Stop scrolling animation
                if (!scroller.isFinished) {
                    scroller.abortAnimation()
                }
                
                lastTouchX = event.x
                lastTouchY = event.y
                isDragging = true
                
                // Check if touching scrollbar
                if (event.x > width - scrollbarWidth * 2) {
                    isScrollbarDragging = true
                    handleScrollbarDrag(event.y)
                    return true
                }
            }
            
            MotionEvent.ACTION_MOVE -> {
                if (isScrollbarDragging) {
                    handleScrollbarDrag(event.y)
                    return true
                }
                
                if (!scaleDetector.isInProgress && isDragging) {
                    val dx = event.x - lastTouchX
                    val dy = event.y - lastTouchY
                    
                    // Always allow vertical scrolling
                    posY += dy
                    
                    // Only allow horizontal panning for zoomed content
                    if (scaleFactor > initialScaleFactor * 0.95f) {
                        posX += dx
                    }
                    
                    // Apply constraints
                    constrainPan()
                    
                    lastTouchX = event.x
                    lastTouchY = event.y
                    
                    invalidate()
                }
            }
            
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                isDragging = false
                isScrollbarDragging = false
                
                // Calculate velocity for fling
                velocityTracker?.let { tracker ->
                    tracker.computeCurrentVelocity(1000, maxFlingVelocity.toFloat())
                    val yVelocity = tracker.yVelocity
                    
                    // Only fling if not zoomed in horizontally
                    if (abs(scaleFactor - initialScaleFactor) < 0.1f) {
                        fling(0, -yVelocity.toInt())
                    }
                }
                
                // Recycle velocity tracker
                velocityTracker?.recycle()
                velocityTracker = null
            }
        }
        
        // Add annotation mode logic
        if (annotationMode != AnnotationMode.NONE) {
            if (enableAnnotations) {
                handleAnnotationTouch(event)
                return true
            }
            return false
        }
        
        return true
    }
    
    private fun handleScrollbarDrag(y: Float) {
        // Calculate new scroll position based on scrollbar drag
        val scrollableRange = totalContentHeight * scaleFactor - height
        if (scrollableRange <= 0) return
        
        val scrollbarHeight = max(scrollbarMinHeight, 
            (height * height / (totalContentHeight * scaleFactor)).toInt())
        val availableScrollbarTrack = height - scrollbarHeight
        
        // Calculate new scroll progress (0-1)
        val scrollProgress = (y - scrollbarHeight / 2).coerceIn(0f, availableScrollbarTrack.toFloat()) / availableScrollbarTrack
        
        // Apply new scroll position
        posY = -scrollProgress * scrollableRange
        constrainPan()
        invalidate()
    }
    
    fun fling(velocityX: Int, velocityY: Int) {
        // Adjust fling distance based on scale factor
        val scaledVelocityY = velocityY
        
        // Get current scroll position
        val startX = -posX.toInt()
        val startY = -posY.toInt()
        
        // Calculate fling boundaries
        val minX = 0
        val maxX = (pdfWidth * scaleFactor - width).toInt().coerceAtLeast(0)
        val minY = 0
        val maxY = (totalContentHeight * scaleFactor - height).toInt().coerceAtLeast(0)
        
        // Start scroller animation
        scroller.fling(
            startX, startY,
            velocityX, scaledVelocityY,
            minX, maxX,
            minY, maxY
        )
        
        // Request next frame to continue animation
        postInvalidateOnAnimation()
    }
    
    override fun computeScroll() {
        if (scroller.computeScrollOffset()) {
            // Update positions from scroller
            posX = -scroller.currX.toFloat()
            posY = -scroller.currY.toFloat()
            
            // Request next frame
            postInvalidateOnAnimation()
        }
    }
    
    private fun constrainPan() {
        // Always allow scrolling through pages vertically
        val maxY = totalContentHeight * scaleFactor - height
        if (maxY > 0) {
            // Constrain vertical scroll within document bounds
            posY = posY.coerceIn(-maxY, 0f)
        } else {
            // Center vertically if content is shorter than view
            posY = (height - totalContentHeight * scaleFactor) / 2
        }
        
        // For horizontal panning, keep content on screen
        val maxX = pdfWidth * scaleFactor - width
        if (maxX > 0) {
            // Constrain horizontal pan
            posX = posX.coerceIn(-maxX, 0f)
        } else {
            // Center horizontally
            posX = (width - pdfWidth * scaleFactor) / 2
        }
    }
    
    private fun renderPage(pageIndex: Int, canvas: Canvas? = null) {
        if (pageIndex < 0 || pageIndex >= pageCount || renderer == null) return
        
        // Check if we already have a bitmap at this scale
        val currentScale = scaleFactor * renderScale
        if (pageBitmaps.containsKey(pageIndex) && pageScales[pageIndex] == currentScale) {
            return // Already rendered at current scale
        }
        
        // Get page dimensions
        val pageWidth = pageWidths[pageIndex] ?: return
        val pageHeight = pageHeights[pageIndex] ?: return
        
        try {
            // Calculate render dimensions
            var renderWidth = (pageWidth * currentScale).toInt()
            var renderHeight = (pageHeight * currentScale).toInt()
            
            // Constrain to maximum size to prevent memory issues
            if (renderWidth > maxBitmapSize || renderHeight > maxBitmapSize) {
                val scale = min(
                    maxBitmapSize.toFloat() / renderWidth,
                    maxBitmapSize.toFloat() / renderHeight
                )
                renderWidth = (renderWidth * scale).toInt()
                renderHeight = (renderHeight * scale).toInt()
            }
            
            // Recycle old bitmap if it exists
            pageBitmaps[pageIndex]?.recycle()
            
            // Create bitmap and render page
            val bitmap = Bitmap.createBitmap(renderWidth, renderHeight, Bitmap.Config.ARGB_8888)
            renderer?.let { pdfRenderer ->
                val page = pdfRenderer.openPage(pageIndex)
                
                // Create a matrix for scaling
                val matrix = Matrix()
                matrix.setScale(
                    renderWidth.toFloat() / page.width,
                    renderHeight.toFloat() / page.height
                )
                
                // Render PDF page to bitmap
                page.render(bitmap, null, matrix, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                page.close()
                
                // Store bitmap and scale
                pageBitmaps[pageIndex] = bitmap
                pageScales[pageIndex] = currentScale
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    // Calculate which pages are currently visible based on scroll position
    private fun calculateVisiblePages() {
        val newVisiblePages = mutableSetOf<Int>()
        
        if (pageCount == 0) return
        
        // Calculate visible area in document coordinates
        val visibleTop = -posY / scaleFactor
        val visibleBottom = (height - posY) / scaleFactor
        
        var currentY = 0
        
        for (i in 0 until pageCount) {
            val pageHeight = pageHeights[i] ?: continue
            val pageBottom = currentY + pageHeight
            
            // Check if this page is visible
            if (pageBottom >= visibleTop && currentY <= visibleBottom) {
                newVisiblePages.add(i)
                
                // Pre-render offscreen pages for smoother scrolling
                for (j in max(0, i - offScreenPageBuffer)..min(pageCount - 1, i + offScreenPageBuffer)) {
                    if (j != i && !pageBitmaps.containsKey(j)) {
                        renderPage(j)
                    }
                }
            }
            
            // Update for next page position
            currentY = pageBottom + pageSpacing
        }
        
        // Clean up pages that are no longer visible or nearby
        val allNeededPages = mutableSetOf<Int>()
        for (visiblePage in newVisiblePages) {
            allNeededPages.add(visiblePage)
            // Add buffer pages
            for (i in max(0, visiblePage - offScreenPageBuffer)..min(pageCount - 1, visiblePage + offScreenPageBuffer)) {
                allNeededPages.add(i)
            }
        }
        
        // Remove bitmaps that are no longer needed
        val pagesToRemove = pageBitmaps.keys.filter { it !in allNeededPages }
        for (pageIndex in pagesToRemove) {
            pageBitmaps[pageIndex]?.recycle()
            pageBitmaps.remove(pageIndex)
            pageScales.remove(pageIndex)
        }
        
        visiblePages.clear()
        visiblePages.addAll(newVisiblePages)
    }

    private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScale(detector: ScaleGestureDetector): Boolean {
        val oldScale = scaleFactor
        
        // Enhanced smooth interpolation factor
        val smoothFactor = 0.15f
        
        // Focus zoom on pinch center point with enhanced precision
        val focusX = detector.focusX
        val focusY = detector.focusY
        
        // Save pre-scale values with double interpolation
        val unscaledFocusX = (focusX - posX) / oldScale
        val unscaledFocusY = (focusY - posY) / oldScale
        
        // Apply scale change with enhanced smooth interpolation
        val targetScale = scaleFactor * detector.scaleFactor
        val deltaScale = targetScale - oldScale
        scaleFactor = oldScale + deltaScale * smoothFactor * (1 + kotlin.math.abs(deltaScale) * 0.2f)
        
        // Dynamic scale constraints based on content
        val minScale = initialScaleFactor * 0.5f
        val maxScale = initialScaleFactor * 10.0f
        scaleFactor = scaleFactor.coerceIn(minScale, maxScale)
        
        // Enhanced position interpolation with acceleration
        val targetPosX = focusX - unscaledFocusX * scaleFactor
        val targetPosY = focusY - unscaledFocusY * scaleFactor
        val deltaX = targetPosX - posX
        val deltaY = targetPosY - posY
        
        // Adaptive smoothing based on movement speed
        val movementSpeed = kotlin.math.sqrt(deltaX * deltaX + deltaY * deltaY)
        val adaptiveSmoothFactor = smoothFactor * (1.0f / (1.0f + movementSpeed * 0.001f))
        
        posX += deltaX * adaptiveSmoothFactor
        posY += deltaY * adaptiveSmoothFactor
        
        // Apply enhanced pan constraints
        constrainPan()
        
        // Smooth transition for fitToScreen mode
        if (kotlin.math.abs(scaleFactor - initialScaleFactor) > 0.1f) {
            fitToScreen = false
        }
        
        // Optimized resource management
        val significantChange = kotlin.math.abs(scaleFactor - oldScale) > 0.05f
        if (significantChange) {
            postDelayed({
                clearResources()
                invalidate()
            }, 32) // Approximately 2 frames delay
        } else {
            invalidate()
        }
        
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
                
                // Center the PDF horizontally
                posX = (width - pdfWidth * scaleFactor) / 2
                
                // Don't change vertical position to maintain reading location
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
            
            // Apply constraints to panning
            constrainPan()
            
            // Clear cache as scale changed
            clearResources()
            
            invalidate()
            return true
        }
        
        override fun onLongPress(e: MotionEvent) {
            // Reset to fit-to-screen on long press
            fitToScreen = true
            scaleFactor = initialScaleFactor
            
            // Center the PDF horizontally
            posX = (width - pdfWidth * scaleFactor) / 2
            
            // Apply constraints to panning
            constrainPan()
            
            // Clear cache as scale changed
            clearResources()
            
            invalidate()
        }
    }
    
    // Text search functionality
    fun searchText(query: String, onResults: (Int, String?) -> Unit) {
        if (!enableTextSearch) {
            onResults(0, "Text search is disabled")
            return
        }

        // Validate search query
        if (query.isBlank()) {
        onResults(0, "Search query cannot be empty")
        return
    }
    
    searchQuery = query.trim() // Remove leading/trailing whitespace
    executorService.execute {
        try {
            val results = mutableListOf<SearchResult>()
            val document = pdfBoxDocument ?: run {
                coroutineScope.launch {
                    onResults(0, "PDF document not loaded for text search")
                }
                return@execute
            }
            
            for (pageIndex in 0 until document.numberOfPages) {
                val stripper = TextSearchStripper(searchQuery!!, pageIndex)
                stripper.startPage = pageIndex + 1
                stripper.endPage = pageIndex + 1
                
                // Extract text from this page
                stripper.getText(document)
                results.addAll(stripper.getSearchResults())
            }
            
            coroutineScope.launch {
                searchResults = results
                currentMatchIndex = 0
                onResults(results.size, null)
                if (results.isNotEmpty()) {
                    navigateToMatch(0)
                }
                invalidate()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error searching text", e)
            coroutineScope.launch {
                onResults(0, "Search failed: ${e.message}")
            }
        }
    }
}
    
    fun navigateToMatch(index: Int) {
        if (index < 0 || index >= searchResults.size) return
        
        currentMatchIndex = index
        val result = searchResults[index]
        
        // Calculate the y position of the page containing the match
        var targetY = 0f
        for (i in 0 until result.pageIndex) {
            targetY += (pageHeights[i] ?: 0) + pageSpacing
        }
        
        // Calculate position of the highlight within the page
        val highlightY = targetY + result.bounds.top
        
        // Center the highlight in the view
        val targetPosY = -(highlightY * scaleFactor - height / 2 + result.bounds.height() * scaleFactor / 2)
        
        // Animate scroll to position
        val startY = -posY.toInt()
        val endY = -targetPosY.toInt()
        
        scroller.startScroll(0, startY, 0, endY - startY, 500)
        invalidate()
    }
    
    fun clearSearch() {
        searchQuery = null
        searchResults = emptyList()
        currentMatchIndex = 0
        invalidate()
    }
    
    // Custom text stripper for finding text positions
    private inner class TextSearchStripper(
    private val searchQuery: String,
    private val pageIndex: Int
) : PDFTextStripper() {
    private val searchResults = mutableListOf<SearchResult>()
    private val queryLower = searchQuery.lowercase()
    private val textPositions = mutableListOf<TextPosition>()
    private var allPageText = StringBuilder()
    
    override fun processTextPosition(text: TextPosition) {
        // Collect all text positions for later processing
        textPositions.add(text)
        allPageText.append(text.unicode)
        super.processTextPosition(text)
    }
    
    override fun getText(document: PDDocument?): String {
        // First collect all text
        val result = super.getText(document)
        
        // Now search within the complete page text
        findMatches()
        
        return result
    }
    
    private fun findMatches() {
        val pageText = allPageText.toString().lowercase()
        var startIndex = 0
        
        // Find all occurrences of the search query
        while (true) {
            val foundIndex = pageText.indexOf(queryLower, startIndex)
            if (foundIndex == -1) break
            
            // Find the text positions that correspond to this match
            val matchBounds = getTextBounds(foundIndex, foundIndex + queryLower.length)
            
            if (matchBounds != null) {
                searchResults.add(
                    SearchResult(
                        pageIndex = pageIndex,
                        text = allPageText.substring(foundIndex, foundIndex + queryLower.length),
                        bounds = matchBounds
                    )
                )
            }
            
            startIndex = foundIndex + 1
        }
    }
    
    private fun getTextBounds(startChar: Int, endChar: Int): RectF? {
        if (textPositions.isEmpty() || startChar >= textPositions.size) return null
        
        var actualStart = startChar
        var actualEnd = endChar.coerceAtMost(textPositions.size)
        
        // Handle case where we might be searching across word boundaries
        // Ensure we don't go out of bounds
        if (actualStart < 0) actualStart = 0
        if (actualEnd > textPositions.size) actualEnd = textPositions.size
        if (actualStart >= actualEnd) return null
        
        try {
            val startPos = textPositions[actualStart]
            val endPos = textPositions[actualEnd - 1]
            
            val left = startPos.xDirAdj
            val top = startPos.yDirAdj - startPos.heightDir // Move to top of text
            val right = endPos.xDirAdj + endPos.widthDirAdj
            val bottom = endPos.yDirAdj
            
            return RectF(left, top, right, bottom)
        } catch (e: Exception) {
            Log.e(TAG, "Error calculating text bounds", e)
            return null
        }
    }
    
    fun getSearchResults(): List<SearchResult> = searchResults
}
    
    // Optional: Method to adjust render quality dynamically
    fun setRenderQuality(quality: RenderQuality) {
        when (quality) {
            RenderQuality.LOW -> renderScale = 1
            RenderQuality.MEDIUM -> renderScale = 2
            RenderQuality.HIGH -> renderScale = 4
            RenderQuality.ULTRA -> renderScale = 8
        }
        clearResources()
        invalidate()
    }
    
    enum class RenderQuality {
        LOW, MEDIUM, HIGH, ULTRA
    }
    
    // Clean up resources
    fun onDestroy() {
        clearResources()
        renderer?.close()
        
        coroutineScope.cancel()
        executorService.shutdown()
        pdfBoxDocument?.close()
    }

    // --- Annotation touch logic ---
    private fun handleAnnotationTouch(event: MotionEvent) {
        if (!enableAnnotations) {
            return
        }

        val x = (event.x - posX) / scaleFactor
        val y = (event.y - posY) / scaleFactor
        when (annotationMode) {
            AnnotationMode.DRAW -> {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        currentPath = Annotation.Path(mutableListOf(Pair(x, y)), annotationColor, annotationStrokeWidth)
                        invalidate()
                    }
                    MotionEvent.ACTION_MOVE -> {
                        currentPath?.points?.add(Pair(x, y))
                        invalidate()
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        currentPath?.let { annotations.add(it) }
                        currentPath = null
                        invalidate()
                    }
                }
            }
            AnnotationMode.HIGHLIGHT -> {
                // Drag to select rectangle
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        currentPath = Annotation.Path(mutableListOf(Pair(x, y)), Color.TRANSPARENT, 0f)
                    }
                    MotionEvent.ACTION_MOVE, MotionEvent.ACTION_UP -> {
                        currentPath?.let {
                            if (it.points.size == 1) it.points.add(Pair(x, y))
                            else it.points[1] = Pair(x, y)
                            if (event.action == MotionEvent.ACTION_UP) {
                                val p1 = it.points[0]
                                val p2 = it.points[1]
                                annotations.add(
                                    Annotation.Highlight(
                                        RectF(
                                            minOf(p1.first, p2.first),
                                            minOf(p1.second, p2.second),
                                            maxOf(p1.first, p2.first),
                                            maxOf(p1.second, p2.second)
                                        ),
                                        Color.YELLOW
                                    )
                                )
                                currentPath = null
                            }
                        }
                        invalidate()
                    }
                }
            }
            AnnotationMode.ERASE -> {
                if (event.action == MotionEvent.ACTION_DOWN) {
                    // Remove annotation if touch is close to any annotation path/highlight
                    val touchRadius = 20 / scaleFactor
                    annotations.removeAll { ann ->
                        when (ann) {
                            is Annotation.Path -> ann.points.any { pt ->
                                (pt.first - x).let { dx -> (pt.second - y).let { dy -> dx * dx + dy * dy < touchRadius * touchRadius } }
                            }
                            is Annotation.Highlight -> ann.rect.contains(x, y)
                        }
                    }
                    invalidate()
                }
            }
            else -> {}
        }
    }

    // --- Methods to set annotation mode from Flutter ---
    fun setAnnotationMode(mode: String, color: Int?, strokeWidth: Float?) {
        if (!enableAnnotations) {
            annotationMode = AnnotationMode.NONE
            return
        }

        annotationMode = when (mode) {
            "draw" -> AnnotationMode.DRAW
            "highlight" -> AnnotationMode.HIGHLIGHT
            "erase" -> AnnotationMode.ERASE
            else -> AnnotationMode.NONE
        }
        color?.let { annotationColor = it }
        strokeWidth?.let { annotationStrokeWidth = it }
    }

    fun clearAnnotations() {
        annotations.clear()
        invalidate()
    }
}