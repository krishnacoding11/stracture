package com.asite.field.pdftron.view

import android.content.Context
import com.asite.field.pdftron.methods.PdftronMethodCallHandler
import com.asite.field.pdftron.utils.PdftronUtils
import com.pdftron.pdftronflutter.FlutterDocumentView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Created by Chandresh Patel on 25-07-2022.
 */
class PdftronDocumentView internal constructor(
    context: Context,
    activityContext: Context,
    messenger: BinaryMessenger,
    id: Int
) : FlutterDocumentView(context, activityContext, messenger, id) {
    private var pdftronMethodCallHandler: PdftronMethodCallHandler

    init {
        pdftronMethodCallHandler = PdftronMethodCallHandler(messenger, id, this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method.startsWith(PdftronUtils.viewTypeId)) {
            pdftronMethodCallHandler.onMethodCall(call, result)
        } else {
            super.onMethodCall(call, result)
        }
    }

    override fun onFlutterViewDetached() {
       // (view as DocumentView).pdfViewCtrl?.cancelAllThumbRequests()
        super.onFlutterViewDetached()
    }
}