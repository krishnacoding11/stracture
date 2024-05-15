package com.asite.field.pdftron.utils


import android.content.Context
import android.graphics.Color
import android.graphics.PorterDuff
import android.text.TextUtils
import android.util.DisplayMetrics
import android.view.View
import android.view.animation.Animation
import android.view.animation.ScaleAnimation
import android.view.inputmethod.InputMethodManager
import android.widget.ImageView
import androidx.core.content.res.ResourcesCompat
import com.asite.field.pdftron.listener.SiteOperationListener
import com.asite.field.pdftron.view.BottomCenterAnchoredCustomLayout
import com.asite.field.pdftron.view.BottomCenterAnchoredCustomLayoutLocation
import com.asite.field.R
import com.asite.field.pdftron.constant.PdftronConstant
import com.pdftron.common.PDFNetException
import com.pdftron.pdf.Annot
import com.pdftron.pdf.ColorPt
import com.pdftron.pdf.PDFViewCtrl
import com.pdftron.pdf.Rect
import com.pdftron.pdf.annots.Markup
import com.pdftron.pdf.utils.AnnotUtils
import com.pdftron.pdf.utils.Utils
import java.util.*
import kotlin.math.roundToInt
import kotlin.math.round
import kotlin.math.abs
import android.widget.RelativeLayout


class PdftronUtils {

    companion object {
        const val viewTypeId = "asite/pdftron_flutter/documentview"

        @JvmStatic
        fun drawPinAsView(
            pdfViewCtrl: PDFViewCtrl,
            x: Double,
            y: Double,
            mDownPageNum: Int,
            colorCode: String,
            formTypeCode: String,
            isHighlight: Boolean,
            annotationId: String,
            siteOperationListener: SiteOperationListener?
        ) {
            removePinAnnotView(pdfViewCtrl, annotationId)
            val context = pdfViewCtrl.context
            val overlay = BottomCenterAnchoredCustomLayout(
                context, pdfViewCtrl, x, y, mDownPageNum
            )

            pdfViewCtrl.addView(overlay)
            val pinSize: Int = context.dpToPx(20f)
            val image = ImageView(context)
            image.minimumHeight = pinSize * 2
            image.minimumWidth = pinSize * 2
            image.scaleType = ImageView.ScaleType.FIT_XY
            image.setImageDrawable(
                ResourcesCompat.getDrawable(
                    context.resources, R.drawable.marker, null
                )
            )

            image.setColorFilter(Color.parseColor(colorCode), PorterDuff.Mode.SRC_IN)
            overlay.addView(image)
            overlay.annotationId = annotationId
            val screenPoint = pdfViewCtrl.convPagePtToScreenPt(x, y, mDownPageNum)
            overlay.setScreenRect(
                screenPoint[0] - pinSize / 2,
                screenPoint[1] - pinSize,
                screenPoint[0] + pinSize / 2,
                screenPoint[1],
                mDownPageNum
            )
            overlay.setBackgroundColor(Color.rgb(255, 0, 0))
            overlay.setZoomWithParent(false)
            scaleView(overlay)
            overlay.setOnClickListener {
                siteOperationListener?.onAnnotationSelectedListener(
                    (it as BottomCenterAnchoredCustomLayout).annotationId.toString(), false
                )
            }
        }

        private fun removePinAnnotView(mPdfControl: PDFViewCtrl, annotationId: String) {
            try {
                if (!TextUtils.isEmpty(annotationId)) {
                    val createdPin: BottomCenterAnchoredCustomLayout? =
                        mPdfControl.findViewWithTag(annotationId)
                    if (createdPin != null) {
                        mPdfControl.removeView(createdPin)
                    }
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }

        private fun removeLocationPinAnnotView(mPdfControl: PDFViewCtrl, annotationId: String) {
            try {
                if (!TextUtils.isEmpty(annotationId)) {
                    val createdPin: BottomCenterAnchoredCustomLayoutLocation? =
                        mPdfControl.findViewWithTag(annotationId)
                    if (createdPin != null) {
                        mPdfControl.removeView(createdPin)
                    }
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }


        @JvmStatic
        fun scaleView(v: View, startScale: Float = 0f, endScale: Float = 1f) {
            val anim: Animation = ScaleAnimation(
                1f, 1f,  // Start and end values for the X axis scaling
                startScale, endScale,  // Start and end values for the Y axis scaling
                Animation.RELATIVE_TO_SELF, 0f,  // Pivot point of X scaling
                Animation.RELATIVE_TO_SELF, 1f
            ) // Pivot point of Y scaling
            anim.fillAfter = true // Needed to keep the result of the animation
            anim.duration = 1000
            v.startAnimation(anim)
        }

        @JvmStatic
        fun highlightSelectedAnnotation(
            mPDFViewCtrl: PDFViewCtrl,
            annot: Annot,
            colorPt: ColorPt,
            pageNum: Int,
            isShowRect: Boolean,
            isCalibratedLocation: Boolean = true
        ) {
            try {
                mPDFViewCtrl.docLock(true) {
                    val mk = Markup(annot)
                    //set Border Color
                    annot.setColor(Utils.color2ColorPt(Color.TRANSPARENT), 3)
                    mk.setInteriorColor(colorPt, 3)
                    mk.opacity = if (isCalibratedLocation) 0.27 else 0.1
                    if (isShowRect && isCalibratedLocation && annot.rect != null) {
                        mPDFViewCtrl.showRect(pageNum, annot.rect)
                        mPDFViewCtrl.zoom = (mPDFViewCtrl.zoom * 0.8)

                    }
                    annot.refreshAppearance()
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }

        @JvmStatic
        fun deleteAllAnnotations(mPDFViewCtrl: PDFViewCtrl, annotType: Int = -1) {
            try {
                mPDFViewCtrl.docLockRead()
                val shouldUnlockRead = true
                try {
                    for (i in 1..mPDFViewCtrl.doc.pageCount) {
                        val page = mPDFViewCtrl.doc!!.getPage(i)
                        var annotCount = page.numAnnots
                        while (annotCount > 0) {
                            if (page.getAnnot(annotCount - 1).isValid) {
                                if (annotType == -1) {
                                    page.annotRemove(annotCount - 1)
                                } else if (page.getAnnot(annotCount - 1).type == annotType) {
                                    page.annotRemove(annotCount - 1)
                                }
                                annotCount--
                            }
                        }
                    }
                    mPDFViewCtrl.update(true)

                } catch (e: PDFNetException) {
                    e.printStackTrace()
                } finally {
                    if (shouldUnlockRead) {
                        mPDFViewCtrl.docUnlockRead()
                    }
                }
            } catch (e: Exception) {
            }
        }

        @JvmStatic
        fun deleteAllAnnotationsExcludingLocation(mPDFViewCtrl: PDFViewCtrl) {
            try {
                mPDFViewCtrl.docLockRead()
                val shouldUnlockRead = true
                try {
                    for (i in 1..mPDFViewCtrl.doc.pageCount) {
                        val page = mPDFViewCtrl.doc!!.getPage(i)
                        var annotCount = page.numAnnots
                        while (annotCount > 0) {
                            if (page.getAnnot(annotCount - 1).isValid) {
                                if (!isLocationAnnot(page.getAnnot(annotCount - 1))) {
                                    page.annotRemove(annotCount - 1)
                                }
                                annotCount--
                            }
                        }
                    }
                    mPDFViewCtrl.update(true)

                } catch (e: PDFNetException) {
                    e.printStackTrace()
                } finally {
                    if (shouldUnlockRead) {
                        mPDFViewCtrl.docUnlockRead()
                    }
                }
            } catch (e: Exception) {
            }
        }

        @JvmStatic
        fun highlightLocation(mPdfControl: PDFViewCtrl, annot: Annot) {
            try {
                if (isLocationAnnot(annot) && annot.sdfObj.findObj(
                        "NM"
                    ).asPDFText != null
                ) {
                    mPdfControl.docLock(true) {
                        try {
                            for (i in 1..mPdfControl.doc.pageCount) {
                                for (j in 0 until mPdfControl.doc.getPage(i).numAnnots) {
                                    val tempAnnot = mPdfControl.doc.getPage(i).getAnnot(j)
                                    val isSelectedAnnot =
                                        tempAnnot.sdfObj.findObj("NM").asPDFText == annot.sdfObj.findObj(
                                            "NM"
                                        ).asPDFText
                                    highlightSelectedAnnotation(
                                        mPdfControl,
                                        tempAnnot,
                                        PdftronConstant.highlightColorPt,
                                        i,
                                        isCalibratedLocation = isSelectedAnnot,
                                        isShowRect = isSelectedAnnot
                                    )
                                }
                            }
                            mPdfControl.update()
                        } catch (ex: PDFNetException) {
                            ex.printStackTrace()
                        }
                    }
                }
            } catch (e: PDFNetException) {
                e.printStackTrace()
            }

        }

        @JvmStatic
        fun highlightLocation(
            mPdfControl: PDFViewCtrl, annotationId: String?, isShowRect: Boolean
        ) {
            try {
                mPdfControl.docLock(true) {
                    try {
                        val pageNum: Int = mPdfControl.doc.pageCount
                        for (i in 1..pageNum) {
                            val annotList: ArrayList<Annot> = mPdfControl.getAnnotationsOnPage(i)
                            val annotIterator: Iterator<Annot> = annotList.iterator()
                            while (annotIterator.hasNext()) {
                                val annot = annotIterator.next()
                                if (isLocationAnnot(annot)) {
                                    val isSelectedAnnot = !annot.sdfObj.findObj(
                                        "NM"
                                    ).asPDFText.isNullOrEmpty() && !annotationId.isNullOrEmpty() && annotationId.lowercase() != "null" && annot.sdfObj.findObj(
                                        "NM"
                                    ).asPDFText == annotationId
                                    highlightSelectedAnnotation(
                                        mPdfControl,
                                        annot,
                                        PdftronConstant.highlightColorPt,
                                        i,
                                        isCalibratedLocation = isSelectedAnnot,
                                        isShowRect = isShowRect
                                    )
                                }
                            }

                        }
                        mPdfControl.update()
                    } catch (ex: PDFNetException) {
                        ex.printStackTrace()
                    }
                }
            } catch (e: PDFNetException) {
                e.printStackTrace()
            }
        }

        @JvmStatic
        fun requestResetRenderingPdftron(mPdfControl: PDFViewCtrl) {
            try {
                mPdfControl.docLock(true) {
                    // Set preferred view mode to PageViewMode.FIT_PAGE
                    mPdfControl.preferredViewMode = PDFViewCtrl.PageViewMode.FIT_PAGE
                    // Set PageViewMode.FIT_PAGE to current page view mode
                    mPdfControl.pageViewMode = PDFViewCtrl.PageViewMode.FIT_PAGE
                    mPdfControl.directionalLockEnabled = false
                }
            } catch (ex: PDFNetException) {
                ex.printStackTrace()
            }
        }

        @JvmStatic
        fun isLocationAnnot(annot: Annot): Boolean {
            return annot.isValid && annot.type >= Annot.e_Square && annot.type <= Annot.e_Polyline
        }

        fun getAnnotationIdAt(mPdfControl: PDFViewCtrl, x: Double, y: Double): String? {
            try {
                val annot = mPdfControl.getAnnotationAt(x.toInt(), y.toInt())
                if (annot != null && annot.sdfObj != null && !annot.sdfObj.findObj(
                        "NM"
                    ).asPDFText.isNullOrEmpty()
                ) {
                    return annot.sdfObj.findObj("NM").asPDFText
                }
            } catch (e: Exception) {
            }
            return null
        }

        fun getUniqueAnnotationId(): String? {
            return UUID.randomUUID().toString() + "-" + Calendar.getInstance().timeInMillis
        }

        fun Context.dpToPx(dp: Float): Int {
            val displayMetrics: DisplayMetrics = this.resources.displayMetrics
            return (dp * displayMetrics.density).roundToInt()
        }

        fun setInteractionEnabled(mPdfControl: PDFViewCtrl, interactionEnabled: Boolean) {
            mPdfControl.setInteractionEnabled(interactionEnabled)
        }

        /**
         * Hides soft keyboard.
         *
         * @param context The context
         * @param view    The view
         */
        fun hideSoftKeyboard(context: Context, view: View) {
            try {
                val imm =
                    context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                if (imm != null && imm.isActive) {
                    imm.hideSoftInputFromWindow(view.windowToken, 0)
                }
            } catch (ignored: java.lang.Exception) {
            }
        }

        //This code snippet takes in coordinates of four points in a PDF document and converts them to screen points. It then creates an annotation on the PDF document using these screen points and adds an image to the annotation. The image is rotated based on the slope of
        //This code defines a polygon annotation that takes two screen coordinates and adds it to the PDFViewCtrl. It also sets up an image view with minimum height, maximum width, and scale type of images based on their user location

        @JvmStatic

        fun polygonAnnotation(
            mPDFViewCtrl: PDFViewCtrl,
            x1: Double,
            y1: Double,
            locationAngle: Double,
            annotId: Double
        ) {

            try {

                if (mPDFViewCtrl.doc != null) {

                    val page = mPDFViewCtrl.doc.getPage(1)
                    val rotation = page.getRotation();
                    val width = page.getPageWidth()
                    val height = page.getPageHeight()
                    var rotationAngle = (-locationAngle + 360) % 360

                    var x = 0.0;
                    var y = 0.0;

                    if(rotation == 0){
                        x = x1
                        y = y1
                    }
                    else if(rotation == 1){
                        x = height - y1;
                        y = x1;
                        rotationAngle += 90
                    }
                    else if(rotation == 2){
                        x = width  - x1;
                        y = height - y1;
                        rotationAngle += 180
                    }
                    else if(rotation == 3){
                        x = y1;
                        y = height - x1
                        rotationAngle += 270
                    }

                    val pagePoints = mPDFViewCtrl
                        .convCanvasPtToPagePt(x.toDouble(), y.toDouble(),-1);

                    val context = mPDFViewCtrl.context;
                    val pinSize: Int = context.dpToPx(50f);

                    /* Use PAGE COORDINATES WHEN PASSING DATA */
                    val overlay = BottomCenterAnchoredCustomLayoutLocation(
                        context, mPDFViewCtrl, pagePoints[0], pagePoints[1], 1
                    )

                    mPDFViewCtrl.addView(overlay)
                    val image = ImageView(context)
                    image.scaleType = ImageView.ScaleType.FIT_XY
                    image.setImageDrawable(
                        ResourcesCompat.getDrawable(
                            context.resources, R.drawable.user_location_icon, null
                        )
                    );


                    image.setRotation(rotationAngle.toFloat());
                    image.isClickable = false;
                    image.isFocusable = false;
                    //image.setBackgroundColor(Color.rgb(255, 0, 0))


                    overlay.addView(image);
                    overlay.annotationId = annotId.toString();
                    //overlay.setBackgroundColor(Color.rgb(255, 255, 0))


                    val layoutParams = RelativeLayout.LayoutParams(
                        RelativeLayout.LayoutParams.MATCH_PARENT,
                        RelativeLayout.LayoutParams.MATCH_PARENT
                    )
                    
                    image.layoutParams = layoutParams

                /* USE SCREEN COORDINATES WHEN PASSING RECT */        
                val screenPoint = mPDFViewCtrl.convCanvasPtToScreenPt(x, y, 1)
                    overlay.setScreenRect(
                        screenPoint[0] - pinSize / 2,
                        screenPoint[1] - pinSize / 2,
                        screenPoint[0] + pinSize / 2,
                        screenPoint[1] + pinSize / 2,
                        1
                    );

                  

                    if (annotId > 0) {
                        removeLocationPinAnnotView(mPDFViewCtrl, (annotId - 1.0).toString())
                    }


                }

            } catch (e: PDFNetException) {

                e.printStackTrace()

            }

        }

        @JvmStatic
        fun deleteAnnotationsOnPage(pdfViewCtrl: PDFViewCtrl, annot: Annot?, pageNum: Int) {
            pdfViewCtrl.docLock(true) {
                val page = pdfViewCtrl.doc.getPage(pageNum)
                var annotCount = page.numAnnots
                while (annotCount > 1) {
                    page.annotRemove(0)
                    annotCount = page.numAnnots
                }
                pdfViewCtrl.update(annot, pageNum)
                pdfViewCtrl.update(false)
            }
        }

        fun getAnnotById(mPdfControl: PDFViewCtrl, annotationId: String?): Annot? {
            var annot: Annot? = null
            try {
                mPdfControl.docLock(true) {
                    try {
                        for (i in 1..mPdfControl.doc.pageCount) {
                            for (j in 0 until mPdfControl.doc.getPage(i).numAnnots) {
                                val tempAnnot = mPdfControl.doc.getPage(i).getAnnot(j)
                                if (isLocationAnnot(tempAnnot)) {
                                    val isSelectedAnnot = !tempAnnot.sdfObj.findObj(
                                        "NM"
                                    ).asPDFText.isNullOrEmpty() && !annotationId.isNullOrEmpty() && annotationId.lowercase() != "null" && tempAnnot.sdfObj.findObj(
                                        "NM"
                                    ).asPDFText == annotationId
                                    if (isSelectedAnnot) {
                                        annot = tempAnnot
                                        break
                                    }
                                }
                            }
                            if (annot != null) break
                        }
                        mPdfControl.update()
                    } catch (ex: PDFNetException) {
                        ex.printStackTrace()
                    }
                }
            } catch (e: PDFNetException) {
                e.printStackTrace()
            }
            return annot
        }

        @JvmStatic
        fun scrollToCenter(mPDFViewCtrl: PDFViewCtrl, annotation: Annot, currentPageNumber: Int) {
            try {
                val screenRect: Rect = AnnotUtils.getOldAnnotScreenPosition(
                    mPDFViewCtrl, annotation, currentPageNumber
                )
                //show as center of screen
                val annotCentreX: Double = (screenRect.x1 + (screenRect.x1 + screenRect.width)) / 2
                val annotCentreY: Double = (screenRect.y1 + (screenRect.y1 + screenRect.height)) / 2
                val screenCentreX: Int = mPDFViewCtrl.width / 2
                val screenCentreY: Int = mPDFViewCtrl.height / 2
                val finalCentreX = annotCentreX - screenCentreX
                val finalCentreY = annotCentreY - screenCentreY
                try {
                    scrollToDocPosition(
                        mPDFViewCtrl, finalCentreX.toInt(), finalCentreY.toInt(), currentPageNumber
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                mPDFViewCtrl.update()
            } catch (e: PDFNetException) {
                e.printStackTrace()
            }
        }

        private fun scrollToDocPosition(
            mPdfControl: PDFViewCtrl, horizontalPosition: Int, verticalPosition: Int, page: Int
        ) {
            val screenPt: DoubleArray = mPdfControl.convScreenPtToPagePt(
                horizontalPosition.toDouble(), verticalPosition.toDouble(), page
            )
            val pagePt: DoubleArray = mPdfControl.convPagePtToScreenPt(
                screenPt[0], screenPt[1], page
            )
            mPdfControl.hScrollPos = pagePt[0].toInt() + mPdfControl.hScrollPos
            mPdfControl.vScrollPos = pagePt[1].toInt() + mPdfControl.vScrollPos
        }
    }
}
