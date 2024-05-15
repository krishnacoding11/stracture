package com.asite.field.pdftron.view;

/**
 * Created by Chandresh Patel on 12-10-2020.
 */

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.view.ViewParent;
import android.widget.RelativeLayout;

import com.pdftron.common.PDFNetException;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.PDFViewCtrl.OnCanvasSizeChangeListener;
import com.pdftron.pdf.Rect;
import com.pdftron.pdf.annots.FreeText;
import com.pdftron.pdf.tools.R.styleable;

public class CustomRelativeLayout extends RelativeLayout implements OnCanvasSizeChangeListener {
    private static final String TAG = com.pdftron.pdf.tools.CustomRelativeLayout.class.getName();
    private static final boolean DEFAULT_ZOOM_WITH_PARENT = true;
    protected PDFViewCtrl mParentView;
    protected double mPagePosLeft;
    protected double mPagePosRight;
    protected double mPagePosTop;
    protected double mPagePosBottom;
    protected double[] mScreenPt;
    protected int mPageNum;
    protected boolean mZoomWithParent;
    protected int mScrollOffsetX;
    protected int mScrollOffsetY;

    public CustomRelativeLayout(Context context, PDFViewCtrl parent, double x, double y, int page_num) {
        this(context);
        this.mParentView = parent;
        this.setPagePosition(x, y, page_num);
    }

    public CustomRelativeLayout(Context context) {
        this(context, (AttributeSet)null);
    }

    public CustomRelativeLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomRelativeLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.mPagePosLeft = 0.0D;
        this.mPagePosRight = 0.0D;
        this.mPagePosTop = 0.0D;
        this.mPagePosBottom = 0.0D;
        this.mScreenPt = new double[2];
        this.mPageNum = 1;
        this.mZoomWithParent = true;
        this.init(context, attrs, defStyleAttr, 0);
    }

    @TargetApi(21)
    public CustomRelativeLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        this.mPagePosLeft = 0.0D;
        this.mPagePosRight = 0.0D;
        this.mPagePosTop = 0.0D;
        this.mPagePosBottom = 0.0D;
        this.mScreenPt = new double[2];
        this.mPageNum = 1;
        this.mZoomWithParent = true;
        this.init(context, attrs, defStyleAttr, defStyleRes);
    }

    private void init(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, styleable.CustomRelativeLayout, defStyleAttr, defStyleRes);

        try {
            double x = (double)a.getFloat(styleable.CustomRelativeLayout_posX, 0.0F);
            double y = (double)a.getFloat(styleable.CustomRelativeLayout_posY, 0.0F);
            int page = a.getInt(styleable.CustomRelativeLayout_pageNum, 1);
            this.setPagePosition(x, y, page);
            this.setZoomWithParent(a.getBoolean(styleable.CustomRelativeLayout_zoomWithParent, true));
        } finally {
            a.recycle();
        }

    }

    public void setZoomWithParent(boolean zoomWithParent) {
        this.mZoomWithParent = zoomWithParent;
    }

    public void setPagePosition(double x, double y, int pageNum) {
        this.mPagePosLeft = x;
        this.mPagePosBottom = y;
        this.mPageNum = pageNum;
    }

    public void setScreenPosition(double left, double top, int pageNum) {
        double[] pt1 = this.mParentView.convScreenPtToPagePt(left, top, pageNum);
        this.mPagePosLeft = pt1[0];
        this.mPagePosTop = pt1[1];
        this.mPageNum = pageNum;
        this.requestLayout();
        this.invalidate();
    }

    public void setScreenRect(double left, double top, double right, double bottom, int pageNum) {
        try {
            double minX = Math.min(left, right);
            double minY = Math.min(top, bottom);
            double maxX = Math.max(left, right);
            double maxY = Math.max(top, bottom);
            double[] pt1 = this.mParentView.convScreenPtToPagePt(minX, maxY, pageNum);
            double[] pt2 = this.mParentView.convScreenPtToPagePt(maxX, minY, pageNum);
            minX = pt1[0];
            minY = pt1[1];
            maxX = pt2[0];
            maxY = pt2[1];
            this.setPagePosition(minX, minY, pageNum);
            this.mPagePosRight = maxX;
            this.mPagePosTop = maxY;
            this.setRectImpl();
        } catch (Exception var20) {
            var20.printStackTrace();
        }

    }

     public void setScreenShape(double left, double top, double right, double bottom, int pageNum) {
        try {

             double minX = Math.min(left, right);
             double minY = Math.min(top, bottom);
             double maxX = Math.max(left, right);
             double maxY = Math.max(top, bottom);

            
            
            this.setPagePosition(minX, minY, pageNum);
            this.mPagePosRight = maxX;
            this.mPagePosTop = maxY;
            this.setRectImpl();
        } catch (Exception var20) {
            var20.printStackTrace();
        }

    }

    public void setAnnot(PDFViewCtrl pdfViewCtrl, Annot annot, int annotPageNum) {
        if (null != pdfViewCtrl && null != annot) {
            try {
                if (!annot.isValid()) {
                    return;
                }

                Rect r;
                try {
                    r = annot.getVisibleContentBox();
                } catch (PDFNetException var6) {
                    r = annot.getRect();
                }

                if (annot.getType() == 2) {
                    FreeText freeText = new FreeText(annot);
                    r = freeText.getContentRect();
                }

                r.normalize();
                this.setRect(pdfViewCtrl, r, annotPageNum);
            } catch (Exception var7) {
                var7.printStackTrace();
            }

        }
    }

    public void setRect(PDFViewCtrl pdfViewCtrl, Rect rect, int pageNum) {
        try {
            double minX = Math.min(rect.getX1(), rect.getX2());
            double minY = Math.min(rect.getY1(), rect.getY2());
            double maxX = Math.max(rect.getX1(), rect.getX2());
            double maxY = Math.max(rect.getY1(), rect.getY2());
            this.mParentView = pdfViewCtrl;
            double[] pt1 = this.mParentView.convPagePtToScreenPt(minX, minY, pageNum);
            double[] pt2 = this.mParentView.convPagePtToScreenPt(maxX, maxY, pageNum);
            double screenMinX = Math.min(pt1[0], pt2[0]);
            double screenMinY = Math.min(pt1[1], pt2[1]);
            double screenMaxX = Math.max(pt1[0], pt2[0]);
            double screenMaxY = Math.max(pt1[1], pt2[1]);
            pt1 = this.mParentView.convScreenPtToPagePt(screenMinX, screenMaxY, pageNum);
            pt2 = this.mParentView.convScreenPtToPagePt(screenMaxX, screenMinY, pageNum);
            minX = pt1[0];
            minY = pt1[1];
            maxX = pt2[0];
            maxY = pt2[1];
            this.setPagePosition(minX, minY, pageNum);
            this.mPagePosRight = maxX;
            this.mPagePosTop = maxY;
            this.setRectImpl();
        } catch (Exception var22) {
            var22.printStackTrace();
        }

    }

    @SuppressLint("WrongConstant")
    private void setRectImpl() {
        double[] screenBounds = this.mParentView.convPagePtToHorizontalScrollingPt(this.mPagePosRight, this.mPagePosTop, this.mPageNum);
        this.mScreenPt = this.mParentView.convPagePtToHorizontalScrollingPt(this.mPagePosLeft, this.mPagePosBottom, this.mPageNum);
        int width = (int)(Math.abs(screenBounds[0] - this.mScreenPt[0]) + 0.5D);
        int height = (int)(Math.abs(screenBounds[1] - this.mScreenPt[1]) + 0.5D);
        this.measure(MeasureSpec.makeMeasureSpec(width, 1073741824), MeasureSpec.makeMeasureSpec(height, 1073741824));
        this.setLayoutParams(new LayoutParams(width, height));
    }

    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ViewParent parent = this.getParent();
        if (parent instanceof PDFViewCtrl) {
            this.mParentView = (PDFViewCtrl)parent;
            this.mParentView.addOnCanvasSizeChangeListener(this);
            //  this.mParentView.addPageSlidingListener(this);
        }

    }

    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (this.mParentView != null) {
            this.mParentView.removeOnCanvasSizeChangeListener(this);
            // this.mParentView.removePageSlidingListener(this);
        }

    }

    @SuppressLint("WrongConstant")
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (this.mParentView == null) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        } else {
            int width = MeasureSpec.getSize(widthMeasureSpec);
            int height = MeasureSpec.getSize(heightMeasureSpec);
            this.mScreenPt = this.mParentView.convPagePtToHorizontalScrollingPt(this.mPagePosLeft, this.mPagePosBottom, this.mPageNum);
            int t;
            int r;
            if (this.mZoomWithParent) {
                double[] screenBounds = this.mParentView.convPagePtToHorizontalScrollingPt(this.mPagePosRight, this.mPagePosTop, this.mPageNum);
                width = (int)(Math.abs(screenBounds[0] - this.mScreenPt[0]) + 0.5D);
                height = (int)(Math.abs(screenBounds[1] - this.mScreenPt[1]) + 0.5D);
                t = MeasureSpec.makeMeasureSpec(width, 1073741824);
                r = MeasureSpec.makeMeasureSpec(height, 1073741824);
                super.onMeasure(t, r);
            } else {
                super.onMeasure(widthMeasureSpec, heightMeasureSpec);
            }

            int l;
            if (this.mParentView.isMaintainZoomEnabled()) {
                l = (this.mParentView.isCurrentSlidingCanvas(this.mPageNum) ? 0 : this.mScrollOffsetX) - this.mParentView.getScrollXOffsetInTools(this.mPageNum);
                t = (this.mParentView.isCurrentSlidingCanvas(this.mPageNum) ? 0 : this.mScrollOffsetY) - this.mParentView.getScrollYOffsetInTools(this.mPageNum);
                this.setTranslationX((float)(-l));
                this.setTranslationY((float)t);
            }

            l = (int)this.mScreenPt[0];
            t = (int)this.mScreenPt[1] - height;
            r = (int)this.mScreenPt[0] + width;
            int b = (int)this.mScreenPt[1];
            this.layout(l, t, r, b);
        }
    }

    public void onCanvasSizeChanged() {
        this.measure(this.getMeasuredWidthAndState(), this.getMeasuredHeightAndState());
        this.requestLayout();
    }

    public void onScrollOffsetChanged(int x, int y) {
        if (this.mParentView.isMaintainZoomEnabled()) {
            this.mScrollOffsetX = x;
            this.mScrollOffsetY = y;
            this.requestLayout();
        }

    }
}

