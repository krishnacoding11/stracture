//
//  CustomPinView.swift
//  Runner
//
//  Created by Maulik Kundaliya on 12/09/22.
//

import UIKit

class CustomPinView: UIView {
//    enum PinShape : Int {
//        case OVAL = 1
//        case RECT = 0
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func createPinnedView(_ points: CGPoint, name: String?, bgColor pinColor: UIColor?, type: Int, isDotted: Bool, isHighlited: Bool) -> UIView? {
        // Create a container view for the pinned content.
        var size = 1.0
        if isHighlited == true {
            size = 1.8
        }
        let pinnedContainerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: CGFloat(40.0 * size), height: CGFloat(40.0 * size)))
        pinnedContainerView.clipsToBounds = false
        pinnedContainerView.backgroundColor = UIColor.clear
        // The pinned content. A label in this case.
//        let pinnedView = UILabel(frame: CGRect(x: CGFloat(10.0 * size), y: CGFloat(5.0 * size), width: CGFloat(pinnedContainerView.frame.size.width - (20.0 * size)), height: CGFloat(20.0 * size)))
//        pinnedView.translatesAutoresizingMaskIntoConstraints = true
//        pinnedView.backgroundColor = UIColor.white
//        pinnedView.text = name
//        pinnedView.textColor = pinColor
//        pinnedView.textAlignment = .center
//        pinnedView.font = UIFont.systemFont(ofSize: 8)
        let imgvPin = UIImageView(frame: CGRect(x: 0, y: 0, width: pinnedContainerView.frame.size.width, height: pinnedContainerView.frame.size.height))
        var centerImgStr = ""
        if type == 0 {
            imgvPin.image = UIImage(named: "site-pin")
            centerImgStr = "usr-center"
        }else{
            imgvPin.image = UIImage(named: "form-pin")
            centerImgStr = "frm-center"
        }
        
        
        imgvPin.contentMode = .scaleAspectFit
        imgvPin.translatesAutoresizingMaskIntoConstraints = true
        let tintBGImg = tintedImage(imgvPin.image!, withTint: pinColor)!
        let tintCenterImg = tintedImage(UIImage(named: centerImgStr)!, withTint: UIColor.white)!
        imgvPin.image = combineImage(bgImage: tintBGImg, centerImage: tintCenterImg, tintColor: pinColor!)
        pinnedContainerView.addSubview(imgvPin)
//        imgvPin.addSubview(pinnedView)
        return pinnedContainerView
    }
    
    func tintedImage(_ img: UIImage?, withTint tintColor: UIColor?) -> UIImage? {
        var newImage = img?.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(img?.size ?? CGSize.zero, false, newImage?.scale ?? 0.0)
        tintColor?.set()
        newImage?.draw(in: CGRect(x: 0, y: 0, width: img?.size.width ?? 0.0, height: newImage?.size.height ?? 0.0))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func combineImage(bgImage : UIImage?,centerImage : UIImage, tintColor: UIColor) -> UIImage{
        let bottomImage = bgImage! // 355 X 200
        let topImage = centerImage  // 355 X 60

        var newSize = CGSizeMake(bottomImage.size.width, bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, bottomImage.scale)
        bottomImage.draw(in:CGRect(x:0,y:0,width:newSize.width,height:newSize.height))
        topImage.draw(in:CGRect(x:(bottomImage.size.width/2 - topImage.size.width/2),y:(bottomImage.size.height/2 - topImage.size.height/2) - 5,width:topImage.size.width,height:topImage.size.height), blendMode:CGBlendMode.normal, alpha:1.0)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
