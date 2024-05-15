//
//  FLNativeViewFactory.swift
//  Runner
//
//  Created by Maulik Kundaliya on 12/08/22.
//

import Flutter
import UIKit
import pdftron_flutter

class FLNativeViewFactory: DocumentViewFactory {
    var tmpMessenger : FlutterBinaryMessenger
    var flNativeView : FlutterPlatformView?
    override init(messenger: FlutterBinaryMessenger) {
        self.tmpMessenger = messenger
        super.init()
    }

    override func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        flNativeView = nil
        flNativeView = FLNativeView.register(withFrame: frame, viewIdentifier: viewId, messenger: tmpMessenger)
        return flNativeView!
    }
}



