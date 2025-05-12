package com.example.pdfplugin

import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import com.tom_roush.pdfbox.text.TextPosition
import java.io.File

class BoundingBoxTextStripper(private val file: File) {
    fun findTextPositions(query: String): List<Map<String, Any>> {
        val matches = mutableListOf<Map<String, Any>>()
        val document = PDDocument.load(file)
        val stripper = object : PDFTextStripper() {
            override fun processTextPosition(text: TextPosition) {
                if (text.unicode.contains(query, ignoreCase = true)) {
                    matches.add(
                        mapOf(
                            "text" to text.unicode,
                            "x" to text.xDirAdj,
                            "y" to text.yDirAdj,
                            "width" to text.widthDirAdj,
                            "height" to text.heightDir
                        )
                    )
                }
                super.processTextPosition(text)
            }
        }
        stripper.getText(document)
        document.close()
        return matches
    }
}
