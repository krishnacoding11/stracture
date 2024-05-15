/* 
Copyright (c) 2022 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class RecipientList {
	public var userID : String?
	public var projectId : String?
	public var dueDays : Int?
	public var distListId : Int?
	public var generateURI : Bool?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let recipientList_list = RecipientList.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of RecipientList Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [RecipientList]
    {
        var models:[RecipientList] = []
        for item in array
        {
            models.append(RecipientList(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let recipientList = RecipientList(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: RecipientList Instance.
*/
	required public init?(dictionary: NSDictionary) {

		userID = dictionary["userID"] as? String
		projectId = dictionary["projectId"] as? String
		dueDays = dictionary["dueDays"] as? Int
		distListId = dictionary["distListId"] as? Int
		generateURI = dictionary["generateURI"] as? Bool
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.userID, forKey: "userID")
		dictionary.setValue(self.projectId, forKey: "projectId")
		dictionary.setValue(self.dueDays, forKey: "dueDays")
		dictionary.setValue(self.distListId, forKey: "distListId")
		dictionary.setValue(self.generateURI, forKey: "generateURI")

		return dictionary
	}

}