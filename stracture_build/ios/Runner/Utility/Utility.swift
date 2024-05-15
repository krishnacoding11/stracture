//
//  Utility.swift
//  Runner
//
//  Created by Maulik Kundaliya on 21/10/22.
//

import Foundation
import UIKit

@objc class Utility : NSObject{
    @objc class func getCompressedImageFromPath(imgPath :String) -> String?{
        var image = UIImage(contentsOfFile: imgPath)
        if(image == nil)
        {
            return ""
        }
        var imageData: Data?
        if let image = image!.jpegData(compressionQuality: 1.0) {
            imageData = image
        }

        let imageName = imgPath.components(separatedBy: "/").last ?? ""

        //Here we are storing the image for the temporary itme ..till the time we fetch the Image metadata and again add in the compressed image .becuase it is creating issue while thumbnail creation in html pages
//        let tempImagePath = Helper.saveImage(imageData)
//        let metadata = Helper.readImageMetadata(tempImagePath)
//        Helper.deleteSavedImage(tempImagePath) //Here we are deleting the temp Image

        print("[before] image size:--\(String(describing: imageData?.count))")
        let scale = (100 * 1024) / CGFloat(imageData!.count) // For 100KB.
            print("[scaled] image size:--\(scale)")
            var smallImage: UIImage? = nil
            if let CGImage = image!.cgImage {
                smallImage = UIImage(cgImage: CGImage, scale: scale, orientation: image!.imageOrientation)
            }
            imageData = smallImage?.jpegData(compressionQuality: scale * 0.85)
            print("[After] image size:\(imageData?.count ?? 0))")
        
        let compressedImagePath = Utility.saveImage(imageData,imageName) //Here we are saving the compressed image...
//        Utility.writeImageMetadata(compressedImagePath, properties: metadata) //Here we are adding the metaData in the image file again after compression..

        let fileManager = FileManager.default
        imageData = fileManager.contents(atPath: compressedImagePath!) //Here we are fetching the data from the path where the compressed image is written..
        return compressedImagePath
    }
    @objc class func getCompressedProfilePicImageFromPath(imgPath :String)->String?{
        var image = UIImage(contentsOfFile: imgPath)
        let imageName = imgPath.components(separatedBy: "/").last ?? ""
        let maxFileSize = 300*1024
        
        var imgData = image!.jpegData(compressionQuality: 1.0)
        if (imgData?.count ?? 0) > maxFileSize {
            image = Utility.image(with: image, scaledTo: CGSize(width: image!.size.height / 2, height: image!.size.height / 2))
        }
        if let cgImage = image?.cgImage {
            image = UIImage(
                cgImage: cgImage,
                scale: image!.scale,
                orientation: .up)
        }
        var compression: CGFloat = 0.9
        let maxCompression: CGFloat = 0.1
        while imgData!.count > maxFileSize && compression > maxCompression {
            compression -= 0.1
            imgData = image?.jpegData(compressionQuality: compression)
        }
        let compressedImagePath = Utility.saveImage(imgData,imageName)
        let fileManager = FileManager.default
        fileManager.createFile(atPath: compressedImagePath!, contents: imgData, attributes: nil)
        return compressedImagePath
    }
    @objc class func image(with image: UIImage?, scaledTo newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    //MARK:- saveImage :- here we are saving the temporaryImages...
    class func saveImage(_ imageData: Data?,_ imageName :String) -> String? {

        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        // we have to store the image at temporary location and also need o delete after we do not need it..
        //let imageName = "image.jpg" //getting the image name here only
        let fileURL = tmpDirURL.appendingPathComponent(imageName)

        let fileManager = FileManager.default
        fileManager.createFile(atPath: fileURL.path, contents: imageData, attributes: nil)

        return fileURL.path
    }
    class func writeImageMetadata(_ path: String?, properties metadata: [AnyHashable : Any]?) {

        let url = URL(fileURLWithPath: path ?? "")

        let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        var uniformTypeIdentifier: CFString? = nil
        if let source {
            uniformTypeIdentifier = CGImageSourceGetType(source)
        }

        var destination: CGImageDestination? = nil
        if let uniformTypeIdentifier {
            destination = CGImageDestinationCreateWithURL(url as CFURL, uniformTypeIdentifier, 1, nil)
        }
        if let destination, let source {
            CGImageDestinationAddImageFromSource(destination, source, 0, metadata! as CFDictionary)
        }
        if let destination {
            CGImageDestinationFinalize(destination)
        }
    }
    
}
