import UIKit
import AVKit
import Flutter
import PDFNet
import MobileCoreServices
import AVFoundation
import flutter_local_notifications
import KeychainSwift
import FirebaseMessaging

let gcmMessageIDKey = "gcm.message_id"
let eventCategory = "eventCategory"
let languageId = "languageId"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,MessagingDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private let linkStreamHandler = LinkStreamHandler()
    var documentInteractionController: UIDocumentInteractionController!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

     // This is required to make any communication available in the action isolate.
          FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
              GeneratedPluginRegistrant.register(with: registry)
          }

          if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
          }
        GeneratedPluginRegistrant.register(with:self)

        UNUserNotificationCenter.current().delegate = self
        //  FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        let controller = window.rootViewController as! FlutterViewController
        
        methodChannel = FlutterMethodChannel(name: "addodle.deeplinkc/channel", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        eventChannel = FlutterEventChannel(name: "addodle.deeplinke/events", binaryMessenger: controller as! FlutterBinaryMessenger)
       
        methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
          guard call.method == "initialLink" else {
            result(FlutterMethodNotImplemented)
            return
          }
        })
        
        let imageCompressMethodChannel = FlutterMethodChannel(name: Constants.KEY_IMAGE_PATH,
                                                      binaryMessenger: controller.binaryMessenger)
        imageCompressMethodChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
            print("-------->\(call.method)")
            if call.method == "imageCompression"{
                guard let args = call.arguments as? [String : Any] else {return}
                let path = args["imagePath"] as? String ?? ""
                let imageType = args["imageType"] as? String ?? ""
                if(imageType.lowercased() == "profile"){
                    let compressedPath = Utility.getCompressedProfilePicImageFromPath(imgPath: path)
                    result(compressedPath)
                }else{
                    let compressedPath = Utility.getCompressedImageFromPath(imgPath: path)
                    result(compressedPath)
                }
                return
            }
        })
        
        let openDocumentMethodChannel = FlutterMethodChannel(name: Constants.KEY_OPEN_DOCUMENT_VIEWER,
                                                             binaryMessenger: controller.binaryMessenger)
        openDocumentMethodChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
            print("-------->\(call.method)")
            guard let args = call.arguments as? [String : Any] else {return}
            let path = args["filePath"] as? String ?? ""
            if (call.method == "openAudio" || call.method == "openVideo"){
                self.openPlayer(strPath: path)
            }
            else{
                self.openDocument(strPath: path)
            }
            return
        })
        
        let flashMethodChannel = FlutterMethodChannel(name: Constants.KEY_TORCH_AVAILABLE,
                                                      binaryMessenger: controller.binaryMessenger)
        flashMethodChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
            if call.method == "flashAvailable"{
                result(self.isFlashAvailable())
                return
            }
        })




        let buildFlavourChannel = FlutterMethodChannel(name: "build_flavor", binaryMessenger: controller.binaryMessenger)

        buildFlavourChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            if(call.method == "getFlavor"){
                let schemeName = Bundle.main.infoDictionary!["CURRENT_SCHEME_NAME"] as! String
                result(schemeName)
                return
            }
        })


        weak var registrar = self.registrar(forPlugin: "pdftron")
        
        let factory = FLNativeViewFactory(messenger: registrar!.messenger())
        registrar!.register(
            factory,
            withId: "asite/pdftron_flutter/documentview")
        
        eventChannel?.setStreamHandler(linkStreamHandler)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])

    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification")
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        // gcm_message_id
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }

    override  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                               fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
      
        if(userInfo["eventCategory"] as? String == "4" && userInfo["languageId"] != nil)
        {
            let alertController:UIAlertController = UIAlertController(title: "Message", message: "Your preferred language is updated on Asite. Please Re-login/Relaunch to view the application in your preferred language.", preferredStyle: UIAlertController.Style.alert)
            let alertAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:nil)
            alertController.addAction(alertAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            return;
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    override func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

       Messaging.messaging().apnsToken = deviceToken
      // print("Token: \(deviceToken)")
       super.application(application,
       didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
     }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    //    print("iOS fcmToken: \(String(describing: fcmToken))")
//        Messaging.messaging().apnsToken = deviceToken
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool
    {
        eventChannel?.setStreamHandler(linkStreamHandler)
        let univrsalLinkURL = userActivity.webpageURL!.absoluteString
        return linkStreamHandler.handleLink(univrsalLinkURL)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        eventChannel?.setStreamHandler(linkStreamHandler)
        return linkStreamHandler.handleLink(url.absoluteString)
    }


    private func isFlashAvailable() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else {
            return false
        }
        return device.hasFlash
    }
    
    private func openDocument(strPath: String){
        let temp = NSURL(fileURLWithPath: strPath)
        let fileUrl = temp as URL
        
        documentInteractionController = UIDocumentInteractionController()
        documentInteractionController.url = fileUrl
        //documentInteractionController.uti = fileUrl.uti
        if let tempView = self.window.rootViewController?.view{
            documentInteractionController.presentOpenInMenu(from: CGRectZero, in: tempView, animated: false)
        }
    }
    
    private func openPlayer(strPath: String){
        let temp = NSURL(fileURLWithPath: strPath)
        let fileUrl = temp as URL
        let player = AVPlayer(url: fileUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.window.rootViewController?.present(playerViewController, animated: true,completion: {
            player.play()
        })
    }
}



class LinkStreamHandler:NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?

    // links will be added to this queue until the sink is ready to process them
    var queuedLinks = [String]()

    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func handleLink(_ link: String) -> Bool {
        guard let eventSink = eventSink else {
            queuedLinks.append(link)
            return false
        }
        eventSink(link)
        return true
    }
}
