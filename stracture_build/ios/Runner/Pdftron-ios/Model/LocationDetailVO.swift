/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class LocationDetailVO {
	public var siteId : Int?
	public var locationId : Int?
	public var folderId : String?
	public var docId : String?
	public var revisionId : String?
	public var annotationId : String?
	public var coordinates : String?
	public var isFileAssociated : Bool?
	public var hasChildLocation : Bool?
	public var parentLocationId : Int?
	public var locationPath : String?
	public var isPFSite : Bool?
	public var isCalibrated : Bool?
	public var isLocationActive : Bool?
	public var projectId : String?
	public var generateURI : Bool?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let locationDetailVO_list = LocationDetailVO.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of LocationDetailVO Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [LocationDetailVO]
    {
        var models:[LocationDetailVO] = []
        for item in array
        {
            models.append(LocationDetailVO(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let locationDetailVO = LocationDetailVO(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: LocationDetailVO Instance.
*/
	required public init?(dictionary: NSDictionary) {

		siteId = dictionary["siteId"] as? Int
		locationId = dictionary["locationId"] as? Int
		folderId = dictionary["folderId"] as? String
		docId = dictionary["docId"] as? String
		revisionId = dictionary["revisionId"] as? String
		annotationId = dictionary["annotationId"] as? String
		coordinates = dictionary["coordinates"] as? String
		isFileAssociated = dictionary["isFileAssociated"] as? Bool
		hasChildLocation = dictionary["hasChildLocation"] as? Bool
		parentLocationId = dictionary["parentLocationId"] as? Int
		locationPath = dictionary["locationPath"] as? String
		isPFSite = dictionary["isPFSite"] as? Bool
		isCalibrated = dictionary["isCalibrated"] as? Bool
		isLocationActive = dictionary["isLocationActive"] as? Bool
		projectId = dictionary["projectId"] as? String
		generateURI = dictionary["generateURI"] as? Bool
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.siteId, forKey: "siteId")
		dictionary.setValue(self.locationId, forKey: "locationId")
		dictionary.setValue(self.folderId, forKey: "folderId")
		dictionary.setValue(self.docId, forKey: "docId")
		dictionary.setValue(self.revisionId, forKey: "revisionId")
		dictionary.setValue(self.annotationId, forKey: "annotationId")
		dictionary.setValue(self.coordinates, forKey: "coordinates")
		dictionary.setValue(self.isFileAssociated, forKey: "isFileAssociated")
		dictionary.setValue(self.hasChildLocation, forKey: "hasChildLocation")
		dictionary.setValue(self.parentLocationId, forKey: "parentLocationId")
		dictionary.setValue(self.locationPath, forKey: "locationPath")
		dictionary.setValue(self.isPFSite, forKey: "isPFSite")
		dictionary.setValue(self.isCalibrated, forKey: "isCalibrated")
		dictionary.setValue(self.isLocationActive, forKey: "isLocationActive")
		dictionary.setValue(self.projectId, forKey: "projectId")
		dictionary.setValue(self.generateURI, forKey: "generateURI")

		return dictionary
	}

}