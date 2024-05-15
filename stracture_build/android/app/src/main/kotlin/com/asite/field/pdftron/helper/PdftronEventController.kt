package com.asite.field.pdftron.helper

import android.app.AlertDialog
import android.os.Bundle
import android.view.KeyEvent
import android.view.MotionEvent
import com.asite.field.pdftron.constant.PdftronConstant
import com.asite.field.pdftron.listener.SiteOperationListener
import com.asite.field.pdftron.utils.PdftronUtils
import com.asite.field.pdftron.view.PdftronDocumentView
import com.pdftron.pdf.Annot
import com.pdftron.pdf.PDFViewCtrl
import com.pdftron.pdf.tools.ToolManager
import com.pdftron.pdftronflutter.nativeviews.FlutterPdfViewCtrlTabFragment
import com.pdftron.pdftronflutter.views.DocumentView
/**
 * Created by Chandresh Patel on 06-08-2022.
 * Handling Document and Annot CLick Events
 */
class PdftronEventController(
    private val pdftronDocumentView: PdftronDocumentView,
    private val siteOperationListener: SiteOperationListener?, private val fromTab: Int
) :
    ToolManager.PreToolManagerListener, ToolManager.BasicAnnotationListener {
    private val documentView: DocumentView
        get() {
            return (pdftronDocumentView.view as DocumentView)
        }
    private val mPdfControl: PDFViewCtrl
        get() {
            return documentView.pdfViewCtrl!!
        }

    private val flutterPdfViewCtrlTabFragment: FlutterPdfViewCtrlTabFragment
        get() {
            return documentView.pdfViewCtrlTabFragment!! as FlutterPdfViewCtrlTabFragment
        }

    private val toolManager: ToolManager
        get() {
            return (mPdfControl.toolManager as ToolManager?)!!
        }

    init {
        toolManager.setBasicAnnotationListener(this)
        toolManager.setPreToolManagerListener(this)
    }

    override fun onSingleTapConfirmed(e: MotionEvent?): Boolean {
        return if (fromTab == PdftronConstant.SITE_TAB) {
            callAnnotationSelectedListener(e!!.x, e.y)
            true
        } else {
            flutterPdfViewCtrlTabFragment.onSingleTapConfirmed(e)
        }
    }
    var isLongpressClicked = false

    //This code moves a user pin location icon while dragging the on screen and passes it to flutter side. It also checks if an event is longpress clicked, otherwise returns true.
    override fun onMove(e1: MotionEvent?, e2: MotionEvent?, x_dist: Float, y_dist: Float): Boolean {
        if (isLongpressClicked) {
           val screenX = e2!!.getX();
                val screenY = e2!!.getY();
                
                val pagePoint = mPdfControl
                .convScreenPtToCanvasPt(screenX.toDouble(), screenY.toDouble(),-1)
                
                val page = mPdfControl.doc.getPage(1)
                val rotation = page.getRotation();
                var x = 0.0;
                var y = 0.0;
                val width = page.getPageWidth()
                val height = page.getPageHeight()
                
                if(rotation == 0){
                    x = pagePoint[0]
                    y = pagePoint[1]
                }
                if(rotation == 1){
                    x = pagePoint[1];
                    y = width - pagePoint[0];
                }
                if(rotation == 2){
                    x = width  - pagePoint[0];
                    y = height - pagePoint[1];
                }
                 if(rotation == 3){
                    x = height - pagePoint[1];
                    y = pagePoint[0];
                }
                siteOperationListener?.onPressDocumentListener(x.toFloat(),y.toFloat());
            
            return true
        }
        return flutterPdfViewCtrlTabFragment.onMove(e1, e2, x_dist, y_dist)
    }


    override fun onDown(e: MotionEvent?): Boolean {
        return flutterPdfViewCtrlTabFragment.onDown(e)
    }

    override fun onUp(e: MotionEvent?, priorEventMode: PDFViewCtrl.PriorEventMode?): Boolean {
        isLongpressClicked = false
        return flutterPdfViewCtrlTabFragment.onUp(e, priorEventMode)
    }

    override fun onScaleBegin(x: Float, y: Float): Boolean {
        isLongpressClicked = false
        return flutterPdfViewCtrlTabFragment.onScaleBegin(x, y)
    }

    override fun onScale(x: Float, y: Float): Boolean {
        isLongpressClicked = false
        return flutterPdfViewCtrlTabFragment.onScale(x, y)
    }

    override fun onScaleEnd(x: Float, y: Float): Boolean {
        isLongpressClicked = false
        return flutterPdfViewCtrlTabFragment.onScaleEnd(x, y)
    }
    override fun onLongPress(e: MotionEvent?): Boolean {

        if (e != null) {
            if(e.getAction() == MotionEvent.ACTION_DOWN)
            {
                isLongpressClicked = true;
            }else{
                isLongpressClicked = false;
            }
            if (fromTab == PdftronConstant.SITE_TAB) {
                
                var screenX = (e!!.x + 0.5).toFloat()
                var screenY = (e.y + 0.5).toFloat()
                val mPageNUmber = mPdfControl.getPageNumberFromScreenPt(screenX.toDouble(), screenY.toDouble())
                if(mPageNUmber > 0) {
                    siteOperationListener?.onLongPressDocumentListener(screenX, screenY)
                }

                screenX = e.getX();
                screenY = e.getY();
                
                val pagePoint = mPdfControl
                .convScreenPtToCanvasPt(screenX.toDouble(), screenY.toDouble(),-1)

                
                val page = mPdfControl.doc.getPage(1)
                val rotation = page.getRotation();
                var x = 0.0;
                var y = 0.0;
                val width = page.getPageWidth()
                val height = page.getPageHeight()

                
                if(rotation == 0){
                    x = pagePoint[0]
                    y = pagePoint[1]
                }
                if(rotation == 1){
                    x = pagePoint[1];
                    y = width - pagePoint[0];
                }
                if(rotation == 2){
                    x = width  - pagePoint[0];
                    y = height - pagePoint[1];
                }
                 if(rotation == 3){
                    x = height - pagePoint[1];
                    y = pagePoint[0];
                }
                siteOperationListener?.onPressDocumentListener(x.toFloat(),y.toFloat())
                return true
            }
        }
        return false
    }


    override fun onScrollChanged(l: Int, t: Int, oldl: Int, oldt: Int) {
        isLongpressClicked = false
        return flutterPdfViewCtrlTabFragment.onScrollChanged(l, t, oldl, oldt)
    }

    //This code snippet overrides the onDoubleTap method and performs some actions based on the value of fromTab. If fromTab is equal to PdftronConstant.SITE_TAB, it calculates screenX and screenY values from the MotionEvent, converts them to page
    //This code checks if a user pressed the page's position is in front and passes them to flutter side. If an event occurs, it returns true.
    override fun onDoubleTap(e: MotionEvent?): Boolean {
        if (e != null) {
            if (fromTab == PdftronConstant.SITE_TAB) {
                val screenX = e.getX();
                val screenY = e.getY();
                
                    val pagePoint = mPdfControl
                    .convScreenPtToCanvasPt(screenX.toDouble(), screenY.toDouble(),-1)
                    


                    val page = mPdfControl.doc.getPage(1)
                    val rotation = page.getRotation();
                    var x = 0.0;
                    var y = 0.0;

                    val width = page.getPageWidth()
                    val height = page.getPageHeight()
                    
                    if(rotation == 0){
                    x = pagePoint[0]
                    y = pagePoint[1]
                }
                if(rotation == 1){
                    x = pagePoint[1];
                    y = width - pagePoint[0];
                }
                if(rotation == 2){
                    x = width  - pagePoint[0];
                    y = height - pagePoint[1];
                }
                 if(rotation == 3){
                    x = height - pagePoint[1];
                    y = pagePoint[0];
                }


                    // Pass points to the flutter side
                    siteOperationListener?.onPressDocumentListener(x.toFloat(),y.toFloat());

                return true
            }
        }
        return flutterPdfViewCtrlTabFragment.onDoubleTap(e)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        return flutterPdfViewCtrlTabFragment.onKeyUp(keyCode, event)
    }

    override fun onAnnotationSelected(annot: Annot?, pageNum: Int) {}

    override fun onAnnotationUnselected() {}

    override fun onInterceptAnnotationHandling(
        annot: Annot?,
        extra: Bundle?,
        toolMode: ToolManager.ToolMode?
    ): Boolean {
        return true
    }

    override fun onInterceptDialog(dialog: AlertDialog?): Boolean {
        return false
    }

    private fun callAnnotationSelectedListener(x: Float, y: Float) {
        val screenX = (x + 0.5).toFloat()
        val screenY = (y + 0.5).toFloat()
        val annot = toolManager.getAnnotationAt(screenX.toInt(), screenY.toInt())
        if (annot != null && PdftronUtils.isLocationAnnot(annot)) {
            val annotationId = annot.sdfObj.findObj("NM")?.asPDFText
            siteOperationListener?.onAnnotationSelectedListener(
                annotationId,
                true
            )
        }else{
            siteOperationListener?.onAnnotationSelectedListener(
                "",
                false
            )
        }
    }

}