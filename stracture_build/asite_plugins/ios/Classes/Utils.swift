//
//  Utils.swift
//  asite_plugins
//
//  Created by Maulik Kundaliya on 24/05/23.
//

import Foundation
import UIKit

@objc class Utils : NSObject{
    @objc class func getUniqueAnnotationId()-> String?{
        let timeInterval = Date().timeIntervalSince1970
        let strAnnotationId = String(format: "%@-%.0f", UUID().uuidString, timeInterval)
        return strAnnotationId
    }
    @objc class func getUniqueDeviceId()-> String?{
            let strDeviceId = UUID().uuidString
            return strDeviceId
        }
}
