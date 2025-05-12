package com.example.pdfplugin

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import java.io.File

class PdfView(context: Context) : View(context) {
    private var renderer: PdfRenderer? = null
    private var page: PdfRenderer.Page? = null
    private var scaleFactor = 1.0f
    private val scaleDetector = ScaleGestureDetector(context, ScaleListener())

    fun openPdf(filePath: String) {
        val file = File(filePath)
        val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        renderer = PdfRenderer(fd)
        page = renderer?.openPage(0)
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.save()
        canvas.scale(scaleFactor, scaleFactor)
        page?.let {
            val bitmap = Bitmap.createBitmap(it.width, it.height, Bitmap.Config.ARGB_8888)
            it.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
            canvas.drawBitmap(bitmap, 0f, 0f, null)
        }
        canvas.restore()
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        scaleDetector.onTouchEvent(event)
        return true
    }

    private inner class ScaleListener : ScaleGestureDetector.SimpleOnScaleGestureListener() {
        override fun onScale(detector: ScaleGestureDetector): Boolean {
            scaleFactor *= detector.scaleFactor
            scaleFactor = scaleFactor.coerceIn(1.0f, 5.0f)
            invalidate()
            return true
        }
    }
}
