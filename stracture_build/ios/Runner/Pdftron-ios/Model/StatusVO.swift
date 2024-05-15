/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class StatusVO {
	public var statusId : Int?
	public var statusName : String?
	public var statusTypeId : Int?
	public var statusCount : Int?
	public var bgColor : String?
	public var fontColor : String?
	public var generateURI : Bool?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let statusVO_list = StatusVO.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of StatusVO Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [StatusVO]
    {
        var models:[StatusVO] = []
        for item in array
        {
            models.append(StatusVO(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let statusVO = StatusVO(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: StatusVO Instance.
*/
	required public init?(dictionary: NSDictionary) {

		statusId = dictionary["statusId"] as? Int
		statusName = dictionary["statusName"] as? String
		statusTypeId = dictionary["statusTypeId"] as? Int
		statusCount = dictionary["statusCount"] as? Int
		bgColor = dictionary["bgColor"] as? String
		fontColor = dictionary["fontColor"] as? String
		generateURI = dictionary["generateURI"] as? Bool
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.statusId, forKey: "statusId")
		dictionary.setValue(self.statusName, forKey: "statusName")
		dictionary.setValue(self.statusTypeId, forKey: "statusTypeId")
		dictionary.setValue(self.statusCount, forKey: "statusCount")
		dictionary.setValue(self.bgColor, forKey: "bgColor")
		dictionary.setValue(self.fontColor, forKey: "fontColor")
		dictionary.setValue(self.generateURI, forKey: "generateURI")

		return dictionary
	}

}