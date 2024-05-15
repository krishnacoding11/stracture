//
//  PdftronEventController.swift
//  Runner
//
//  Created by Maulik Kundaliya on 05/09/22.
//

import Foundation
import pdftron_flutter

protocol PdftronEventDelegate{
    
    func getSelectedAnnotation(annotationId: String, isLocationAnnot:Bool)
    func getTapOnPin(formId : String, width:Double, height:Double)
    func createPinAnnotation(pts:CGPoint)
    func createOnPressAnnotation(pts:PTPDFPoint)
    func createOnZoomAnnotation(pts:PTPDFPoint)

//    func pdfTronScrolled()
}

class PdftronEventController : PTFlutterDocumentController  {
    var fplugin : PdftronFlutterPlugin?
    var tab : Int?

    var pdfEventDelegate: PdftronEventDelegate?

    init(fPlugin : PdftronFlutterPlugin,tab : Int){
        self.fplugin = fPlugin
        self.tab = tab
        super.init()
        self.initViewerSettings()
        PDFTronUtils.getDocumentController(pdfTronPlugin: self.fplugin!).pdfViewCtrl.delegate = self
        PDFTronUtils.getDocumentController(pdfTronPlugin: self.fplugin!).toolManager.delegate = self
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func initViewerSettings() {
        super.initViewerSettings()
    }
    func renderPinsWithZooming(pdfViewCtrl: PTPDFViewCtrl?,scrollView : UIScrollView){
        let pages = pdfViewCtrl?.visiblePages
        //i in 0..<pages!.count
        for page in pages! {
            let views = pdfViewCtrl?.floatingViews(onPage: page as! Int32)

            for view in views! {
                let invertScale = 1.0 / (scrollView.zoomScale)
                view.transform = CGAffineTransform(scaleX: invertScale, y: invertScale)
            }
        }
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.window.endEditing(true)
    }
    override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, pdfScrollViewTap gestureRecognizer: UITapGestureRecognizer) {
        print("tap")

        let point = gestureRecognizer.location(in: pdfViewCtrl)
        let pts = PTPDFPoint(px: point.x, py: point.y)
        let annot = pdfViewCtrl.getAnnotationAt(Int32(pts?.getX() ?? 0), y: Int32(pts?.getY() ?? 0), distanceThreshold: Double(0.5), minimumLineWeight: Double(0.5))

//        let isSelected = PDFTronUtils.showCalibratedLocation(pdfCtrl: pdfViewCtrl, annot: annot!)

        if(PDFTronUtils.isLocationAnnot(annot: annot!)){
                    pdfEventDelegate?.getSelectedAnnotation(annotationId: (annot?.getSDFObj().find("NM")?.getAsPDFText() ?? ""),isLocationAnnot: true)
        }else{
            pdfEventDelegate?.getSelectedAnnotation(annotationId:"",isLocationAnnot: false)
        }

        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        appDelegate?.window.endEditing(true)
//        let isSelected =
    }
    override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl?, pdfScrollViewDidZoom scrollView: UIScrollView?) {
        let pts = PTPDFPoint(px: 0.0, py: 0.0)
        pdfEventDelegate?.createOnZoomAnnotation(pts: pts!)
        super.pdfViewCtrl(pdfViewCtrl!, pdfScrollViewDidZoom: scrollView!)
        self.renderPinsWithZooming(pdfViewCtrl: pdfViewCtrl, scrollView: scrollView!)
    }
   override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, pdfScrollViewDidEndZooming scrollView: UIScrollView, with view: UIView?, atScale scale: Float) {

        super.pdfViewCtrl(pdfViewCtrl, pdfScrollViewDidEndZooming: scrollView, with: view, atScale: scale)
        self.renderPinsWithZooming(pdfViewCtrl: pdfViewCtrl, scrollView: scrollView)
        pdfViewCtrl.update(true)
    }
    override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, pdfScrollViewDidScroll scrollView: UIScrollView) {
        let pts = PTPDFPoint(px: 0.0, py: 0.0)
        pdfEventDelegate?.createOnZoomAnnotation(pts: pts!)
        super.pdfViewCtrl(pdfViewCtrl, pdfScrollViewDidScroll: scrollView)
        
    }
    //PRAGMA MARK - <PTToolManagerDelegate>
    override func toolManager(_ toolManager: PTToolManager, shouldSelectAnnotation annotation: PTAnnot, onPageNumber pageNumber: UInt) -> Bool {
        return false
    }
    override func toolManager(_ toolManager: PTToolManager, handleLongPress gestureRecognizer: UILongPressGestureRecognizer) -> Bool {
        return true
    }

    //This code snippet overrides a function that handles long press gestures on a PDF view. It gets the location of the gesture, and if the gesture is not in the "began" state, it calls a delegate method to create an annotation at that location
        //This code creates a PDFScrollViewLongPress gesture and adds an on-press annotation to the pdfEventDelegate if it is not began, then calls one of them. If there are no touches that state or inbegan states with different points for each button
        override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, pdfScrollViewLongPress gestureRecognizer: UILongPressGestureRecognizer) {
            let point = gestureRecognizer.location(in: pdfViewCtrl)
            if(gestureRecognizer.state != .began){
                 let pts = PTPDFPoint(px: point.x, py: point.y)
                pdfEventDelegate?.createOnPressAnnotation(pts: pts!)
            }
           else if let tmpDelegate = pdfEventDelegate{
                tmpDelegate.createPinAnnotation(pts: point)
            }

        }

    //To avoid zoom functionality of pdf file on double tap
    override func toolManager(_ toolManager: PTToolManager, handleDoubleTap gestureRecognizer: UITapGestureRecognizer) -> Bool {
        return true
    }

      //This code snippet overrides a function that handles a double tap gesture on a PDF view. It gets the location of the tap, and if the gesture state is ended, it creates an annotation at that location using a delegate method.
      //This code checks if a gestureRecognizer is ended and creates an event delegate for pressing the button.
      override func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, pdfScrollViewDoubleTap gestureRecognizer: UITapGestureRecognizer) {

           let point = gestureRecognizer.location(in: pdfViewCtrl)

           if(gestureRecognizer.state == .ended){
            let pts = PTPDFPoint(px: point.x, py: point.y)
            pdfEventDelegate?.createOnPressAnnotation(pts: pts!)
           }
        }
}
