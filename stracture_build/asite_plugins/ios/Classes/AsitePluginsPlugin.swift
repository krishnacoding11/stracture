import Flutter
import UIKit
import CryptoSwift
import KeychainSwift
import Security
//import KeychainItemWrapper

public class AsitePluginsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "asite_plugins", binaryMessenger: registrar.messenger())
    let instance = AsitePluginsPlugin()
    let keychain = KeychainSwift()
    keychain.set("U1QyeS9HaGlMVit3MWN6PQ==", forKey: "ctrKey")
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let keychain = KeychainSwift()
        if(call.method == "encrypt"){
            guard let args = call.arguments as? [String : Any] else {return}
            let data = args["data"] as? String ?? ""
            let key = keychain.get("ctrKey") ?? ""
            let algoType = args["algoType"] as? Int ?? 0
            if(algoType == 1){
                let encryptedString = CryptoHelper.encryptWithCTR(dataFromFlutter: data, keyFromFlutter: key)
                self.encrypt(result: result, encrypted: encryptedString!)
            }
            else{
                let encryptedString = CryptoHelper.encrypt(dataFromFlutter: data, keyFromFlutter: key)
                self.encrypt(result: result, encrypted: encryptedString!)
            }
          return
        }else if(call.method == "decrypt"){
            guard let args = call.arguments as? [String : Any] else {return}
            let data = args["data"] as? String ?? ""
            let key = keychain.get("ctrKey") ?? ""
            let algoType = args["algoType"] as? Int ?? 0
            if(algoType == 1){
                let decryptedString = CryptoHelper.decryptWithCTR(dataFromFlutter: data, keyFromFlutter: key)
                self.decrypt(result: result, decrypted: decryptedString!)
            }
            else{
                let decryptedString = CryptoHelper.decrypt(dataFromFlutter: data, keyFromFlutter: key)
                self.decrypt(result: result, decrypted: decryptedString!)
            }
          return
        }else if(call.method == "uniqueAnnotationId"){
            result(Utils.getUniqueAnnotationId())
        }else if(call.method == "uniqueDeviceId"){
            var deviceId = "";
            deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? ""
            if(deviceId.isEmpty)
            {
                deviceId = generateDeviceId() ?? "";
                UserDefaults.standard.set(deviceId, forKey: "deviceId")
            }
            result(deviceId)
            
          //  result(Utils.getUniqueDeviceId())
        }else{
            result(FlutterMethodNotImplemented)
            return
        }
    }

    private func encrypt(result: FlutterResult, encrypted: String) {
             result(encrypted)
      }

      private func decrypt(result: FlutterResult, decrypted: String) {
             result(decrypted)
      }
    func generateDeviceId() -> String? {
        let deviceId = UUID().uuidString
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "com.asite.field",
            kSecAttrService: "com.asite.field",
            kSecValueData: deviceId.data(using: .utf8)!
        ] as [String: Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return deviceId
        }
        
        return deviceId
    }
    
}
