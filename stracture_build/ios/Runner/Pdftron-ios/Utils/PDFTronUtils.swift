//
//  PDFTronUtils.swift
//  Runner
//
//  Created by Maulik Kundaliya on 24/08/22.
//

import Foundation
import pdftron_flutter

@objc class PDFTronUtils : NSObject{
    @objc class func getDocumentController(pdfTronPlugin:PdftronFlutterPlugin) -> PTDocumentController{
        return PdftronFlutterPlugin.pt_getSelectedDocumentController(pdfTronPlugin.tabbedDocumentViewController)
    }
    @objc class func deleteAllAnnotation
    (mPDFViewCtrl:PTPDFViewCtrl, annotType:PTAnnotType){
        var shouldUnlockRead = false
        mPDFViewCtrl.docLockRead()
        shouldUnlockRead = true
        
        let pageCount = mPDFViewCtrl.pageCount
        for i in 1...pageCount{
            let page = mPDFViewCtrl.getDoc()?.getPage(UInt32(i))
            let annotations = mPDFViewCtrl.getAnnotationsOnPage(i)
            for annot in annotations{
                if(annot.isValid()){
                    if(annot.getType() == annotType){
                        page?.annotRemove(with: annot)
                    }
                }
            }
        }
        mPDFViewCtrl.update()
        if (shouldUnlockRead) {
            mPDFViewCtrl.docUnlockRead()
        }
        
    }
    @objc class func deleteAllAnnotationsExcludingLocation(mPDFViewCtrl:PTPDFViewCtrl){
        var shouldUnlockRead = false
        mPDFViewCtrl.docLockRead()
        shouldUnlockRead = true
        
        let pageCount = mPDFViewCtrl.pageCount
        for i in 1...pageCount{
            let page = mPDFViewCtrl.getDoc()?.getPage(UInt32(i))
            let annotations = mPDFViewCtrl.getAnnotationsOnPage(i)
            for annot in annotations{
                if(annot.isValid()){
                    if(!isLocationAnnot(annot: annot)){
                        page?.annotRemove(with: annot)
                    }
                }
            }
        }
        mPDFViewCtrl.update()
        if (shouldUnlockRead) {
            mPDFViewCtrl.docUnlockRead()
        }
        
    }
    @objc class func requestResetRenderingMap(pdfCrtl : PTPDFViewCtrl){
        pdfCrtl.docLock(true)
        pdfCrtl.pageViewMode = e_trn_fit_page
        pdfCrtl.update()
        pdfCrtl.docUnlock()
    }
    @objc class func highlightLocation(mPDFViewCtrl:PTPDFViewCtrl, annotationId:String, isShowRect:Bool){
        //        var isLocationAnnot = true
        var rect : PTPDFRect?
        mPDFViewCtrl.docLockRead()
        var shouldUnlockRead = true
        let pageCount = mPDFViewCtrl.pageCount
        for i in 1...pageCount{
            
            let annotations = mPDFViewCtrl.getAnnotationsOnPage(i)
            for annot in annotations{
                if(annot.isValid() && (annot.getType() != e_ptStamp) && (annot.getSDFObj() != nil) && !annotationId.isEmpty){
                    let obj : PTObj = annot.getSDFObj()
                    let dictIterator : PTObj? = obj.find("NM")
                    if(dictIterator != nil){
                        let isSelectedAnnot = (dictIterator!.getAsPDFText() == annotationId)
                        self.highlightSelectedAnnotation(mPDFViewCtrl: mPDFViewCtrl, annot: annot, colorPt: PTColorPt(x: 0.28, y: 0.76, z: 0.77, w: 0.09), pageNum: Int(i), isShowRect: isShowRect, isCalibratedLocation: isSelectedAnnot)
                        if(isSelectedAnnot && isShowRect){
                            rect = annot.getRect()
                            mPDFViewCtrl.showRect(Int32(i), rect: rect!)
                            mPDFViewCtrl.zoom = mPDFViewCtrl.zoom * 0.8
                        }
                    }
                }
            }
        }
        mPDFViewCtrl.update()
        if (shouldUnlockRead) {
            mPDFViewCtrl.docUnlockRead()
            shouldUnlockRead = false
        }
        if(rect != nil && isShowRect){
            mPDFViewCtrl.showRect(mPDFViewCtrl.currentPage, rect: rect!)
            mPDFViewCtrl.zoom = mPDFViewCtrl.zoom * 0.8
        }
    }
    @objc class func highlightSelectedAnnotation(
        mPDFViewCtrl: PTPDFViewCtrl,
        annot: PTAnnot,
        colorPt: PTColorPt?,
        pageNum: Int,
        isShowRect: Bool = true,
        isCalibratedLocation: Bool = true
    ){
        let mk = PTMarkup(ann: annot)
        if colorPt != nil{
            mk?.setInteriorColor(colorPt, compNum: 3)
        }
        //(colorPt, 3)
        mk?.setOpacity((isCalibratedLocation) ? 0.27 : 0.1)
        mk?.refreshAppearance()
        annot.setColor(colorPt, numcomp: 1)
        if (isShowRect && isCalibratedLocation && annot.getRect() != nil && colorPt != nil) {
            mPDFViewCtrl.showRect(Int32(pageNum), rect: annot.getRect())
            mPDFViewCtrl.zoom = mPDFViewCtrl.zoom * 0.8
//             if (mPDFViewCtrl.zoom > 4){
//                 mPDFViewCtrl.zoom = 4.0
//             }
        }
        annot.refreshAppearance()
    }
    @objc class func removeAllHighlightedAnnotation(mPDFViewCtrl: PTPDFViewCtrl){
        var rect : PTPDFRect?
        mPDFViewCtrl.docLockRead()
        var shouldUnlockRead = true
        let pageCount = mPDFViewCtrl.pageCount
        for i in 1...pageCount{
            
            let annotations = mPDFViewCtrl.getAnnotationsOnPage(i)
            for annot in annotations{
                if(annot.isValid() && (annot.getType() != e_ptStamp) && (annot.getSDFObj() != nil)){
                    let obj : PTObj = annot.getSDFObj()
                    let dictIterator : PTObj? = obj.find("NM")
                    if(dictIterator != nil){
                        self.highlightSelectedAnnotation(mPDFViewCtrl: mPDFViewCtrl, annot: annot, colorPt: PTColorPt(x: 0.28, y: 0.76, z: 0.77, w: 0.09), pageNum: Int(i), isShowRect: false, isCalibratedLocation: false)
//                        if(isSelectedAnnot && isShowRect){
//                            rect = annot.getRect()
//                            mPDFViewCtrl.showRect(Int32(i), rect: rect!)
//                            mPDFViewCtrl.zoom = mPDFViewCtrl.zoom * 0.8
//                        }
                    }
                }
            }
        }
        mPDFViewCtrl.update()
        if (shouldUnlockRead) {
            mPDFViewCtrl.docUnlockRead()
            shouldUnlockRead = false
        }
//        if(rect != nil && isShowRect){
//            mPDFViewCtrl.showRect(mPDFViewCtrl.currentPage, rect: rect!)
//            mPDFViewCtrl.zoom = mPDFViewCtrl.zoom * 0.8
//        }
    }
    @objc class func isLocationAnnot(annot: PTAnnot) -> Bool {
        return annot.isValid() && (((annot.getType().rawValue)) >= 4 && ((annot.getType().rawValue)) <= 7)
    }
    @objc class func getAnnotationIdAt(pdfCtrl : PTPDFViewCtrl,x:Double,y:Double) -> String{
        let annot = pdfCtrl.getAnnotationAt(Int32(x), y: Int32(y), distanceThreshold: 0.5, minimumLineWeight: 0.5)
        if (annot != nil && annot?.getSDFObj() != nil && (annot?.getSDFObj().find("NM").getAsPDFText()) != nil)
        {
            return (annot?.getSDFObj().find("NM").getAsPDFText())!
        }
        return ""
        
    }
    @objc class func getAnnotById(mPdfControl: PTPDFViewCtrl, annotationId: String?) -> PTAnnot? {
        var annot: PTAnnot?
        mPdfControl.docLock(true)
        for i in 1...mPdfControl.pageCount{
            let annotations = mPdfControl.getAnnotationsOnPage(Int32(i))
            for tmpAnnot in annotations{
                let obj : PTObj = tmpAnnot.getSDFObj()
                let dictIterator : PTObj? = obj.find("NM")
                if(dictIterator != nil){
                    let isSelectedAnnot = (dictIterator!.getAsPDFText() == annotationId)
                    if(isSelectedAnnot){
                        annot = tmpAnnot
                        break
                    }
                }
            }
            if(annot != nil){
                break
            }
        }
        mPdfControl.update()
        mPdfControl.docUnlock()
        return annot
    }
    @objc class func scrollToCenter(mPDFViewCtrl: PTPDFViewCtrl, annotation: PTAnnot, currentPageNumber: Int) {
        let screenRect = PDFTronUtils.getOldAnnotScreenPosition(mPDFViewCtrl: mPDFViewCtrl, annotation: annotation, currentPageNumber: currentPageNumber)
        
        //show as center of screen
        let annotCentreX: Double =
        (screenRect!.x1 + (screenRect!.x1 + screenRect!.width())) / 2
        let annotCentreY: Double =
        (screenRect!.y1 + (screenRect!.y1 + screenRect!.height())) / 2
        let screenCentreX: Double = Double(mPDFViewCtrl.frame.size.width / 2)
        let screenCentreY: Double = Double(mPDFViewCtrl.frame.size.height / 2)
        let finalCentreX = annotCentreX - screenCentreX
        let finalCentreY = annotCentreY - screenCentreY
        scrollToDocPosition(mPdfControl: mPDFViewCtrl, horizontalPosition: Int(finalCentreX), verticalPosition: Int(finalCentreY), page: currentPageNumber)
        mPDFViewCtrl.update()
    }
    private class func getOldAnnotScreenPosition(mPDFViewCtrl: PTPDFViewCtrl, annotation: PTAnnot, currentPageNumber: Int) -> PTPDFRect?{
            if(annotation.isValid()){
                let oldUpdateRect = mPDFViewCtrl.getScreenRect(for: annotation, page_num: Int32(currentPageNumber))
                oldUpdateRect?.normalize()
                return oldUpdateRect
            }
            return nil
        }
    private class func scrollToDocPosition(
        mPdfControl: PTPDFViewCtrl,
        horizontalPosition: Int,
        verticalPosition: Int,
        page: Int
    ) {
        let pts = PTPDFPoint(px: Double(horizontalPosition), py: Double(verticalPosition))
        let screenPt = mPdfControl.convScreenPt(toPagePt: pts!, page_num: Int32(page))
        let pagePt = mPdfControl.convPagePt(toScreenPt: screenPt, page_num: Int32(page))
        
        mPdfControl.setHScrollPos(pagePt.x + mPdfControl.getHScrollPos())
        mPdfControl.setVScrollPos(pagePt.y + mPdfControl.getVScrollPos())
    }
    @objc class func deleteImageView(mPDFViewCtrl:PTPDFViewCtrl, annotId: Double)
    {
        for subview in mPDFViewCtrl.subviews{
            if subview.accessibilityIdentifier == String(annotId-1) {
                subview.removeFromSuperview()
            }
        }
        
    }
    @objc class func polygonAnnotation(mPDFViewCtrl:PTPDFViewCtrl, x1:Double,y1:Double,locationAngle:Double,annotId:Double){
        do {
            try PTPDFNet.catchException
            {
                let doc: PTPDFDoc? = mPDFViewCtrl.getDoc()

                if(doc != nil){
                    let page: PTPage? = doc!.getPage(UInt32(mPDFViewCtrl.currentPage))
                    let width = page?.getWidth(PTBox(UInt32(getpagesize())))
                    let height = page?.getHeight(PTBox(UInt32(getpagesize())))
                    var rotation = page?.getRotation().rawValue
                           
                    var x = 0.0
                    var y = 0.0

                    let widthMinusY1 = y1
                    var angleOfRotation = 0.0;

                    
                    if(rotation! == 0){
                        x = x1 / 2
                        y = widthMinusY1 / 2
                        angleOfRotation = 0.0
                    }

                    if(rotation! == 1){
                        x = height! - widthMinusY1 / 2
                        y = x1 / 2
                        angleOfRotation = .pi / 2
                    }

                    if(rotation! == 2){
                        x = width! - (x1 / 2)
                        y = height! - (widthMinusY1 / 2)
                        angleOfRotation = .pi
                    }

                    if(rotation! == 3){
                        x = widthMinusY1 / 2
                        y = (height! - x1) / 2
                        angleOfRotation = .pi / 2 
                    }

                    
                   //let angleVal = angleOfRotation * (CGFloat(180) / (.pi) )//(angleOfRotation * 360) / (3.14159265*2)
                    let degree = (locationAngle) * (.pi/180)
                    print(degree)
                    let pointTemp = mPDFViewCtrl.convCanvasPt(toScreenPt: PTPDFPoint(px: x, py: y ))
                    print(mPDFViewCtrl.zoom)
                    let userPositionMarkup =  UIView(frame: CGRect(x: pointTemp.x-15, y: pointTemp.y-15, width: CGFloat(30.0), height: CGFloat(30.0)))
                    userPositionMarkup.clipsToBounds = false
                    userPositionMarkup.accessibilityIdentifier = String(annotId)
                    let imgvPin = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: userPositionMarkup.frame.size.width, height: userPositionMarkup.frame.size.height))
                    imgvPin.image = UIImage(named: "user_location")

                    imgvPin.transform = CGAffineTransformMakeRotation(-degree - (angleOfRotation));
                    userPositionMarkup.addSubview(imgvPin)
                    mPDFViewCtrl.addSubview(userPositionMarkup)
                    if(annotId > 0.0){
                        deleteImageView(mPDFViewCtrl: mPDFViewCtrl, annotId: annotId)
                    }
                }
            }
        } catch
        {
            print("Caught exception")
        }
        
    }
    @objc class func deleteAnnotationsOnPage(mPDFViewCtrl:PTPDFViewCtrl,  annotType:PTAnnotType) {
        var shouldUnlockRead = false
        mPDFViewCtrl.docLockRead()
        shouldUnlockRead = true
        
        let page = mPDFViewCtrl.getDoc()?.getPage(UInt32(1))
        let annotations = mPDFViewCtrl.getAnnotationsOnPage(1)
        if(annotations.count>2)
        {
            for annot in annotations{
                if(annot.isValid()){
                    if(annot.getType() == annotType){
                        page?.annotRemove(with: annot)
                    }
                }
            }
            page?.annotRemove(with: annotations.first)
            
        }
        mPDFViewCtrl.update()
        if (shouldUnlockRead) {
            mPDFViewCtrl.docUnlockRead()
        }
    }
}
