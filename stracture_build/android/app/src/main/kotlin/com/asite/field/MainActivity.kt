package com.asite.field

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Matrix
import android.media.ExifInterface
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.FileProvider
import com.asite.field.pdftron.factories.PdftronDocumentViewFactory
import com.asite.field.pdftron.utils.PdftronUtils
import com.asite.field.utils.CommonUtility.Companion.getMimeType
import id.zelory.compressor.Compressor
import id.zelory.compressor.constraint.format
import id.zelory.compressor.constraint.quality
import id.zelory.compressor.constraint.resolution
import id.zelory.compressor.constraint.size
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File


class MainActivity : FlutterFragmentActivity() {
    private val BUILD_FLAVOR: String = "build_flavor"
    private val AUTHORITY: String = "com.asite.field.flutter_inappwebview.fileprovider"
    private val CHANNEL = "addodle.deeplinkc/channel"
    private val IAMGECHANNEL = "flutter.native/imageCompression"
    private val EVENTS = "addodle.deeplinke/events"
    private val CHANNELAGENT = "addodle.useragent/channel"
    private var startString: String? = null
    private var linksReceiver: BroadcastReceiver? = null
    private val OPEN_DOCUMENT_VIEWER = "flutter.native/opendocumentviewer"
    private val TORCH_AVAILABLE = "flutter.native/flashAvailable"
    private val APP_LABLE = "flutter.native/getapplabel"
    private val CHANNELENCCTR = "encctr/decctr"
    private val DEVICE_ID = "device_ID"
    private val DEVICE_TOKEN = "device_token"

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                PdftronUtils.viewTypeId,
                PdftronDocumentViewFactory(
                    flutterEngine.dartExecutor.binaryMessenger,
                    this
                )
            )
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor,
            BUILD_FLAVOR
        ).setMethodCallHandler { call, result ->
            result.success(BuildConfig.FLAVOR)
        }

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialLink") {
                if (startString != null) {
                    result.success(startString)
                }
            }
        }
        EventChannel(flutterEngine.dartExecutor, EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventChannel.EventSink) {
                    linksReceiver = createChangeReceiver(events)
                }

                override fun onCancel(args: Any?) {
                    linksReceiver = null
                }
            }
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNELAGENT
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("getUserAgent")) {
                result.success(System.getProperty("http.agent"))
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor, IAMGECHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "imageCompression") {
                var path: String = call.argument<String>("imagePath") ?: "file_picker/download.jpeg"
                var quality = call.argument<Int>("quality") ?: 85
                var maxFileSize = (call.argument<Int>("maxFileSize") ?: 0).toLong()
                GlobalScope.launch {
                    val compressedImageFile = Compressor.compress(applicationContext, File(path)) {
                        resolution(1080, 1920)
                        quality(quality)
                        format(Bitmap.CompressFormat.JPEG)
                        if (maxFileSize > 0)
                            size(maxFileSize) // 300 KB
                    }
                    result.success(compressedImageFile!!.path)
                }
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor,
            OPEN_DOCUMENT_VIEWER
        ).setMethodCallHandler { call, result ->
            if (listOf("openDocument", "openVideo", "openAudio").contains(call.method)) {
                var path: String = call.argument<String>("filePath") ?: ""
                if (!path.isNullOrEmpty()) {
                    openDocument(path)
                }
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor,
            TORCH_AVAILABLE
        ).setMethodCallHandler { call, result ->
            result.success(isFlashAvailable())
        }

        MethodChannel(
            flutterEngine.dartExecutor,
            APP_LABLE
        ).setMethodCallHandler { call, result ->
            result.success(getAppLabel())
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = getIntent()
        startString = intent.getData()?.toString()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action === Intent.ACTION_VIEW) {
            linksReceiver?.onReceive(this.applicationContext, intent)
        }
    }

    fun createChangeReceiver(events: EventChannel.EventSink): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(
                context: Context,
                intent: Intent
            ) { // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW
                val dataString =
                    intent.dataString ?: events.error("UNAVAILABLE", "Link unavailable", null)
                events.success(dataString.toString())
            }
        }
    }

    fun isFlashAvailable(): Boolean {
        return applicationContext.getPackageManager()
            .hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
    }

    fun openDocument(filePath: String) {
        Log.v("FilePath: ", "Path: - $filePath")
// Get URI and MIME type of file
        val uri = FileProvider.getUriForFile(applicationContext, AUTHORITY, File(filePath))
        val mime: String? = getMimeType(filePath)

// Open file with user selected app
        val intent = Intent()
        intent.action = Intent.ACTION_VIEW
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.setDataAndType(uri, mime)
        return startActivity(intent)
    }

    private fun rotateBitmap(bitmap: Bitmap, orientation: Int): Bitmap? {
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_NORMAL -> return bitmap
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.setScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                matrix.setRotate(180f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.setRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.setRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(-90f)
            else -> return bitmap
        }
        try {
            val bmRotated =
                Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            bitmap.recycle()
            return bmRotated
        } catch (e: OutOfMemoryError) {
            e.printStackTrace()
            return null
        }
    }

    private fun getAppLabel(): String? {
        var applicationInfo: ApplicationInfo? = null
        try {
            applicationInfo = applicationContext.packageManager.getApplicationInfo(applicationContext.applicationInfo.packageName, 0);
        } catch (e: PackageManager.NameNotFoundException) {
            Log.d("TAG", "The package with the given name cannot be found on the system.")
        }
        return (if (applicationInfo != null) packageManager.getApplicationLabel(applicationInfo).toString() else null);
    }
}


