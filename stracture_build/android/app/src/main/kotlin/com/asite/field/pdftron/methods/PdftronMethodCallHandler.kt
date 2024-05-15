
package com.asite.field.pdftron.methods

import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import com.asite.field.models.ObservationData
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ANNOTATION_ID
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ANNOT_TYPE
import com.asite.field.pdftron.constant.PdftronConstant.KEY_CONVERT_PAGE_PT_TO_SCREEN_PT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_CONVERT_SCREEN_PT_TO_PAGE_PT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_CREATE_TEMP_PIN
import com.asite.field.pdftron.constant.PdftronConstant.KEY_DELETE_ALL_ANNOTATIONS
import com.asite.field.pdftron.constant.PdftronConstant.KEY_GENERATE_THUMBNAIL
import com.asite.field.pdftron.constant.PdftronConstant.KEY_GET_ANNOTATION_ID_AT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_GET_CURRENT_PAGE_NUMBER
import com.asite.field.pdftron.constant.PdftronConstant.KEY_GET_PDFTRONKEY
import com.asite.field.pdftron.constant.PdftronConstant.KEY_GET_UNIQUE_ANNOTATION_ID
import com.asite.field.pdftron.constant.PdftronConstant.KEY_HIGHLIGHT_FORM_ID
import com.asite.field.pdftron.constant.PdftronConstant.KEY_HIGHLIGHT_SELECTED_LOCATION
import com.asite.field.pdftron.constant.PdftronConstant.KEY_INTERACTION_ENABLED
import com.asite.field.pdftron.constant.PdftronConstant.KEY_IS_SHOW_RECT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_OBSERVATION_LIST
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ON_ANNOT_SELECTED_LISTENER_EVENT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ON_LONG_PRESS_DOCUMENT_LISTENER_EVENT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ON_PIN_TAP_LISTENER_EVENT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_ON_PRESS_DOCUMENT_LISTENER_EVENT
import com.asite.field.pdftron.constant.PdftronConstant.KEY_PAGE_NUMBER
import com.asite.field.pdftron.constant.PdftronConstant.KEY_POLYGON_ANNOTATION
import com.asite.field.pdftron.constant.PdftronConstant.KEY_REQUEST_RESET_RENDERING_PDFTRON
import com.asite.field.pdftron.constant.PdftronConstant.KEY_SET_EVENT_LISTENER
import com.asite.field.pdftron.constant.PdftronConstant.KEY_TAB
import com.asite.field.pdftron.constant.PdftronConstant.KEY_THUMBNAIL_PATH
import com.asite.field.pdftron.helper.PdftronEventController
import com.asite.field.pdftron.listener.SiteOperationListener
import com.asite.field.pdftron.utils.PdftronUtils
import com.asite.field.pdftron.utils.PdftronUtils.Companion.getAnnotById
import com.asite.field.pdftron.utils.PdftronUtils.Companion.getAnnotationIdAt
import com.asite.field.pdftron.view.PdftronDocumentView
import com.asite.field.utils.PinGenerationUtility
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.pdftron.common.PDFNetException
import com.pdftron.pdf.Annot
import com.pdftron.pdf.PDFNet
import com.pdftron.pdf.PDFViewCtrl
import com.pdftron.pdftronflutter.views.DocumentView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.FileOutputStream
import java.io.IOException
import java.util.*
import java.util.concurrent.atomic.AtomicReference

/**
 * Created by Chandresh Patel on 04-08-2022.
 */
class PdftronMethodCallHandler(
    binaryMessenger: BinaryMessenger, id: Int,
    private var pdftronDocumentView: PdftronDocumentView
) : MethodChannel.MethodCallHandler, SiteOperationListener {

    private var methodChannel: MethodChannel? = null
    private var siteOperationListener: SiteOperationListener? = null
    private var onAnnotationSelectedEventEmitter = AtomicReference<EventChannel.EventSink>()
    private var onLongPressDocumentEventEmitter = AtomicReference<EventChannel.EventSink>()
    private var onPressDocumentEventEmitter = AtomicReference<EventChannel.EventSink>()
    private var onPinTapEventEmitter = AtomicReference<EventChannel.EventSink>()
    private var thumbnailPath: String = ""

    init {
        siteOperationListener = this
        methodChannel = MethodChannel(binaryMessenger, "asite/pdftron_flutter/documentview_$id")
        methodChannel!!.setMethodCallHandler(this)
        eventRegisterWith(binaryMessenger)
    }

    private val mPdfControl: PDFViewCtrl
        get() {
            return (pdftronDocumentView.view as DocumentView).pdfViewCtrl!!
        }

    override fun deleteAllAnnotation(mPDFViewCtrl: PDFViewCtrl, annotType: Int,isExcludingLocationAnnot: Boolean) {
        if (isExcludingLocationAnnot) {
            PdftronUtils.deleteAllAnnotationsExcludingLocation(mPDFViewCtrl)
        } else {
            PdftronUtils.deleteAllAnnotations(mPDFViewCtrl, annotType)
        }
    }

    override fun setDocumentEventListener(tab: Int) {
        PdftronEventController(pdftronDocumentView, siteOperationListener, tab)
    }

    override fun drawPinsAnnotations(mPDFViewCtrl: PDFViewCtrl, observations: String) {

    }

    override fun highlightSelectedLocation(
        mPDFViewCtrl: PDFViewCtrl,
        annotationId: String?,
        isShowRect: Boolean
    ) {
        PdftronUtils.highlightLocation(mPDFViewCtrl, annotationId, isShowRect)
        if (isShowRect && !annotationId.isNullOrEmpty()) {
            Handler(Looper.getMainLooper()).postDelayed({
                val annot: Annot? = getAnnotById(mPdfControl, annotationId)
                if (annot != null) {
                    PdftronUtils.scrollToCenter(mPDFViewCtrl, annot, mPDFViewCtrl.currentPage)
                }
            }, 0)
        }
    }

    override fun onAnnotationSelectedListener(annotationId: String?, isLocationAnnot: Boolean) {

        val annotObject = JSONObject().apply {
            put("annotationId", annotationId)
            put("isLocationAnnot", isLocationAnnot)
        }
        getOnAnnotationSelectedListenerEventEmitter()?.success(annotObject.toString())

    }

    override fun createPinAnnot(
        mPDFViewCtrl: PDFViewCtrl,
        x: Double,
        y: Double,
        mDownPageNum: Int,
        annotationId: String,
        isHighLight: Boolean,
        appBuilderID: String,
        formTypeCode: String
    ) {
        PdftronUtils.drawPinAsView(
            mPDFViewCtrl,
            x,
            y,
            mDownPageNum,
            "#FFB233",
            formTypeCode,
            isHighLight,
            annotationId,
            siteOperationListener
        )
    }

    override fun onLongPressDocumentListener(x: Float, y: Float) {
        /* val x1 = (x + 0.5).toFloat()
         val y1 = (y + 0.5).toFloat()*/
        val longPresObject = JSONObject()
        longPresObject.put("X", x)
        longPresObject.put("Y", y)
        getOnLongPressDocumentListenerEventEmitter()
            ?.success(longPresObject.toString())

    }

    override fun onPressDocumentListener(x: Float, y: Float) {
        /* val x1 = (x + 0.5).toFloat()
         val y1 = (y + 0.5).toFloat()*/
        val longPresObject = JSONObject()
        longPresObject.put("X", x)
        longPresObject.put("Y", y)
        getOnPressDocumentListenerEventEmitter()
            ?.success(longPresObject.toString())

    }

    override fun generateThumbnail(pageNUmber: Int, thumbnailFilePath: String, result: MethodChannel.Result) {
        var result: MethodChannel.Result = result
        if (mPdfControl.doc != null) {
            mPdfControl.addThumbAsyncListener {page: Int, buf: IntArray?, width: Int, height: Int ->
                try {

                    if (thumbnailPath.isNotEmpty() && buf != null && buf.isNotEmpty()) {
                        val bitmap =
                            Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                        bitmap?.setPixels(buf, 0, width, 0, 0, width, height)
                        try {
                            FileOutputStream(thumbnailPath).use { out ->
                                bitmap.compress(
                                    Bitmap.CompressFormat.PNG,
                                    100,
                                    out
                                ) // bmp is your Bitmap instance
                                out.close()
                            }

                        } catch (e: IOException) {
                            e.printStackTrace()
                        }
                    }

                } catch (oom: OutOfMemoryError) {
// error
                }
                result.success(null)
            };
            this.thumbnailPath = thumbnailFilePath
            mPdfControl.getThumbAsync(pageNUmber)
        }
    }

    override fun onPinTap(observationData: ObservationData) {
        val jsonObject = JSONObject()
        jsonObject.put("formId", observationData.formId)
        jsonObject.put("width", observationData.pinWidth)
        jsonObject.put("height", observationData.pinHeight)
        getOnPinTapListenerEventEmitter()
            ?.success(jsonObject.toString())
    }

    private fun getOnAnnotationSelectedListenerEventEmitter(): EventChannel.EventSink? {
        return onAnnotationSelectedEventEmitter.get()
    }

    fun setOnAnnotationSelectedListenerEventEmitter(emitter: EventChannel.EventSink?) {
        onAnnotationSelectedEventEmitter.set(emitter)
    }

     fun polygonAnnotation(mPDFViewCtrl: PDFViewCtrl,x1: Double,y1: Double,locationAngle: Double,annotId: Double) {
        PdftronUtils.polygonAnnotation(mPDFViewCtrl,x1,y1,locationAngle,annotId)
    }

    private fun getOnLongPressDocumentListenerEventEmitter(): EventChannel.EventSink? {
        return onLongPressDocumentEventEmitter.get()
    }
     private fun getOnPressDocumentListenerEventEmitter(): EventChannel.EventSink? {
        return onPressDocumentEventEmitter.get()
    }

    fun setOnLongPressDocumentListenerEventEmitter(emitter: EventChannel.EventSink?) {
        onLongPressDocumentEventEmitter.set(emitter)
    }
       fun setOnPressDocumentListenerEventEmitter(emitter: EventChannel.EventSink?) {
        onPressDocumentEventEmitter.set(emitter)
    }
    private fun getOnPinTapListenerEventEmitter(): EventChannel.EventSink? {
        return onPinTapEventEmitter.get()
    }

    fun setOnPinTapListenerEventEmitter(emitter: EventChannel.EventSink?) {
        onPinTapEventEmitter.set(emitter)
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            KEY_GET_PDFTRONKEY -> {
                try {
                    val licenseKey = call.argument<String>("licenseKey")
                    PDFNet.initialize(licenseKey)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                }
            }
            KEY_DELETE_ALL_ANNOTATIONS -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val annotType = call.argument<Int>(KEY_ANNOT_TYPE) ?: -1
                    val isExcludingLocationAnnot = call.argument<Boolean>("isExcludingLocationAnnot") ?: false
                    siteOperationListener?.deleteAllAnnotation(mPdfControl, annotType!!, isExcludingLocationAnnot)
                    result.success(null)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.error(ex.errorCode.toString(), "PDFTronException Error: $ex", null)
                }
            }
            KEY_SET_EVENT_LISTENER -> {
                val currentTab = call.argument<Int>(KEY_TAB)
                if (currentTab != null) {
                    siteOperationListener?.setDocumentEventListener(currentTab)
                }
                result.success(null)
            }
            KEY_REQUEST_RESET_RENDERING_PDFTRON -> {
                PdftronUtils.requestResetRenderingPdftron(mPdfControl)
                result.success(null)
            }
            KEY_GENERATE_THUMBNAIL -> {
                checkFunctionPrecondition(mPdfControl)
                val jsonObject = call.argument<String>("param")?.let { JSONObject(it) }
                jsonObject?.let {
                    val pageNumber = jsonObject.getInt(KEY_PAGE_NUMBER)
                    val thumbnailPath = jsonObject.getString(KEY_THUMBNAIL_PATH)
                    if (!thumbnailPath.isNullOrEmpty()) {
                        siteOperationListener?.generateThumbnail(pageNumber, thumbnailPath,result)
                    }
                    else{
                        result.success(null)
                    }
                }

            }
            KEY_POLYGON_ANNOTATION -> {
                try {
                    // Created a channel to communicate the Flutter and Native side code
                    checkFunctionPrecondition(mPdfControl)
                    val jsonObject = call.argument<String>("param")?.let { JSONObject(it) }
                    jsonObject?.let {
                        val x1 = it.getDouble("x1")
                        val y1 = it.getDouble("y1")
                        val locationAngle = it.getDouble("locationAngle")
                       
                        val annotId = it.getDouble("annotId")
                        polygonAnnotation(
                            mPdfControl,
                            x1, y1, locationAngle, annotId
                        )
                    }
                    result.success(null)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.error(ex.errorCode.toString(), "PDFTronException Error: $ex", null)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            KEY_HIGHLIGHT_SELECTED_LOCATION -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val annotationId = call.argument<String?>(KEY_ANNOTATION_ID)
                    siteOperationListener?.highlightSelectedLocation(
                        mPdfControl, annotationId,
                        call.argument(KEY_IS_SHOW_RECT) ?: false
                    )
                    result.success(null)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.error(ex.errorCode.toString(), "PDFTronException Error: $ex", null)
                }
            }
            KEY_CREATE_TEMP_PIN -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val jsonObject = call.argument<String>("param")?.let { JSONObject(it) }
                    jsonObject?.let {
                        val x = it.getDouble("X")
                        val y = it.getDouble("Y")
                        val pagePoints = mPdfControl
                            .convScreenPtToPagePt(x, y)
                        siteOperationListener?.createPinAnnot(
                            mPdfControl,
                            pagePoints[0],
                            pagePoints[1],
                            mPdfControl
                                .currentPage,
                            "123456",
                            false,
                            "SNGDEF",
                            "DEF"
                        )
                    }
                    result.success(null)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.error(ex.errorCode.toString(), "PDFTronException Error: $ex", null)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            KEY_GET_ANNOTATION_ID_AT -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val x = call.argument<Double>("X")
                    val y = call.argument<Double>("Y")
                    var annotationId: String? = null
                    if (x != null && y != null) {
                        annotationId = getAnnotationIdAt(mPdfControl, x, y)
                    }
                    result.success(annotationId)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.success(null)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(null)
                }
            }
            KEY_CONVERT_SCREEN_PT_TO_PAGE_PT -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val x = call.argument<Double>("X")
                    val y = call.argument<Double>("Y")
                    if (x != null && y != null) {
                        val pagePoints = mPdfControl
                            .convScreenPtToPagePt(x, y)
                        val jsonObject = JSONObject().apply {
                            put("X", pagePoints[0])
                            put("Y", pagePoints[1])
                        }
                        return result.success(jsonObject.toString())
                    } else {
                        result.success(null)
                    }
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.success(null)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(null)
                }
            }
            KEY_CONVERT_PAGE_PT_TO_SCREEN_PT -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val x = call.argument<Double>("X")
                    val y = call.argument<Double>("Y")
                    if (x != null && y != null) {
                        val pagePoints = mPdfControl
                            .convPagePtToScreenPt(x, y,mPdfControl.currentPage)
                        val jsonObject = JSONObject().apply {
                            put("X", pagePoints[0])
                            put("Y", pagePoints[1])
                        }
                        return result.success(jsonObject.toString())
                    } else {
                        result.success(null)
                    }
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.success(null)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(null)
                }
            }
            KEY_GET_CURRENT_PAGE_NUMBER -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    return result.success(mPdfControl.currentPage)
                } catch (ex: PDFNetException) {
                    ex.printStackTrace()
                    result.success(null)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(null)
                }
            }
            KEY_GET_UNIQUE_ANNOTATION_ID -> {
                try {
                    return result.success(PdftronUtils.getUniqueAnnotationId())
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(null)
                }
            }
            KEY_OBSERVATION_LIST -> {

                val observationList: ArrayList<ObservationData> =
                    Gson().fromJson(
                        call.argument<String>(KEY_OBSERVATION_LIST),
                        object : TypeToken<ArrayList<ObservationData?>?>() {}.type
                    )
                val highLightFormId = call.argument<String>(KEY_HIGHLIGHT_FORM_ID)
                PinGenerationUtility.createPushPinAnnotationsFromList(
                    mPdfControl,
                    observationList,
                    highLightFormId, siteOperationListener
                )
                result.success(null)
            }
            KEY_INTERACTION_ENABLED -> {
                try {
                    checkFunctionPrecondition(mPdfControl)
                    val interactionEnabled = call.argument<Boolean>(KEY_INTERACTION_ENABLED)
                    if (interactionEnabled != null) {
                        PdftronUtils.setInteractionEnabled(mPdfControl, interactionEnabled)
                    }
                    return result.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }
            }
        }
    }

    private fun eventRegisterWith(messenger: BinaryMessenger?) {
        val onAnnotationSelectedListenerEvent =
            EventChannel(messenger, KEY_ON_ANNOT_SELECTED_LISTENER_EVENT)
        onAnnotationSelectedListenerEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                setOnAnnotationSelectedListenerEventEmitter(events)
            }

            override fun onCancel(arguments: Any?) {
                setOnAnnotationSelectedListenerEventEmitter(null)
            }
        })

        val onLongPressDocumentListenerEvent =
            EventChannel(messenger, KEY_ON_LONG_PRESS_DOCUMENT_LISTENER_EVENT)
        onLongPressDocumentListenerEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                setOnLongPressDocumentListenerEventEmitter(events)
            }

            override fun onCancel(arguments: Any?) {
                setOnLongPressDocumentListenerEventEmitter(null)
            }
        })

        val onPressDocumentListenerEvent =
            EventChannel(messenger, KEY_ON_PRESS_DOCUMENT_LISTENER_EVENT)
        onPressDocumentListenerEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                setOnPressDocumentListenerEventEmitter(events)
            }

            override fun onCancel(arguments: Any?) {
                setOnPressDocumentListenerEventEmitter(null)
            }
        })

        val onPinTapListenerEvent =
            EventChannel(messenger, KEY_ON_PIN_TAP_LISTENER_EVENT)
        onPinTapListenerEvent.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                setOnPinTapListenerEventEmitter(events)
            }

            override fun onCancel(arguments: Any?) {
                setOnPinTapListenerEventEmitter(null)
            }
        })

    }

    // Helpers
    private fun checkFunctionPrecondition(mPDFViewCtrl: PDFViewCtrl) {
        Objects.requireNonNull(mPDFViewCtrl)
        Objects.requireNonNull(mPDFViewCtrl.doc)
    }
}