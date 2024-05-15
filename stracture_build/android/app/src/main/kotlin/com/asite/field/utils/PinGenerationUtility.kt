package com.asite.field.utils

import android.graphics.Color
import android.text.TextUtils
import android.widget.ImageView
import androidx.core.content.res.ResourcesCompat
import com.asite.field.models.ObservationData
import com.asite.field.pdftron.listener.SiteOperationListener
import com.asite.field.pdftron.utils.PdftronUtils
import com.asite.field.pdftron.utils.PdftronUtils.Companion.dpToPx
import com.asite.field.pdftron.view.BottomCenterAnchoredCustomLayout
import com.asite.field.R
import com.devs.vectorchildfinder.VectorChildFinder
import com.devs.vectorchildfinder.VectorDrawableCompat
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.pdftron.pdf.PDFViewCtrl
import com.pdftron.pdf.utils.Logger
import org.json.JSONArray
import org.json.JSONObject

class PinGenerationUtility {
    companion object {

        @JvmStatic
        val siteAppBuilderIds = arrayOf<String>("ASI-SITE", "SNG-DEF")
        fun createPushPinAnnotationsFromList(
            pdfViewCtrl: PDFViewCtrl?,
            observationList: ArrayList<ObservationData>?,
            highLightFormId: String? = null, siteOperationListener: SiteOperationListener?
        ) {
            try {
                if (pdfViewCtrl != null) {
                    removeAllOldPins(pdfViewCtrl)
                }
                if (!observationList.isNullOrEmpty() && pdfViewCtrl != null) {
                    for (observationVO in observationList) {
                        val strCoordinates: String = observationVO.coordinates
                        if (isJSONValid(strCoordinates)) {
                            var coordinatesList: ArrayList<HashMap<String?, Double?>>? = ArrayList()
                            if (strCoordinates.split(",").toTypedArray().size <= 2) {
                                coordinatesList = Gson().fromJson(
                                    strCoordinates,
                                    object :
                                        TypeToken<ArrayList<HashMap<String?, Double?>?>?>() {}.type
                                )
                            } else {
                                val pinCoordinatesMap = Gson().fromJson<HashMap<String?, Double?>>(
                                    strCoordinates,
                                    object : TypeToken<HashMap<String?, Double?>?>() {}.type
                                )
                                coordinatesList!!.add(pinCoordinatesMap)
                            }
                            if (!coordinatesList.isNullOrEmpty()) {
                                val coordinateMap = coordinatesList[0]
                                if (coordinatesList.size > 1) {
                                    val coordinateXYMap = coordinatesList[1]
                                    if (coordinateXYMap.containsKey("X")) {
                                        coordinateMap["X"] = coordinateXYMap["X"]
                                    } else if (coordinateXYMap.containsKey("Y")) {
                                        coordinateMap["Y"] = coordinateXYMap["Y"]
                                    }
                                }
                                var x1 = 0.0
                                var y1 = 0.0
                                try {
                                    if (strCoordinates.split(",").toTypedArray().size > 2) {
                                        x1 = coordinateMap["x1"]!!
                                        y1 = coordinateMap["y1"]!!
                                    } else {
                                        x1 = coordinateMap["X"]!!
                                        y1 = coordinateMap["Y"]!!
                                    }
                                } catch (ex: Exception) {
                                    ex.printStackTrace()
                                }
                                if (x1 != 0.0 && y1 != 0.0) {
                                    val isSelectedPin =
                                        highLightFormId != null && highLightFormId == observationVO.formId
                                    drawMarkerPinAsView(
                                        pdfViewCtrl,
                                        x1,
                                        y1,
                                        observationVO,
                                        isSelectedPin, siteOperationListener
                                    )
                                }
                            }
                        }
                    }

                    pdfViewCtrl.update(true)

                }
            } catch (ex: java.lang.Exception) {
                ex.printStackTrace()
            }
        }

        private fun drawMarkerPinAsView(
            pdfViewCtrl: PDFViewCtrl,
            x: Double,
            y: Double,
            observationData: ObservationData,
            isHighlight: Boolean, siteOperationListener: SiteOperationListener?
        ) {

            val context = pdfViewCtrl.context
            var pinSize = context.dpToPx(36f)
            if (isHighlight) {
                pinSize *= 2
            }
            val overlay = BottomCenterAnchoredCustomLayout(
                context,
                pdfViewCtrl,
                x,
                y,
                observationData.pageNumber
            )
            pdfViewCtrl.addView(overlay)
            val image = ImageView(context)
            image.minimumHeight = pinSize
            image.minimumWidth = pinSize
            image.scaleType = ImageView.ScaleType.FIT_XY

            val siteAppBuilderId = observationData.appBuilderID.uppercase()
            val doesContains = siteAppBuilderIds.contains(siteAppBuilderId)
            val pinDrawable:Int?

            if (doesContains) {
                pinDrawable = R.drawable.pin_user
                image.setImageDrawable(
                    ResourcesCompat.getDrawable(
                        context.resources,
                        R.drawable.pin_user,
                        null
                    )
                )
            } else {
                pinDrawable = R.drawable.pin_form
                image.setImageDrawable(
                    ResourcesCompat.getDrawable(
                        context.resources,
                        R.drawable.pin_form,
                        null
                    )
                )
            }
            var bgColor = "#00FFFF"
            if ((observationData.statusVO != null)
                && !TextUtils.isEmpty(observationData.statusVO.bgColor)
            ) {
                bgColor = observationData.statusVO.bgColor
                if (!bgColor.contains("#")) {
                    bgColor = "#$bgColor"
                }
            }
//            image.setColorFilter(Color.parseColor(bgColor), PorterDuff.Mode.SRC_IN)

            val vector = VectorChildFinder(context, pinDrawable, image)
            val statusPath: VectorDrawableCompat.VFullPath = vector.findPathByName(if(doesContains) "userStatus" else "formStatus")
            val bgPath: VectorDrawableCompat.VFullPath = vector.findPathByName(if(doesContains) "userBgPath" else "formBgPath")
            statusPath.setFillColor(Color.parseColor(bgColor))
            bgPath.setFillColor(Color.WHITE)

            overlay.addView(image)
            val screenPoint = pdfViewCtrl.convPagePtToScreenPt(x, y, observationData.pageNumber)
            overlay.setScreenRect(
                screenPoint[0] - image.minimumWidth / 2,
                screenPoint[1] - image.minimumHeight,
                screenPoint[0] + image.minimumWidth / 2,
                screenPoint[1],
                observationData.pageNumber
            )
            if (isHighlight) {
                PdftronUtils.scaleView(image)
            }
            observationData.pinWidth = pinSize.toDouble()
            observationData.pinHeight = pinSize.toDouble()
            overlay.tag = observationData
            overlay.setZoomWithParent(false)
            overlay.setOnClickListener {
                val observationData = it.tag as ObservationData
                siteOperationListener?.onPinTap(
                    observationData
                )
            }
        }


        /**
         * Purpose: Used to check the given string is valid json or not
         *
         * @param test
         * @return return true if valid else false
         */
        private fun isJSONValid(test: String): Boolean {
            try {
                JSONObject(test)
            } catch (ex: java.lang.Exception) {
                // edited, to include @Arthur's comment
                // e.g. in case JSONArray is valid as well...
                try {
                    JSONArray(test)
                } catch (ex1: java.lang.Exception) {
                    return false
                }
            }
            return true
        }

        @JvmStatic
        fun removeAllOldPins(mPDFViewCtrl: PDFViewCtrl) {
            try {
                for (i in mPDFViewCtrl.childCount - 1 downTo 0) {
                    if (mPDFViewCtrl.getChildAt(i) is BottomCenterAnchoredCustomLayout) {
                        val pinView = mPDFViewCtrl.getChildAt(i) as BottomCenterAnchoredCustomLayout
                        mPDFViewCtrl.removeView(pinView)
                    }
                }

                mPDFViewCtrl.update()
            } catch (ex: Exception) {
                Logger.INSTANCE.LogE("RemovePins", ex)
            }


        }
    }
}