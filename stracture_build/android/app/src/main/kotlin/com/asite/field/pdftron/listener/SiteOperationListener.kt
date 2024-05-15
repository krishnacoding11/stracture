package com.asite.field.pdftron.listener

import com.asite.field.models.ObservationData
import com.pdftron.pdf.PDFViewCtrl
import io.flutter.plugin.common.MethodChannel

/**
 * Created by Chandresh Patel on 15-07-2022.
 */
interface SiteOperationListener {
    fun deleteAllAnnotation(mPDFViewCtrl: PDFViewCtrl, annotType: Int, isExcludingLocationAnnot: Boolean)
    fun setDocumentEventListener(tab: Int)
    fun drawPinsAnnotations(mPDFViewCtrl: PDFViewCtrl, observations: String)
    fun highlightSelectedLocation(
        mPDFViewCtrl: PDFViewCtrl,
        annotationId: String?,
        isShowRect: Boolean
    )
    fun onAnnotationSelectedListener(annotationId: String?, isLocationAnnot: Boolean)
    fun createPinAnnot(
        mPDFViewCtrl: PDFViewCtrl,
        x: Double,
        y: Double,
        mDownPageNum: Int,
        annotationId: String,
        isHighLight: Boolean = false,
        appBuilderID: String,
        formTypeCode: String
    )

    fun onLongPressDocumentListener(x: Float, y: Float)
    fun onPressDocumentListener(x: Float, y: Float)
    fun generateThumbnail(pageNUmber: Int, thumbnailFilePath: String, result: MethodChannel.Result)
    fun onPinTap(observationData: ObservationData)

}