package com.asite.field.pdftron.constant

import android.graphics.Color
import com.pdftron.pdf.ColorPt
import com.pdftron.pdf.utils.Utils

/**
 * Created by Chandresh Patel on 04-08-2022.
 */
object PdftronConstant {
    const val KEY_GET_PDFTRONKEY = "getPDFTronKey"
    const val KEY_DELETE_ALL_ANNOTATIONS = "aDeleteAllAnnotations"
    const val KEY_SET_EVENT_LISTENER = "setDocumentEventListener"
    const val KEY_HIGHLIGHT_SELECTED_LOCATION = "highlightSelectedLocation"
    const val KEY_REQUEST_RESET_RENDERING_PDFTRON = "requestResetRenderingPdftron"
    const val KEY_CREATE_TEMP_PIN = "createTempPin"
    const val KEY_GET_ANNOTATION_ID_AT = "getAnnotationIdAt"
    const val KEY_GENERATE_THUMBNAIL = "generateThumbnail"
    const val KEY_ANNOT_TYPE = "annotType"
    const val KEY_PAGE_NUMBER = "pageNumber"
    const val KEY_THUMBNAIL_PATH = "thumbFilePath"
    const val KEY_CONVERT_SCREEN_PT_TO_PAGE_PT = "convertScreenPtToPagePt"
    const val KEY_CONVERT_PAGE_PT_TO_SCREEN_PT = "convertPagePtToScreenPt"
    const val KEY_GET_CURRENT_PAGE_NUMBER = "getCurrentPageNumber"
    const val KEY_GET_UNIQUE_ANNOTATION_ID = "getUniqueAnnotationId"
    const val KEY_TAB = "Tab"
    const val KEY_ANNOTATION_ID = "annotationId"
    const val KEY_IS_SHOW_RECT = "isShowRect"
    const val KEY_ON_ANNOT_SELECTED_LISTENER_EVENT = "onAnnotationSelectedListener_event"
// This code snippet defines a constant variable "LISTENER_EVENT" with the value "onLongPressDocumentListener_event" and a constant variable "KEY_ON_PRESS_DOCUMENT_LISTEN".
    const val KEY_ON_LONG_PRESS_DOCUMENT_LISTENER_EVENT = "onLongPressDocumentListener_event"
    const val KEY_ON_PRESS_DOCUMENT_LISTENER_EVENT = "onPressDocumentListener_event"
    const val KEY_ON_PIN_TAP_LISTENER_EVENT = "OnPinTapListener_event"
    const val KEY_OBSERVATION_LIST = "observationList"
    const val KEY_HIGHLIGHT_FORM_ID = "highLightFormId"
    const val SITE_TAB = 110
    const val KEY_INTERACTION_ENABLED = "interactionEnabled"
    const val KEY_POLYGON_ANNOTATION = "polygonAnnotation"
    val highlightColorPt: ColorPt = Utils.color2ColorPt(Color.parseColor("#47c1c4"))
}