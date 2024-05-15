//
//  PdfTroneUtilsTest.swift
//  RunnerTests
//
//  Created by Maulik Kundaliya on 24/07/23.
//

import XCTest
@testable import Runner
import PDFNet
import pdftron_flutter


final class PdfTroneUtilsTest: XCTestCase {
    var pdfCtrl : PTPDFViewCtrl?
    var allAnnots = [PTAnnot]()
    var afterDelAnnots = [PTAnnot]()
    
    override func setUp() {
        super.setUp()
        setUpPDFTron()
    }
    func setUpPDFTron(){
        var pdfFilePath = Bundle.main.path(forResource: "8162567", ofType: "pdf")
        var xfdfFilePath = Bundle.main.path(forResource: "8162567", ofType: "xfdf")
        var docToOpen = PTPDFDoc(filepath: pdfFilePath!)
        pdfCtrl = PTPDFViewCtrl(frame: UIScreen.main.bounds)
        pdfCtrl?.setDoc(docToOpen!)
        let fdoc = PTFDFDoc.create(fromXFDF: xfdfFilePath!)
        docToOpen?.fdfMerge(fdoc)
    }
    func getAllAnnotationOfPlans(mPdfCtrl : PTPDFViewCtrl) -> [PTAnnot]{
        var arrAnnots = [PTAnnot]()
        
        for i in 1...mPdfCtrl.pageCount{
            arrAnnots.append(contentsOf: mPdfCtrl.getAnnotationsOnPage(Int32(i)))
        }
//        XCTAssertTrue(arrAnnots.count > 0)
        return arrAnnots
    }
    func testDeleteAllAnnotations(){
        allAnnots = getAllAnnotationOfPlans(mPdfCtrl: pdfCtrl!)
        PDFTronUtils.deleteAllAnnotation(mPDFViewCtrl: pdfCtrl!, annotType: PTAnnotType(UInt32(12)))//12 is using for stemp annotation
        afterDelAnnots = getAllAnnotationOfPlans(mPdfCtrl: pdfCtrl!)
        XCTAssertTrue(allAnnots.count > afterDelAnnots.count)
    }
    func testScrollToCenter(){
       
        
        allAnnots = getAllAnnotationOfPlans(mPdfCtrl: pdfCtrl!)
        PDFTronUtils.deleteAllAnnotation(mPDFViewCtrl: pdfCtrl!, annotType: PTAnnotType(UInt32(12)))//12 is using for stemp annotation
        afterDelAnnots = getAllAnnotationOfPlans(mPdfCtrl: pdfCtrl!)
        if(afterDelAnnots.count > 0){
            if(PDFTronUtils.isLocationAnnot(annot: afterDelAnnots.first!)){
                pdfCtrl?.zoom = 2.0
                PDFTronUtils.scrollToCenter(mPDFViewCtrl: pdfCtrl!, annotation: afterDelAnnots.first!, currentPageNumber:1)
                var beforeHScrollPos = pdfCtrl?.getHScrollPos()
                var beforeVScrollPos = pdfCtrl?.getVScrollPos()
                if(PDFTronUtils.isLocationAnnot(annot: afterDelAnnots.last!)){
                    PDFTronUtils.scrollToCenter(mPDFViewCtrl: pdfCtrl!, annotation: afterDelAnnots.last!, currentPageNumber:1)
                    var afterHScrollPos = pdfCtrl?.getHScrollPos()
                    var afterVScrollPos = pdfCtrl?.getVScrollPos()
                    
                    XCTAssertTrue((beforeHScrollPos != afterHScrollPos) || (beforeVScrollPos != afterVScrollPos))
                }else{
                    XCTAssertFalse(PDFTronUtils.isLocationAnnot(annot: afterDelAnnots.last!))
                }
            }else{
                XCTAssertFalse(PDFTronUtils.isLocationAnnot(annot: afterDelAnnots.first!))
            }
        }
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//
////        deleteAllAnnotations()
////        scrollToCenter()
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
