//
//  PDFMethodCallHandler.swift
//  Runner
//
//  Created by Maulik Kundaliya on 24/08/22.
//

import Foundation
import pdftron_flutter

//class PdftronMethodCallHandler : FlutterMethodChannel,SiteOperationProtocol{
//    var flutterMethodChannel : FlutterMethodChannel?
//    var siteOperationProtocol: SiteOperationProtocol?
//    var messenger : FlutterBinaryMessenger?
//    var id : int
//    
//    override init() {
//        super.init()
//        siteOperationProtocol = self
//        flutterMethodChannel = FlutterMethodChannel(name: "asite/pdftron_flutter/documentview_\(id)", binaryMessenger: messenger)
//        flutterMethodChannel?.setMethodCallHandler({ <#FlutterMethodCall#>, <#@escaping FlutterResult#> in
//            <#code#>
//        })
//    }
//    func deleteAllAnnotation(mPDFViewCtrl: PTPDFViewCtrl, annotType: Int) {
//        <#code#>
//    }
//    
//    func setDocumentEventListener(tab: Int) {
//        <#code#>
//    }
//    
//    func drawPinsAnnotations(mPDFViewCtrl: PTPDFViewCtrl, observations: String) {
//        <#code#>
//    }
//    
//    func highlightSelectedLocation(mPDFViewCtrl: PTPDFViewCtrl, annotationId: String) {
//        <#code#>
//    }
//    
//    func onAnnotationSelectedListener(selectedAnnot: PTAnnot) {
//        <#code#>
//    }
//    
//    func createPushPinAnnot(mPDFViewCtrl: PTPDFViewCtrl, x: Double, y: Double, mDownPageNum: Int, annotationId: String, isHighLight: Bool, appBuilderID: String, formTypeCode: String) {
//        <#code#>
//    }
//    
//    func onPinAnnotSingleClick(data: String) {
//        <#code#>
//    }
//    
//    
//}
