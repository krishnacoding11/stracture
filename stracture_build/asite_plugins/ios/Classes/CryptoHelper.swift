//
//  CryptoHelper.swift
//  Runner
//
//  Created by Maulik Kundaliya on 10/08/22.
//

import Foundation
import CryptoSwift


class CryptoHelper{
    let DEFAULT_CODING = "UTF-8";
    let ALGORITHM = "AES";
    let TRANSFORMATION = "AES/ECB/PKCS5Padding";
    private static let iv = "RF22SW76BV83EDH8";
    
    // ENC
    public static func encrypt(dataFromFlutter :String, keyFromFlutter :String) -> String? {
            do{
                guard let data = dataFromFlutter.data(using: .utf8) else {
                    return "DATA ERROR"
                }
                guard let keyData = Data(base64Encoded: keyFromFlutter) else {
                    return "DATA ERROR"
                }
                let key: [UInt8] = keyData.bytes
                let aes128 = try AES(key: key,blockMode: ECB(), padding: .pkcs5)
                let encrypted = try aes128.encrypt(data.bytes)
                return encrypted.toBase64()
            }catch{
                return "DATA ERROR"
            }
        }
    
    // DEC
    public static func decrypt(dataFromFlutter :String, keyFromFlutter :String) -> String? {
        do{
            guard let data = Data(base64Encoded: dataFromFlutter) else {
                return "DATA ERROR"
            }
            guard let keyData = Data(base64Encoded: keyFromFlutter) else {
                return "DATA ERROR"
            }
            let key: [UInt8] = keyData.bytes
            let aes128 = try AES(key: key,blockMode: ECB(), padding: .pkcs5)
            let decrypted = try aes128.decrypt(data.bytes)
            return String(data: Data(decrypted), encoding: .utf8)
        }catch{
            return "DATA ERROR"
        }
    }
    // ENC
    public static func encryptWithCTR(dataFromFlutter :String, keyFromFlutter :String) -> String? {
        let iv_0:  Array<UInt8> = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f];
            do{
                guard let data = dataFromFlutter.data(using: .utf8) else {
                    return "DATA ERROR"
                }
                guard let keyData = Data(base64Encoded: keyFromFlutter) else {
                    return "DATA ERROR"
                }
                let key: [UInt8] = keyData.bytes
                let aes128 = try AES(key: key,blockMode: CTR(iv: iv_0), padding: .noPadding)
                let encrypted = try aes128.encrypt(data.bytes)
                return encrypted.toBase64()
            }catch{
                return "DATA ERROR"
            }
        }
    
    // DEC
    public static func decryptWithCTR(dataFromFlutter :String, keyFromFlutter :String) -> String? {
        let iv_0:  Array<UInt8> = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f];
        do{
            guard let data = Data(base64Encoded: dataFromFlutter) else{
                return "DATA ERROR"
            }
            guard let keyData = Data(base64Encoded: keyFromFlutter) else {
                return "DATA ERROR"
            }
            let key: [UInt8] = keyData.bytes
            let aes128 = try AES(key: key,blockMode: CTR(iv: iv_0), padding: .noPadding)
            let decrypted = try aes128.decrypt(data.bytes)
            return String(data: Data(decrypted), encoding: .utf8)
        }catch{
            return "DATA ERROR"
        }
    }
}
