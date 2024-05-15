

import Foundation
 

public class ObservationData {
	public var observationId : Int?
	public var locationId : Int?
	public var folderId : String?
	public var msgId : String?
	public var formId : String?
	public var formTypeId : String?
	public var annotationId : String?
	public var revisionId : String?
	public var coordinates : String?
	public var hasAttachment : Bool?
	public var statusVO : StatusVO?
	public var recipientList : Array<RecipientList>?
	public var locationDetailVO : LocationDetailVO?
	public var isActive : Bool?
	public var isSyncIndexUpdate : Bool?
	public var commId : String?
	public var formTitle : String?
	public var formDueDays : Int?
	public var pageNumber : Int?
	public var templateType : Int?
	public var formTypeCode : String?
	public var appBuilderID : String?
	public var creatorUserName : String?
	public var creatorOrgName : String?
	public var formCode : String?
	public var formCreationDate : String?
	public var appType : Int?
	public var projectId : String?
	public var generateURI : Bool?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let ObservationData_list = ObservationData.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of ObservationData Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [ObservationData]
    {
        var models:[ObservationData] = []
        for item in array
        {
            models.append(ObservationData(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let ObservationData = ObservationData(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: ObservationData Instance.
*/
	required public init?(dictionary: NSDictionary) {

		observationId = dictionary["observationId"] as? Int
		locationId = dictionary["locationId"] as? Int
		folderId = dictionary["folderId"] as? String
		msgId = dictionary["msgId"] as? String
		formId = dictionary["formId"] as? String
		formTypeId = dictionary["formTypeId"] as? String
		annotationId = dictionary["annotationId"] as? String
		revisionId = dictionary["revisionId"] as? String
		coordinates = dictionary["coordinates"] as? String
		hasAttachment = dictionary["hasAttachment"] as? Bool
		if (dictionary["statusVO"] != nil) { statusVO = StatusVO(dictionary: dictionary["statusVO"] as! NSDictionary) }
        if (dictionary["recipientList"] != nil) { recipientList = RecipientList.modelsFromDictionaryArray(array: dictionary["recipientList"] as! NSArray) }
		if (dictionary["locationDetailVO"] != nil) { locationDetailVO = LocationDetailVO(dictionary: dictionary["locationDetailVO"] as! NSDictionary) }
		isActive = dictionary["isActive"] as? Bool
		isSyncIndexUpdate = dictionary["isSyncIndexUpdate"] as? Bool
		commId = dictionary["commId"] as? String
		formTitle = dictionary["formTitle"] as? String
		formDueDays = dictionary["formDueDays"] as? Int
		pageNumber = dictionary["pageNumber"] as? Int
		templateType = dictionary["templateType"] as? Int
		formTypeCode = dictionary["formTypeCode"] as? String
		appBuilderID = dictionary["appBuilderID"] as? String
		creatorUserName = dictionary["creatorUserName"] as? String
		creatorOrgName = dictionary["creatorOrgName"] as? String
		formCode = dictionary["formCode"] as? String
		formCreationDate = dictionary["formCreationDate"] as? String
		appType = dictionary["appType"] as? Int
		projectId = dictionary["projectId"] as? String
		generateURI = dictionary["generateURI"] as? Bool
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.observationId, forKey: "observationId")
		dictionary.setValue(self.locationId, forKey: "locationId")
		dictionary.setValue(self.folderId, forKey: "folderId")
		dictionary.setValue(self.msgId, forKey: "msgId")
		dictionary.setValue(self.formId, forKey: "formId")
		dictionary.setValue(self.formTypeId, forKey: "formTypeId")
		dictionary.setValue(self.annotationId, forKey: "annotationId")
		dictionary.setValue(self.revisionId, forKey: "revisionId")
		dictionary.setValue(self.coordinates, forKey: "coordinates")
		dictionary.setValue(self.hasAttachment, forKey: "hasAttachment")
		dictionary.setValue(self.statusVO?.dictionaryRepresentation(), forKey: "statusVO")
		dictionary.setValue(self.locationDetailVO?.dictionaryRepresentation(), forKey: "locationDetailVO")
		dictionary.setValue(self.isActive, forKey: "isActive")
		dictionary.setValue(self.isSyncIndexUpdate, forKey: "isSyncIndexUpdate")
		dictionary.setValue(self.commId, forKey: "commId")
		dictionary.setValue(self.formTitle, forKey: "formTitle")
		dictionary.setValue(self.formDueDays, forKey: "formDueDays")
		dictionary.setValue(self.pageNumber, forKey: "pageNumber")
		dictionary.setValue(self.templateType, forKey: "templateType")
		dictionary.setValue(self.formTypeCode, forKey: "formTypeCode")
		dictionary.setValue(self.appBuilderID, forKey: "appBuilderID")
		dictionary.setValue(self.creatorUserName, forKey: "creatorUserName")
		dictionary.setValue(self.creatorOrgName, forKey: "creatorOrgName")
		dictionary.setValue(self.formCode, forKey: "formCode")
		dictionary.setValue(self.formCreationDate, forKey: "formCreationDate")
		dictionary.setValue(self.appType, forKey: "appType")
		dictionary.setValue(self.projectId, forKey: "projectId")
		dictionary.setValue(self.generateURI, forKey: "generateURI")

		return dictionary
	}

}
