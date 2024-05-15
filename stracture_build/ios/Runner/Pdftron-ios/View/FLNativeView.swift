//
//  FLNativeView.swift
//  Runner
//
//  Created by Maulik Kundaliya on 24/08/22.
//

import Foundation
import Flutter
import UIKit
import pdftron_flutter

var pdfTronPlugin: PdftronFlutterPlugin?
class FLNativeView:PdftronFlutterPlugin,PdftronEventDelegate,PTPDFViewCtrlDelegate{

    
    
    private var event: PdftronEventController?
    private var pdfCtrl: PTPDFViewCtrl?
    var annotationSelectedEventSink : FlutterEventSink?
    var createPinEventSink : FlutterEventSink?
    var createOnPressEventSink : FlutterEventSink?
    var createOnZoomEventSink : FlutterEventSink?
    var tapOnPinEventSink : FlutterEventSink?
    var pdfScrollEventSink : FlutterEventSink?
    let customPinView = CustomPinView()
    //    override var tabbedDocumentViewController: PTTabbedDocumentViewController{
    //        didSet{
    //            self.tabbedDocumentViewController = super.tabbedDocumentViewController
    //        }
    //    }
    var frame: CGRect?
    var viewId: Int64?
    var args: Any?
    var messenger: FlutterBinaryMessenger?
    private var _view: UIView?
    
    override func view() -> UIView {
        return pdfTronPlugin!.view()
    }
    func convertStringToDictionary(json: String) -> [String: Any]? {
        let data = json.data(using: .utf8)!
        do{
            let output = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
            return output
        }
        catch {
            print (error)
            return nil
        }
    }
    @objc func tapOnPin(gesture : UIGestureRecognizer){
        let formId = gesture.view?.accessibilityIdentifier ?? ""
        let pinView = gesture.view?.viewWithTag(1001) ?? UIView()
        let pinSize = pinView.frame.size ?? CGSize.zero
        if let event = self.tapOnPinEventSink{
            let annotaionDict = [
                "formId":formId,
                "width":pinSize.width,
                "height" : pinSize.height
            ] as [String : Any]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: annotaionDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
    }
    override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Method call from flutter ----->\(call.method)")
        switch(call.method){
        case Constants.KEY_GET_PDFTRONKEY:
            if let args = call.arguments as? Dictionary<String, Any>,
               let licenseKey = args["licenseKey"] as? String{
                PTPDFNet.initialize(licenseKey)
                result(nil)
            }
            break
        case Constants.KEY_HIGHLIGHT_SELECTED_LOCATION:
            if let args = call.arguments as? Dictionary<String, Any>,
               let annotationId = args[Constants.KEY_ANNOTATION_ID] as? String{
                let isShowRect = args[Constants.KEY_IS_SHOW_RECT] as? Bool ?? false
                PDFTronUtils.highlightLocation(mPDFViewCtrl: getPdfController()!, annotationId: annotationId,isShowRect: isShowRect)
                if(isShowRect){
                    let annot = PDFTronUtils.getAnnotById(mPdfControl: getPdfController()!, annotationId: annotationId)
                     if let ptAnnot = annot{
                        PDFTronUtils.scrollToCenter(mPDFViewCtrl: getPdfController()!, annotation: ptAnnot, currentPageNumber: Int(getPdfController()!.currentPage))
                     }
                }
                if annotationId.count == 0{
                    PDFTronUtils.removeAllHighlightedAnnotation(mPDFViewCtrl: getPdfController()!)
                }
                result(nil)
            } else {
                PDFTronUtils.removeAllHighlightedAnnotation(mPDFViewCtrl: getPdfController()!)
                result(nil)
            }
            break
        case Constants.KEY_REQUEST_RESET_RENDERING_PDFTRON:
            PDFTronUtils.requestResetRenderingMap(pdfCrtl: getPdfController()!)
            result(nil)
            break
        case Constants.KEY_SET_EVENT_LISTENER:
            if let args = call.arguments as? Dictionary<String, Any>,
               let tab = args["Tab"] as? Int{
                event = PdftronEventController(fPlugin: pdfTronPlugin!, tab: tab)
                event?.pdfEventDelegate = self
                result(nil)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_DELETE_ALL_ANNOTATIONS:
            if let args = call.arguments as? Dictionary<String, Any>,
               let number = args["annotType"] as? Int{
                let isExcludingLocationAnnot = args["isExcludingLocationAnnot"] as? Bool ?? false
                if(isExcludingLocationAnnot){
                    PDFTronUtils.deleteAllAnnotationsExcludingLocation(mPDFViewCtrl: getPdfController()!)
                }else{
                    PDFTronUtils.deleteAllAnnotation(mPDFViewCtrl: getPdfController()!, annotType: PTAnnotType(UInt32(number)))
                }
                result(nil)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_GET_ANNOTATION_ID_AT:
            if let args = call.arguments as? Dictionary<String, Any>{
                
                let x = args["X"] as? Double
                let y = args["Y"] as? Double
                
                var annotationId = ""
                if(x != nil && y != nil){
                    annotationId = PDFTronUtils.getAnnotationIdAt(pdfCtrl: getPdfController()!, x: x!, y: y!)
                    result(annotationId)
                }else{
                    result(FlutterError.init(code: "annotatio id is null", message: nil, details: nil))
                }
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_CONVERT_SCREEN_PT_TO_PAGE_PT:
            if let args = call.arguments as? Dictionary<String, Any>{
                
                let x = args["X"] as? Double
                let y = args["Y"] as? Double
                
                if(x != nil && y != nil && getPdfController() != nil){
                    let pagePoint = getPdfController()!.convScreenPt(toPagePt: PTPDFPoint(px: x!, py: y!), page_num: getPdfController()!.currentPage)
                    let pointsDict = [
                        "X":pagePoint.x,
                        "Y":pagePoint.y,
                    ] as [String : Any]
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject: pointsDict)
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                    result(jsonString)
                }
                result(FlutterError.init(code: "annotatio id is null", message: nil, details: nil))
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_CONVERT_PAGE_PT_TO_SCREEN_PT:
            if let args = call.arguments as? Dictionary<String, Any>{
                
                let x = args["X"] as? Double
                let y = args["Y"] as? Double
                
                if(x != nil && y != nil && getPdfController() != nil){
                    let pagePoint = getPdfController()!.convPagePt(toScreenPt: PTPDFPoint(px: x!, py: y!), page_num: getPdfController()!.currentPage)
                    let pointsDict = [
                        "X":pagePoint.x,
                        "Y":pagePoint.y,
                    ] as [String : Any]
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject: pointsDict)
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                    result(jsonString)
                }
                result(FlutterError.init(code: "annotatio id is null", message: nil, details: nil))
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_GET_CURRENT_PAGE_NUMBER:
            if(getPdfController() != nil){
                result(getPdfController()!.currentPage)
            }
            result(FlutterError.init(code: "pdfcontroller is null", message: nil, details: nil))
            break


        case Constants.KEY_GET_UNIQUE_ANNOTATIONID:
            if(getPdfController() != nil){
                result(generateUUID())
            }
            result(FlutterError.init(code: "pdfcontroller is null", message: nil, details: nil))
            break
        case Constants.KEY_INTERACTION_ENABLED:
            if let args = call.arguments as? Dictionary<String, Any>,
               let interactionEnabled = args["interactionEnabled"] as? Bool{
                // use number and times as required, for example....
                print("PDF Tron userinteraction ---> \(interactionEnabled)")
                getPdfController()?.isUserInteractionEnabled = interactionEnabled ?? false
                result(nil)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_OBSERVATION_LIST:
            if let args = call.arguments as? Dictionary<String, Any>,
               let param = args["observationList"] as? String{
                let highLightFormId = args[Constants.KEY_HIGHLIGHT_FORM_ID] as? String
                let data = param.data(using: .utf8)!
                let pages = pdfCtrl?.pageCount ?? 0
                for i in 1...pages{
                    let arrFloatingViews = pdfCtrl?.floatingViews(onPage: i) as? [UIView] ?? [UIView]()
                    pdfCtrl?.removeFloating(arrFloatingViews)
                }
                
                var observationList = [ObservationData]()
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
                    {
                        for observation in jsonArray{
                            let observationData = ObservationData(dictionary: observation as NSDictionary)
                            observationList.append((observationData ?? ObservationData(dictionary: NSDictionary()))!)
                        }
                        print("Items -------> \(observationList)")
                        pdfCtrl?.docLock(true)
                        for observationData in observationList{
                            let locationData = observationData.coordinates ?? ""
                            if let location = try JSONSerialization.jsonObject(with: locationData.data(using: .utf8)!, options : .allowFragments) as? Dictionary<String,Any>{
                                if ((location["x1"] != nil) && (location["y1"] != nil))
                                {
                                    var sharePin = 1
                                    let appType = observationData.appType
                                    let appBuilderID = observationData.appBuilderID ?? ""
                                    if(Constants.appBuilderIds.contains(appBuilderID.lowercased())){
                                        sharePin = 0
                                    }
                                    addPinOnMap(x:location["x1"] as? Double ?? 0.0, y: location["y1"] as? Double ?? 0.0,annotationId: observationData.formId ?? "", name: observationData.formTypeCode!, bgColor: hexStringToUIColor(hex: (observationData.statusVO?.bgColor!)!), type: sharePin, isDotted: false, isHighlighted: observationData.formId == highLightFormId,page: observationData.pageNumber ?? 0)
                                }
                            }
                        }
                        pdfCtrl?.docUnlock()
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
                
                
                result(nil)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_CREATE_TEMP_PIN:
            if let args = call.arguments as? Dictionary<String, Any>,
               let param = args["param"] as? String{
                // use number and times as required, for example....
                pdfCtrl?.docLock(true)
                let points = self.convertStringToDictionary(json: param)
                addPinOnMap(x: points!["X"] as? Double ?? 0, y: points!["Y"] as? Double ?? 0,annotationId: "", name: "DEF", bgColor: UIColor.blue, type: 0, isDotted: false, isHighlighted: false, page: Int(pdfCtrl?.currentPage ?? 0));
                pdfCtrl?.docUnlock()
                result(nil)
            } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
        case Constants.KEY_GENERATE_THUMBNAIL:
            if let args = call.arguments as? Dictionary<String, Any>,
               let param = args["param"] as? String{
                let dict = self.convertStringToDictionary(json: param)
                let pageNum = dict?[Constants.KEY_PAGE_NUMBER] as? Int ?? 0
                let thumbnailPath = dict?[Constants.KEY_THUMBNAIL_PATH] as? String ?? ""
                getPdfController()?.cancelAllThumbRequests()
                
                let ptPage : PTPage = getPdfController()?.getDoc()?.getPage(UInt32(pageNum)) ?? PTPage()
                let image = ptPage.thumbnail(withMaximumSize: CGSize(width: 200, height: 200))
                var urlString : URL
                if #available(iOS 16.0, *) {
                    urlString = URL(filePath: thumbnailPath)
                } else {
                    // Fallback on earlier versions
                    urlString = URL(fileURLWithPath: thumbnailPath)
                }
                print("Image path : \(urlString)")
                if !FileManager.default.fileExists(atPath: urlString.path) {
                    do {
                        let resizedImage = image//image?.imageResized(to: CGSize(width: 200, height: 200))
                        try resizedImage?.jpegData(compressionQuality: 1.0)!.write(to: urlString as URL)
                        result(nil)
                        print ("Image Added Successfully")
                    } catch {
                        print ("Image Not added")
                        result(nil)
                    }
                }else{
                     print ("Image Already Exists")
                     result(nil)
                 }



//                getPdfController()?.getThumbAsync(Int32(pageNum), completion: { image in
//                    var urlString : URL
//                    if #available(iOS 16.0, *) {
//                        urlString = URL(filePath: thumbnailPath)
//                    } else {
//                        // Fallback on earlier versions
//                        urlString = URL(fileURLWithPath: thumbnailPath)
//                    }
//                    print("Image path : \(urlString)")
//                    if !FileManager.default.fileExists(atPath: urlString.path) {
//                        do {
//                            let resizedImage = image?.imageResized(to: CGSize(width: 200, height: 200))
//                            try resizedImage?.jpegData(compressionQuality: 1.0)!.write(to: urlString as URL)
//                            result(nil)
//                            print ("Image Added Successfully")
//                        } catch {
//                            print ("Image Not added")
//                            result(nil)
//                        }
//                    }
//                })
                
            }else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
            }
            break
            case Constants.KEY_POLYGONANNOTATION:
            if let args = call.arguments as? Dictionary<String, Any>,
                          let param = args["param"] as? String{
                           // use number and times as required, for example....
                           let points = self.convertStringToDictionary(json: param)
                    
                    let x1 = points!["x1"] as? Double
                    let y1 = points!["y1"] as? Double
                    let locationAngle = points!["locationAngle"] as? Double
                    
                    let annotId = points!["annotId"] as? Double
               
                PDFTronUtils.polygonAnnotation(mPDFViewCtrl: getPdfController()!, x1:x1!,y1: y1!,locationAngle: locationAngle!,annotId: annotId!)
//
                                }
                           
           
           break
        default:
            print("Nothing")
        }
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    override class func register(withFrame frame: CGRect, viewIdentifier viewId: Int64, messenger: FlutterBinaryMessenger) -> PdftronFlutterPlugin {
        pdfTronPlugin = nil
        pdfTronPlugin = super.register(withFrame: frame, viewIdentifier: viewId, messenger: messenger)
        
        let channelName = String(format: "asite/pdftron_flutter/documentview_%lld", viewId)
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        let instance = FLNativeView()
        
        //    instance.widgetView = NO;
//        weak var weakInstance = instance
        channel.setMethodCallHandler { call, result in
//            let instance = weakInstance
            if instance != nil {
                instance.handle(call, result: result)
            }
        }
        instance.registerEventChannel(messenger: messenger)
        
        return instance
    }
    func getPdfController() -> PTPDFViewCtrl? {
        pdfCtrl = PDFTronUtils.getDocumentController(pdfTronPlugin: pdfTronPlugin!).pdfViewCtrl
        pdfCtrl?.isDirectionalLockEnabled = false
        return pdfCtrl
    }
    func generateUUID()->String{
        let timeInterval = Date().timeIntervalSince1970
        let strAnnotationId = String(format: "%@-%.0f", UUID().uuidString, timeInterval)
        return strAnnotationId
    }
    
    func registerEventChannel(messenger:FlutterBinaryMessenger){
        
        let annotSelectEventChannel = FlutterEventChannel(name: Constants.KEY_ON_ANNOT_SELECTED_LISTENER_EVENT, binaryMessenger: messenger)
        let createPinEventChaannel = FlutterEventChannel(name: Constants.KEY_ON_LONG_PRESS_DOCUMENT_LISTENER_EVENT, binaryMessenger: messenger)
        let createOnPressEventChaannel = FlutterEventChannel(name: Constants.KEY_ON_PRESS_DOCUMENT_LISTENER_EVENT, binaryMessenger: messenger)
        let createOnZoomEventChaannel = FlutterEventChannel(name: Constants.KEY_ON_ZOOM_DOCUMENT_LISTENER_EVENT, binaryMessenger: messenger)
        let pinTapEventChannel = FlutterEventChannel(name: Constants.KEY_ON_PIN_TAP_LISTENER_EVENT, binaryMessenger: messenger)
        let pdfScrollEventChannel = FlutterEventChannel(name: Constants.KEY_ON_SCROLL_LISTENER_EVENT, binaryMessenger: messenger)
        
        annotSelectEventChannel.setStreamHandler(self)
        createPinEventChaannel.setStreamHandler(self)
        createOnPressEventChaannel.setStreamHandler(self)
        createOnZoomEventChaannel.setStreamHandler(self)
        pinTapEventChannel.setStreamHandler(self)
        pdfScrollEventChannel.setStreamHandler(self)
    }
    //PRAGMA MARK - event channel handle methods
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        switch(arguments as? Int){
        case 0:
            annotationSelectedEventSink = events
            break
        case 1:
            createPinEventSink = events
            break
        case 2:
            tapOnPinEventSink = events
            break
             case 3:
            createOnPressEventSink = events
            break
        case 4:
            createOnZoomEventSink = events
            break
        case 5:
            pdfScrollEventSink = events
            break
        default:
            break
        }
        return nil
    }
    //PRAGMA MARK - PdfEventDelegate methods
    func getTapOnPin(formId: String, width: Double, height: Double) {
        //pin click event
    }
    func pdfTronScrolled() {
        if let event = self.pdfScrollEventSink{
            let annotaionDict = [
                "isScroll":"true"
            ] as [String : Any]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: annotaionDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
    }
    func getSelectedAnnotation(annotationId: String, isLocationAnnot:Bool) {
        if let event = self.annotationSelectedEventSink{
            let annotaionDict = [
                "annotationId":annotationId,
                "isLocationAnnot":isLocationAnnot,
            ] as [String : Any]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: annotaionDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
    }
    func createPinAnnotation(pts: CGPoint) {
        if let event = self.createPinEventSink{
            let pinDict = ["X":pts.x,"Y":pts.y] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: pinDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
    }
    func createOnPressAnnotation(pts: PTPDFPoint) {
        if let event = self.createOnPressEventSink{
            let pagePoint = getPdfController()!.convScreenPt(toCanvasPt: PTPDFPoint(px: pts.x, py: pts.y))
            
            
            var rotation = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getRotation().rawValue
            
                   
            var x = 0.0
            var y = 0.0
            
            var width = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getWidth(PTBox(UInt32(getpagesize())))
            var height = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getHeight(PTBox(UInt32(getpagesize())))

            
            if(rotation! == 0){
                x = pagePoint.x * 2
                y = pagePoint.y * 2
            }

            if(rotation! == 1){
                x = pagePoint.y * 2
                y = width! - (pagePoint.x * 2)
            }

            if(rotation! == 2){
                x = width! - (pagePoint.x * 2)
                y = height! - (pagePoint.y * 2)
            }

            if(rotation! == 3){
                x = height! - (pagePoint.y * 2)
                y = pagePoint.x * 2
            }

            
            let pinDict = ["X":x, "Y":y] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: pinDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
     }    
    // func createOnPressAnnotation(pts: PTPDFPoint) {
    //     if let event = self.createOnPressEventSink{
    //         let pagePoint = getPdfController()!.convScreenPt(toPagePt: PTPDFPoint(px: pts.x, py: pts.y), page_num: getPdfController()!.currentPage)
    //         let ypoint =  (pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage)).getWidth(PTBox(UInt32(getpagesize()))))!-pagePoint.y
    //         let pinDict = ["X":pagePoint.x,"Y":ypoint] as [String : Any]
    //         let jsonData = try! JSONSerialization.data(withJSONObject: pinDict)
    //         let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
    //         event(jsonString)
    //     }
    // }
    func createOnZoomAnnotation(pts: PTPDFPoint) {
        if let event = self.createOnZoomEventSink{
            let pagePoint = getPdfController()!.convScreenPt(toCanvasPt: PTPDFPoint(px: pts.x, py: pts.y))
            
            
            var rotation = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getRotation().rawValue
            
                   
            var x = 0.0
            var y = 0.0
            
            var width = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getWidth(PTBox(UInt32(getpagesize())))
            var height = pdfCtrl?.getDoc()?.getPage(UInt32(pdfCtrl!.currentPage))?.getHeight(PTBox(UInt32(getpagesize())))

            
            if(rotation! == 0){
                x = pagePoint.x * 2
                y = pagePoint.y * 2
            }

            if(rotation! == 1){
                x = pagePoint.y * 2
                y = width! - (pagePoint.x * 2)
            }

            if(rotation! == 2){
                x = width! - (pagePoint.x * 2)
                y = height! - (pagePoint.y * 2)
            }

            if(rotation! == 3){
                x = height! - (pagePoint.y * 2)
                y = pagePoint.x * 2
            }

            
            let pinDict = ["X":x, "Y":y] as [String : Any]
            let jsonData = try! JSONSerialization.data(withJSONObject: pinDict)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            event(jsonString)
        }
    }
    
    
    //MARK : PTPDFCtrlDelegate methods
    func pdfViewCtrl(_ pdfViewCtrl: PTPDFViewCtrl, gotThumbAsync page_num: Int32, thumbImage image: UIImage?) {
        print(image)
    }
    func addPinOnMap(x:Double,y:Double,annotationId : String,name:String,bgColor:UIColor,type:Int,isDotted:Bool,isHighlighted:Bool,page:Int){
        let ovalPin  = customPinView.createPinnedView(CGPoint.zero, name:name, bgColor: bgColor, type: type, isDotted: isDotted, isHighlited: isHighlighted)
        ovalPin?.tag = 1001
        ovalPin?.accessibilityElements = [Any]()
        ovalPin?.accessibilityLabel = ""
        ovalPin?.accessibilityValue = "1234"
        let size = isHighlighted ? 1.8 : 1.0
        let transparentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        ovalPin?.frame = CGRect(x: -20.0*size, y: -40.0*size, width: 40.0*size, height: 40.0*size)
        transparentView.touchAreaInsets = UIEdgeInsets(top: 40.0*size, left: 20.0*size, bottom: 0.0, right: 20.0*size)
        transparentView.accessibilityIdentifier = annotationId
        transparentView.accessibilityElements = [Any]()
        transparentView.accessibilityLabel = ""
        transparentView.accessibilityValue = "1234"
        transparentView.addSubview(ovalPin!)
        
        let pts = PTPDFPoint(px: x, py: y)
        pdfCtrl?.addFloating(transparentView, toPage: Int32(page), atPagePoint: pts!)
        if(size == 1.8){
            transparentView.isHidden = true
            UIView.animate(withDuration: 0.0,
                animations: {
                transparentView.isHidden = false
                transparentView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                },
                completion: { _ in
                UIView.animate(withDuration: 1.0) {
                        transparentView.transform = CGAffineTransform.identity
                    }
                })
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnPin(gesture:)))
        tap.numberOfTapsRequired = 1
        transparentView.isUserInteractionEnabled = true
        transparentView.addGestureRecognizer(tap)
        pdfCtrl?.update()
    }
    //    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
    //        return
    //    }
}
extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
