//
//  SiteOperationProtocol+.swift
//  Runner
//
//  Created by Maulik Kundaliya on 24/08/22.
//

import Foundation
import UIKit
import pdftron_flutter
import PDFNet

protocol SiteOperationProtocol{
    
    func deleteAllAnnotation( mPDFViewCtrl: PTPDFViewCtrl, annotType: Int)
    func setDocumentEventListener(tab:Int)
    func drawPinsAnnotations(mPDFViewCtrl: PTPDFViewCtrl, observations: String)
    func highlightSelectedLocation(mPDFViewCtrl: PTPDFViewCtrl,annotationId: String)
    func onAnnotationSelectedListener(selectedAnnot: PTAnnot)
    func createPushPinAnnot(
        mPDFViewCtrl: PTPDFViewCtrl,
        x: Double,
        y: Double,
        mDownPageNum: Int,
        annotationId: String,
        isHighLight: Bool,
        appBuilderID: String,
        formTypeCode: String
    )
    func onPinAnnotSingleClick(data:String)
}
