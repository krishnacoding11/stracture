import 'dart:convert';

import '../../utils/field_enums.dart';

class FormMessageVO {
  String? _appTypeId;
  String? _projectId;
  String? _formTypeId;
  String? _formId;
  String? _projectName;
  String? _code;
  String? _commId;
  String? _title;
  String? _userId;
  String? _orgId;
  String? _orgName;
  String? _firstName;
  String? _lastName;
  String? _originator;
  String? _msgOriginDisplayUserName;
  String? _noOfActions;
  String? _observationId;
  String? _locationId;
  String? _pfLocFolderId;
  String? _updatedDate;
  String? _duration;
  String? _msgCode;
  String? _docType;
  String? _formTypeName;
  String? _userRefCode;
  String? _formStatus;
  String? _controllerName;
  String? _formCreationDate;
  String? _msgCreatedDate;
  String? _folderId;
  String? _msgId;
  String? _parentMsgId;
  String? _msgTypeId;
  String? _msgStatusId;
  String? _msgStatusName;
  String? _indent;
  String? _formNumber;
  String? _msgOriginatorId;
  String? _hashedMsgOriginatorId;
  String? _printIcon;
  String? _templateType;
  String? _instanceGroupId;
  String? _noOfMessages;
  String? _dcId;
  String? _statusId;
  String? _originUserId;
  String? _projectAPDfolderId;
  String? _msgTypeCode;
  String? _formGroupName;
  String? _id;
  String? _statusText;
  String? _statusChangeUserId;
  String? _originatorEmail;
  String? _invoiceCountAgainstOrder;
  String? _invoiceColourCode;
  String? _controllerUserId;
  String? _offlineFormId;
  String? _updatedDateInMS;
  String? _formCreationDateInMS;
  String? _flagType;
  String? _latestDraftId;
  String? _jsonData;
  String? _responseRequestBy;
  String? _msgCreatedDateInMS;
  String? _sentNames;
  String? _sentActions;
  String? _draftSentActions;
  String? _fixFieldData;
  String? _offlineRequestData;
  String? _formPermissionsMap;
  String? _delFormIds;
  String? _assocRevIds;
  String? _assocFormIds;
  String? _assocCommIds;
  String? _formUserSet;
  String? _msgNum;
  String? _msgContent;
  String? _totalActions;
  String? _attachFiles;
  String? _msgOriginImage;
  String? _msgCreatedDateOffline;
  String? _lastModifiedTime;
  String? _lastModifiedTimeInMS;
  String? _msgOriginDisplayOrgName;
  String? _projectStatusId;
  bool? _canAccessHistory;
  bool? _hasFormAccess;
  bool? _canOrigChangeStatus;
  bool? _canControllerChangeStatus;
  bool? _isStatusChangeRestricted;
  bool? _allowReopenForm;
  bool? _hasOverallStatus;
  bool? _isDraft;
  bool? _isCloseOut;
  bool? _formPrintEnabled;
  bool? _hasDocAssocations;
  bool? _hasBimViewAssociations;
  bool? _hasBimListAssociations;
  bool? _hasFormAssocations;
  bool? _hasCommentAssocations;
  bool? _formHasAssocAttach;
  bool? _msgHasAssocAttach;
  bool? _hasAttach;
  bool? _isOfflineCreated;
  bool? _actionComplete;
  bool? _actionCleared;
  bool? _hasViewAccess;
  bool? _isForInfoIncomplete;
  bool? _canViewDraftMsg;
  bool? _canViewOwnorgPrivateForms;
  bool? _isAutoSavedDraft;

  String? get appTypeId => _appTypeId;

  set setAppTypeId(String? tmpAppTypeId) => _appTypeId = tmpAppTypeId;

  String? get projectId => _projectId;

  set setProjectId(String? tmpProjectId) => _projectId = tmpProjectId;

  String? get formTypeId => _formTypeId;

  set setFormTypeId(String? tmpFormTypeId) => _formTypeId = tmpFormTypeId;

  String? get formId => _formId;

  set setFormId(String? tmpFormId) => _formId = tmpFormId;

  String? get projectName => _projectName;

  set setProjectName(String? tmpProjectName) => _projectName = tmpProjectName;

  String? get code => _code;

  set setCode(String? tmpCode) => _code = tmpCode;

  String? get commId => _commId;

  set setCommId(String? tmpCommId) => _commId = tmpCommId;

  String? get title => _title;

  set setTitle(String? tmpTitle) => _title = tmpTitle;

  String? get userId => _userId;

  set setUserId(String? tmpUserId) => _userId = tmpUserId;

  String? get orgId => _orgId;

  set setOrgId(String? tmpOrgId) => _orgId = tmpOrgId;

  String? get orgName => _orgName;

  set setOrgName(String? tmpOrgName) => _orgName = tmpOrgName;

  String? get firstName => _firstName;

  set setFirstName(String? tmpFirstName) => _firstName = tmpFirstName;

  String? get lastName => _lastName;

  set setLastName(String? tmpLastName) => _lastName = tmpLastName;

  String? get originator => _originator;

  set setOriginator(String? tmpOriginator) => _originator = tmpOriginator;

  String? get msgOriginDisplayUserName => _msgOriginDisplayUserName;

  set setMsgOriginDisplayUserName(String? tmpMsgOriginDisplayUserName) => _msgOriginDisplayUserName = tmpMsgOriginDisplayUserName;

  String? get noOfActions => _noOfActions;

  set setNoOfActions(String? tmpNoOfActions) => _noOfActions = tmpNoOfActions;

  String? get observationId => _observationId;

  set setObservationId(String? tmpObservationId) => _observationId = tmpObservationId;

  String? get locationId => _locationId;

  set setLocationId(String? tmpLocationId) => _locationId = tmpLocationId;

  String? get pfLocFolderId => _pfLocFolderId;

  set setPfLocFolderId(String? tmpPfLocFolderId) => _pfLocFolderId = tmpPfLocFolderId;

  String? get updatedDate => _updatedDate;

  set setUpdatedDate(String? tmpUpdatedDate) => _updatedDate = tmpUpdatedDate;

  String? get duration => _duration;

  set setDuration(String? tmpDuration) => _duration = tmpDuration;

  String? get msgCode => _msgCode;

  set setMsgCode(String? tmpMsgCode) => _msgCode = tmpMsgCode;

  String? get docType => _docType;

  set setDocType(String? tmpDocType) => _docType = tmpDocType;

  String? get formTypeName => _formTypeName;

  set setFormTypeName(String? tmpFormTypeName) => _formTypeName = tmpFormTypeName;

  String? get userRefCode => _userRefCode;

  set setUserRefCode(String? tmpUserRefCode) => _userRefCode = tmpUserRefCode;

  String? get formStatus => _formStatus;

  set setFormStatus(String? tmpFormStatus) => _formStatus = tmpFormStatus;

  String? get controllerName => _controllerName;

  set setControllerName(String? tmpControllerName) => _controllerName = tmpControllerName;

  String? get formCreationDate => _formCreationDate;

  set setFormCreationDate(String? tmpFormCreationDate) => _formCreationDate = tmpFormCreationDate;

  String? get msgCreatedDate => _msgCreatedDate;

  set setMsgCreatedDate(String? tmpMsgCreatedDate) => _msgCreatedDate = tmpMsgCreatedDate;

  String? get folderId => _folderId;

  set setFolderId(String? tmpFolderId) => _folderId = tmpFolderId;

  String? get msgId => _msgId;

  set setMsgId(String? tmpMsgId) => _msgId = tmpMsgId;

  String? get parentMsgId => _parentMsgId;

  set setParentMsgId(String? tmpParentMsgId) => _parentMsgId = tmpParentMsgId;

  String? get msgTypeId => _msgTypeId;

  set setMsgTypeId(String? tmpMsgTypeId) => _msgTypeId = tmpMsgTypeId;

  String? get msgStatusId => _msgStatusId;

  set setMsgStatusId(String? tmpMsgStatusId) => _msgStatusId = tmpMsgStatusId;

  String? get msgStatusName => _msgStatusName;

  set setMsgStatusName(String? tmpMsgStatusName) => _msgStatusName = tmpMsgStatusName;

  String? get indent => _indent;

  set setIndent(String? tmpIndent) => _indent = tmpIndent;

  String? get formNumber => _formNumber;

  set setFormNumber(String? tmpFormNumber) => _formNumber = tmpFormNumber;

  String? get msgOriginatorId => _msgOriginatorId;

  set setMsgOriginatorId(String? tmpMsgOriginatorId) => _msgOriginatorId = tmpMsgOriginatorId;

  String? get hashedMsgOriginatorId => _hashedMsgOriginatorId;

  set setHashedMsgOriginatorId(String? tmpHashedMsgOriginatorId) => _hashedMsgOriginatorId = tmpHashedMsgOriginatorId;

  String? get printIcon => _printIcon;

  set setPrintIcon(String? tmpPrintIcon) => _printIcon = tmpPrintIcon;

  String? get templateType => _templateType;

  set setTemplateType(String? tmpTemplateType) => _templateType = tmpTemplateType;

  String? get instanceGroupId => _instanceGroupId;

  set setInstanceGroupId(String? tmpInstanceGroupId) => _instanceGroupId = tmpInstanceGroupId;

  String? get noOfMessages => _noOfMessages;

  set setNoOfMessages(String? tmpNoOfMessages) => _noOfMessages = tmpNoOfMessages;

  String? get dcId => _dcId;

  set setDcId(String? tmpDcId) => _dcId = tmpDcId;

  String? get statusId => _statusId;

  set setStatusId(String? tmpStatusId) => _statusId = tmpStatusId;

  String? get originUserId => _originUserId;

  set setOriginUserId(String? tmpOriginUserId) => _originUserId = tmpOriginUserId;

  String? get projectAPDfolderId => _projectAPDfolderId;

  set setProjectAPDfolderId(String? tmpProjectAPDfolderId) => _projectAPDfolderId = tmpProjectAPDfolderId;

  String? get msgTypeCode => _msgTypeCode;

  set setMsgTypeCode(String? tmpMsgTypeCode) => _msgTypeCode = tmpMsgTypeCode;

  String? get formGroupName => _formGroupName;

  set setFormGroupName(String? tmpFormGroupName) => _formGroupName = tmpFormGroupName;

  String? get id => _id;

  set setId(String? tmpId) => _id = tmpId;

  String? get statusText => _statusText;

  set setStatusText(String? tmpStatusText) => _statusText = tmpStatusText;

  String? get statusChangeUserId => _statusChangeUserId;

  set setStatusChangeUserId(String? tmpStatusChangeUserId) => _statusChangeUserId = tmpStatusChangeUserId;

  String? get originatorEmail => _originatorEmail;

  set setOriginatorEmail(String? tmpOriginatorEmail) => _originatorEmail = tmpOriginatorEmail;

  String? get invoiceCountAgainstOrder => _invoiceCountAgainstOrder;

  set setInvoiceCountAgainstOrder(String? tmpInvoiceCountAgainstOrder) => _invoiceCountAgainstOrder = tmpInvoiceCountAgainstOrder;

  String? get invoiceColourCode => _invoiceColourCode;

  set setInvoiceColourCode(String? tmpInvoiceColourCode) => _invoiceColourCode = tmpInvoiceColourCode;

  String? get controllerUserId => _controllerUserId;

  set setControllerUserId(String? tmpControllerUserId) => _controllerUserId = tmpControllerUserId;

  String? get offlineFormId => _offlineFormId;

  set setOfflineFormId(String? tmpOfflineFormId) => _offlineFormId = tmpOfflineFormId;

  String? get updatedDateInMS => _updatedDateInMS;

  set setUpdatedDateInMS(String? tmpUpdatedDateInMS) => _updatedDateInMS = tmpUpdatedDateInMS;

  String? get formCreationDateInMS => _formCreationDateInMS;

  set setFormCreationDateInMS(String? tmpFormCreationDateInMS) => _formCreationDateInMS = tmpFormCreationDateInMS;

  String? get flagType => _flagType;

  set setFlagType(String? tmpFlagType) => _flagType = tmpFlagType;

  String? get latestDraftId => _latestDraftId;

  set setLatestDraftId(String? tmpLatestDraftId) => _latestDraftId = tmpLatestDraftId;

  String? get jsonData => _jsonData;

  set setJsonData(String? tmpJsonData) => _jsonData = tmpJsonData;

  String? get responseRequestBy => _responseRequestBy;

  set setResponseRequestBy(String? tmpResponseRequestBy) => _responseRequestBy = tmpResponseRequestBy;

  String? get msgCreatedDateInMS => _msgCreatedDateInMS;

  set setMsgCreatedDateInMS(String? tmpMsgCreatedDateInMS) => _msgCreatedDateInMS = tmpMsgCreatedDateInMS;

  String? get sentNames => _sentNames;

  set setSentNames(String? tmpSentNames) => _sentNames = tmpSentNames;

  String? get sentActions => _sentActions;

  set setSentActions(String? tmpSentActions) => _sentActions = tmpSentActions;

  String? get draftSentActions => _draftSentActions;

  set setDraftSentActions(String? tmpDraftSentActions) => _draftSentActions = tmpDraftSentActions;

  String? get fixFieldData => _fixFieldData;

  set setFixFieldData(String? tmpFixFieldData) => _fixFieldData = tmpFixFieldData;

  String? get offlineRequestData => _offlineRequestData;

  set setOfflineRequestData(String? tmpOfflineRequestData) => _offlineRequestData = tmpOfflineRequestData;

  String? get formPermissionsMap => _formPermissionsMap;

  set setFormPermissionsMap(String? tmpFormPermissionsMap) => _formPermissionsMap = tmpFormPermissionsMap;

  String? get delFormIds => _delFormIds;

  set setDelFormIds(String? tmpDelFormIds) => _delFormIds = tmpDelFormIds;

  String? get assocRevIds => _assocRevIds;

  set setAssocRevIds(String? tmpAssocRevIds) => _assocRevIds = tmpAssocRevIds;

  String? get assocFormIds => _assocFormIds;

  set setAssocFormIds(String? tmpAssocFormIds) => _assocFormIds = tmpAssocFormIds;

  String? get assocCommIds => _assocCommIds;

  set setAssocCommIds(String? tmpAssocCommIds) => _assocCommIds = tmpAssocCommIds;

  String? get formUserSet => _formUserSet;

  set setFormUserSet(String? tmpFormUserSet) => _formUserSet = tmpFormUserSet;

  String? get msgNum => _msgNum;

  set setMsgNum(String? tmpMsgNum) => _msgNum = tmpMsgNum;

  String? get msgContent => _msgContent;

  set setMsgContent(String? tmpMsgContent) => _msgContent = tmpMsgContent;

  String? get totalActions => _totalActions;

  set setTotalActions(String? tmpTotalActions) => _totalActions = tmpTotalActions;

  String? get attachFiles => _attachFiles;

  set setAttachFiles(String? tmpAttachFiles) => _attachFiles = tmpAttachFiles;

  String? get msgOriginImage => _msgOriginImage;

  set setMsgOriginImage(String? tmpMsgOriginImage) => _msgOriginImage = tmpMsgOriginImage;

  String? get msgCreatedDateOffline => _msgCreatedDateOffline;

  set setMsgCreatedDateOffline(String? tmpMsgCreatedDateOffline) => _msgCreatedDateOffline = tmpMsgCreatedDateOffline;

  String? get lastModifiedTime => _lastModifiedTime;

  set setLastModifiedTime(String? tmpLastModifiedTime) => _lastModifiedTime = tmpLastModifiedTime;

  String? get lastModifiedTimeInMS => _lastModifiedTimeInMS;

  set setLastModifiedTimeInMS(String? tmpLastModifiedTimeInMS) => _lastModifiedTimeInMS = tmpLastModifiedTimeInMS;

  String? get msgOriginDisplayOrgName => _msgOriginDisplayOrgName;

  set setMsgOriginDisplayOrgName(String? tmpMsgOriginDisplayOrgName) => _msgOriginDisplayOrgName = tmpMsgOriginDisplayOrgName;

  String? get projectStatusId => _projectStatusId;

  set setProjectStatusId(String? tmpProjectStatusId) => _projectStatusId = tmpProjectStatusId;

  bool? get canAccessHistory => _canAccessHistory;

  set setCanAccessHistory(bool? tmpCanAccessHistory) => _canAccessHistory = tmpCanAccessHistory;

  bool? get hasFormAccess => _hasFormAccess;

  set setHasFormAccess(bool? tmpHasFormAccess) => _hasFormAccess = tmpHasFormAccess;

  bool? get canOrigChangeStatus => _canOrigChangeStatus;

  set setCanOrigChangeStatus(bool? tmpCanOrigChangeStatus) => _canOrigChangeStatus = tmpCanOrigChangeStatus;

  bool? get canControllerChangeStatus => _canControllerChangeStatus;

  set setCanControllerChangeStatus(bool? tmpCanControllerChangeStatus) => _canControllerChangeStatus = tmpCanControllerChangeStatus;

  bool? get isStatusChangeRestricted => _isStatusChangeRestricted;

  set setIsStatusChangeRestricted(bool? tmpIsStatusChangeRestricted) => _isStatusChangeRestricted = tmpIsStatusChangeRestricted;

  bool? get allowReopenForm => _allowReopenForm;

  set setAllowReopenForm(bool? tmpAllowReopenForm) => _allowReopenForm = tmpAllowReopenForm;

  bool? get hasOverallStatus => _hasOverallStatus;

  set setHasOverallStatus(bool? tmpHasOverallStatus) => _hasOverallStatus = tmpHasOverallStatus;

  bool? get isDraft => _isDraft;

  set setIsDraft(bool? tmpIsDraft) => _isDraft = tmpIsDraft;

  bool? get isCloseOut => _isCloseOut;

  set setIsCloseOut(bool? tmpIsCloseOut) => _isCloseOut = tmpIsCloseOut;

  bool? get formPrintEnabled => _formPrintEnabled;

  set setFormPrintEnabled(bool? tmpFormPrintEnabled) => _formPrintEnabled = tmpFormPrintEnabled;

  bool? get hasDocAssocations => _hasDocAssocations;

  set setHasDocAssocations(bool? tmpHasDocAssocations) => _hasDocAssocations = tmpHasDocAssocations;

  bool? get hasBimViewAssociations => _hasBimViewAssociations;

  set setHasBimViewAssociations(bool? tmpHasBimViewAssociations) => _hasBimViewAssociations = tmpHasBimViewAssociations;

  bool? get hasBimListAssociations => _hasBimListAssociations;

  set setHasBimListAssociations(bool? tmpHasBimListAssociations) => _hasBimListAssociations = tmpHasBimListAssociations;

  bool? get hasFormAssocations => _hasFormAssocations;

  set setHasFormAssocations(bool? tmpHasFormAssocations) => _hasFormAssocations = tmpHasFormAssocations;

  bool? get hasCommentAssocations => _hasCommentAssocations;

  set setHasCommentAssocations(bool? tmpHasCommentAssocations) => _hasCommentAssocations = tmpHasCommentAssocations;

  bool? get formHasAssocAttach => _formHasAssocAttach;

  set setFormHasAssocAttach(bool? tmpFormHasAssocAttach) => _formHasAssocAttach = tmpFormHasAssocAttach;

  bool? get msgHasAssocAttach => _msgHasAssocAttach;

  set setMsgHasAssocAttach(bool? tmpMsgHasAssocAttach) => _msgHasAssocAttach = tmpMsgHasAssocAttach;

  bool? get hasAttach => _hasAttach;

  set setHasAttach(bool? tmpHasAttach) => _hasAttach = tmpHasAttach;

  bool? get isOfflineCreated => _isOfflineCreated;

  set setIsOfflineCreated(bool? tmpIsOfflineCreated) => _isOfflineCreated = tmpIsOfflineCreated;

  bool? get actionComplete => _actionComplete;

  set setActionComplete(bool? tmpActionComplete) => _actionComplete = tmpActionComplete;

  bool? get actionCleared => _actionCleared;

  set setActionCleared(bool? tmpActionCleared) => _actionCleared = tmpActionCleared;

  bool? get hasViewAccess => _hasViewAccess;

  set setHasViewAccess(bool? tmpHasViewAccess) => _hasViewAccess = tmpHasViewAccess;

  bool? get isForInfoIncomplete => _isForInfoIncomplete;

  set setIsForInfoIncomplete(bool? tmpIsForInfoIncomplete) => _isForInfoIncomplete = tmpIsForInfoIncomplete;

  bool? get canViewDraftMsg => _canViewDraftMsg;

  set setCanViewDraftMsg(bool? tmpCanViewDraftMsg) => _canViewDraftMsg = tmpCanViewDraftMsg;

  bool? get canViewOwnorgPrivateForms => _canViewOwnorgPrivateForms;

  set setCanViewOwnorgPrivateForms(bool? tmpCanViewOwnorgPrivateForms) => _canViewOwnorgPrivateForms = tmpCanViewOwnorgPrivateForms;

  bool? get isAutoSavedDraft => _isAutoSavedDraft;

  set setIsAutoSavedDraft(bool? tmpIsAutoSavedDraft) => _isAutoSavedDraft = tmpIsAutoSavedDraft;

  FormMessageVO();

  FormMessageVO.fromJson(dynamic json) {
    setProjectId = json['projectId'];
    setProjectName = json['projectName'];
    setCode = json['code'];
    setCommId = json['commId'];
    setFormId = json['formId'];
    setTitle = json['title'];
    setUserId = json['userID'];
    setOrgId = json['orgId'];
    setFirstName = json['firstName'];
    setLastName = json['lastName'];
    setOrgName = json['orgName'];
    setOriginator = json['originator'];
    setMsgOriginDisplayUserName = json['originatorDisplayName'];
    //"actions": [],
    //"allActions": [],
    setNoOfActions = json['noOfActions']?.toString();
    setObservationId = json['observationId']?.toString();
    setLocationId = json['locationId']?.toString();
    setPfLocFolderId = json['pfLocFolderId']?.toString();
    setUpdatedDate = json['updated'];
    setDuration = json['duration'];
    setHasAttach = json['hasAttachments'];
    setMsgCode = json['msgCode'];
    setDocType = json['docType'];
    setFormTypeName = json['formTypeName'];
    setUserRefCode = json['userRefCode'];
    setFormStatus = json['status'];
    setResponseRequestBy = json['responseRequestBy'];
    setControllerName = json['controllerName'];
    setHasDocAssocations = json['hasDocAssocations'];
    setHasBimViewAssociations = json['hasBimViewAssociations'];
    setHasBimListAssociations = json['hasBimListAssociations'];
    setHasFormAssocations = json['hasFormAssocations'];
    setHasCommentAssocations = json['hasCommentAssocations'];
    setFormHasAssocAttach = json['formHasAssocAttach'];
    setMsgHasAssocAttach = json['msgHasAssocAttach'];
    setFormCreationDate = json['formCreationDate'];
    setMsgCreatedDate = json['msgCreatedDate'];
    setFolderId = json['folderId'];
    setMsgId = json['msgId'];
    setParentMsgId = json['parentMsgId']?.toString();
    setMsgTypeId = json['msgTypeId']?.toString();
    setMsgStatusId = json['msgStatusId']?.toString();
    setMsgStatusName = json['msgStatusName'];
    setIndent = json['indent']?.toString();
    setFormTypeId = json['formTypeId'];
    setFormNumber = json['formNum']?.toString();
    setMsgOriginatorId = json['msgOriginatorId']?.toString();
    setHashedMsgOriginatorId = json['hashedMsgOriginatorId'];
    setFormPrintEnabled = json['formPrintEnabled'];
    setPrintIcon = json['showPrintIcon']?.toString();
    setSentNames = json['sentNames'] != null ? jsonEncode(json['sentNames']) : "";
    setTemplateType = json['templateType']?.toString();
    setInstanceGroupId = json['instanceGroupId'];
    setNoOfMessages = json['noOfMessages']?.toString();
    setIsDraft = json['isDraft'];
    setDcId = json['dcId']?.toString();
    setStatusId = json['statusid']?.toString();
    setOriginUserId = json['originatorId']?.toString();
    setIsCloseOut = json['isCloseOut'];
    setIsStatusChangeRestricted = json['isStatusChangeRestricted'];
    setProjectAPDfolderId = json['project_APD_folder_id'];
    setAssocRevIds = json['assocRevIds'] != null ? jsonEncode(json['assocRevIds']) : "";
    setAssocFormIds = json['assocFormIds'] != null ? jsonEncode(json['assocFormIds']) : "";
    setAssocCommIds = json['assocCommIds'] != null ? jsonEncode(json['assocCommIds']) : "";
    setAllowReopenForm = json['allowReopenForm'];
    setHasOverallStatus = json['hasOverallStatus'];
    setFormUserSet = json['formUserSet'] != null ? jsonEncode(json['formUserSet']) : "";
    setCanOrigChangeStatus = json['canOrigChangeStatus'];
    setCanControllerChangeStatus = json['canControllerChangeStatus'];
    setAppTypeId = json['appType'];
    setMsgTypeCode = json['msgTypeCode'];
    setFormGroupName = json['formGroupName'];
    setId = json['id'];
    setStatusText = json['statusText'];
    setStatusChangeUserId = json['statusChangeUserId']?.toString();
    setOriginatorEmail = json['originatorEmail'];
    //statusRecordStyle
    setInvoiceCountAgainstOrder = json['invoiceCountAgainstOrder'];
    setInvoiceColourCode = json['invoiceColourCode'];
    setControllerUserId = json['controllerUserId']?.toString();
    setOfflineFormId = json['offlineFormId'];
    //customFieldsValueVOs
    setUpdatedDateInMS = json['updatedDateInMS']?.toString();
    setFormCreationDateInMS = json['formCreationDateInMS']?.toString();
    setMsgCreatedDateInMS = json['msgCreatedDateInMS']?.toString();
    setFlagType = json['flagType']?.toString();
    setLatestDraftId = json['latestDraftId'];
    setHasFormAccess = json['hasFormAccess'];
    setJsonData = json['jsonData'];
    setFormPermissionsMap = json['formPermissions'] != null ? jsonEncode(json['formPermissions']) : "";
    setSentActions = json['sentActions'] != null ? jsonEncode(json['sentActions']) : "";
    setFixFieldData = json['fixedFormData'] != null ? jsonEncode(json['fixedFormData']) : "";
    //"ownerOrgName": "Asite 207 com",
    //"ownerOrgId": 5151785,
    //"isPublic": false,
    //"isThumbnailSupports": false,
    setCanAccessHistory = json['canAccessHistory'];
    setProjectStatusId = json['projectStatusId']?.toString();
    setDraftSentActions = json['draftMsgDistributionList'] != null ? jsonEncode(json['draftMsgDistributionList']) : "";
    setLastModifiedTime = json['strLastModifiedTime'];
    setLastModifiedTimeInMS = json['lastModifiedTimeInMS'];
    setMsgNum = json['msgNum'];
    setTotalActions = json['totalActions'];
    setAttachFiles = json['attach_files'];
    setMsgOriginImage = json['msgOriginatorImage'];
    setActionComplete = json['actionComplete'];
    setActionCleared = json['actionCleared'];
    setHasViewAccess = json['hasViewAccess'];
    setIsForInfoIncomplete = json['isForInfoIncomplete'];
    setCanViewDraftMsg = json['canViewDraftMsg'];
    setCanViewOwnorgPrivateForms = json['canViewOwnorgPrivateForms'];
    setIsAutoSavedDraft = json['isAutoSavedDraft'];
    final msgJson = json['JsonData'] != null ? jsonDecode(json['JsonData']) : null;
    if (msgJson != null && msgJson['myFields']['FORM_CUSTOM_FIELDS'] != null) {
      final msgJson = jsonDecode(json['JsonData'] ?? "{}");
      if (msgJson['myFields'] != null && msgJson['myFields']['FORM_CUSTOM_FIELDS'] != null) {
        EFormMessageType eMsgType = EFormMessageType.fromNumber(int.parse(json['msgTypeId']?.toString() ?? "1"));
        switch (eMsgType) {
          case EFormMessageType.ori:
          case EFormMessageType.fwd:
            setMsgContent = msgJson['myFields']['FORM_CUSTOM_FIELDS']['ORI_MSG_Custom_Fields']['Defect_Description']?.toString() ?? "";
            break;
          default:
            setMsgContent = msgJson['myFields']['FORM_CUSTOM_FIELDS']['RES_MSG_Custom_Fields']['Comments']?.toString() ?? "";
            break;
        }
      } else if (json['msg_content1'] != null) {
        setMsgContent = json['msg_content1'];
      } else if (json['msgcontent1'] != null) {
        setMsgContent = json['msgcontent1'];
      }
    }
  }
  FormMessageVO.offlineFromJson(dynamic json) {
    setProjectId = json['ProjectId'];
    setProjectName = json['projectName'];
    setCode = json['code'];
    setCommId = json['commId'];
    setFormId = json['formId'];
    setTitle = json['title'];
    setUserId = json['userID'];
    setOrgId = json['orgId'];
    setFirstName = json['firstName'];
    setLastName = json['lastName'];
    setOrgName = json['orgName'];
    setOriginator = json['originator'];
    setMsgOriginDisplayUserName = json['originatorDisplayName'];
    //"actions": [],
    //"allActions": [],
    setNoOfActions = json['noOfActions']?.toString();
    setObservationId = json['observationId']?.toString();
    setLocationId = json['locationId']?.toString();
    setPfLocFolderId = json['pfLocFolderId']?.toString();
    setUpdatedDate = json['updated'];
    setDuration = json['duration'];
    setHasAttach = json['hasAttachments'];
    setMsgCode = json['msgCode'];
    setDocType = json['docType'];
    setFormTypeName = json['formTypeName'];
    setUserRefCode = json['userRefCode'];
    setFormStatus = json['status'];
    setResponseRequestBy = json['responseRequestBy'];
    setControllerName = json['controllerName'];
    setHasDocAssocations = json['hasDocAssocations'];
    setHasBimViewAssociations = json['hasBimViewAssociations'];
    setHasBimListAssociations = json['hasBimListAssociations'];
    setHasFormAssocations = json['hasFormAssocations'];
    setHasCommentAssocations = json['hasCommentAssocations'];
    setFormHasAssocAttach = json['formHasAssocAttach'];
    setMsgHasAssocAttach = json['msgHasAssocAttach'];
    setFormCreationDate = json['formCreationDate'];
    setMsgCreatedDate = json['msgCreatedDate'];
    setFolderId = json['folderId'];
    setMsgId = json['msgId'];
    setParentMsgId = json['parentMsgId']?.toString();
    setMsgTypeId = json['msgTypeId']?.toString();
    setMsgStatusId = json['msgStatusId']?.toString();
    setMsgStatusName = json['msgStatusName'];
    setIndent = json['indent']?.toString();
    setFormTypeId = json['formTypeId'];
    setFormNumber = json['formNum']?.toString();
    setMsgOriginatorId = json['msgOriginatorId']?.toString();
    setHashedMsgOriginatorId = json['hashedMsgOriginatorId'];
    setFormPrintEnabled = json['formPrintEnabled'];
    setPrintIcon = json['showPrintIcon']?.toString();
    setSentNames = json['sentNames'] != null ? jsonEncode(json['sentNames']) : "";
    setTemplateType = json['templateType']?.toString();
    setInstanceGroupId = json['instanceGroupId'];
    setNoOfMessages = json['noOfMessages']?.toString();
    setIsDraft = json['isDraft'];
    setDcId = json['dcId']?.toString();
    setStatusId = json['statusid']?.toString();
    setOriginUserId = json['originatorId']?.toString();
    setIsCloseOut = json['isCloseOut'];
    setIsStatusChangeRestricted = json['isStatusChangeRestricted'];
    setProjectAPDfolderId = json['project_APD_folder_id'];
    setAssocRevIds = json['assocRevIds'] != null ? jsonEncode(json['assocRevIds']) : "";
    setAssocFormIds = json['assocFormIds'] != null ? jsonEncode(json['assocFormIds']) : "";
    setAssocCommIds = json['assocCommIds'] != null ? jsonEncode(json['assocCommIds']) : "";
    setAllowReopenForm = json['allowReopenForm'];
    setHasOverallStatus = json['hasOverallStatus'];
    setFormUserSet = json['formUserSet'] != null ? jsonEncode(json['formUserSet']) : "";
    setCanOrigChangeStatus = json['canOrigChangeStatus'];
    setCanControllerChangeStatus = json['canControllerChangeStatus'];
    setAppTypeId = json['appType'];
    setMsgTypeCode = json['msgTypeCode'];
    setFormGroupName = json['formGroupName'];
    setId = json['id'];
    setStatusText = json['statusText'];
    setStatusChangeUserId = json['statusChangeUserId']?.toString();
    setOriginatorEmail = json['originatorEmail'];
    //statusRecordStyle
    setInvoiceCountAgainstOrder = json['invoiceCountAgainstOrder'];
    setInvoiceColourCode = json['invoiceColourCode'];
    setControllerUserId = json['controllerUserId']?.toString();
    setOfflineFormId = json['offlineFormId'];
    //customFieldsValueVOs
    setUpdatedDateInMS = json['updatedDateInMS']?.toString();
    setFormCreationDateInMS = json['formCreationDateInMS']?.toString();
    setMsgCreatedDateInMS = json['msgCreatedDateInMS']?.toString();
    setFlagType = json['flagType']?.toString();
    setLatestDraftId = json['latestDraftId'];
    setHasFormAccess = json['hasFormAccess'];
    setJsonData = json['jsonData'];
    setFormPermissionsMap = json['formPermissions'] != null ? jsonEncode(json['formPermissions']) : "";
    setSentActions = json['sentActions'] != null ? jsonEncode(json['sentActions']) : "";
    setFixFieldData = json['fixedFormData'] != null ? jsonEncode(json['fixedFormData']) : "";
    //"ownerOrgName": "Asite 207 com",
    //"ownerOrgId": 5151785,
    //"isPublic": false,
    //"isThumbnailSupports": false,
    setCanAccessHistory = json['canAccessHistory'];
    setProjectStatusId = json['projectStatusId']?.toString();
    setDraftSentActions = json['draftMsgDistributionList'] != null ? jsonEncode(json['draftMsgDistributionList']) : "";
    setLastModifiedTime = json['strLastModifiedTime'];
    setLastModifiedTimeInMS = json['lastModifiedTimeInMS'];
    setMsgNum = json['msgNum'];
    setTotalActions = json['totalActions'];
    setAttachFiles = json['attach_files'];
    setMsgOriginImage = json['msgOriginatorImage'];
    setActionComplete = json['actionComplete'];
    setActionCleared = json['actionCleared'];
    setHasViewAccess = json['hasViewAccess'];
    setIsForInfoIncomplete = json['isForInfoIncomplete'];
    setCanViewDraftMsg = json['canViewDraftMsg'];
    setCanViewOwnorgPrivateForms = json['canViewOwnorgPrivateForms'];
    setIsAutoSavedDraft = json['isAutoSavedDraft'];
    final msgJson = jsonDecode(json['JsonData'] ?? "{}");
    if (msgJson['myFields'] != null && msgJson['myFields']['FORM_CUSTOM_FIELDS'] != null) {
      EFormMessageType eMsgType = EFormMessageType.fromNumber(int.parse(json['msgTypeId']?.toString() ?? "1"));
      switch (eMsgType) {
        case EFormMessageType.ori:
        case EFormMessageType.fwd:
          setMsgContent = msgJson['myFields']['FORM_CUSTOM_FIELDS']['ORI_MSG_Custom_Fields']['Defect_Description']?.toString() ?? "";
          break;
        default:
          setMsgContent = msgJson['myFields']['FORM_CUSTOM_FIELDS']['RES_MSG_Custom_Fields']['Comments']?.toString() ?? "";
          break;
      }
    } else if (json['msg_content1'] != null) {
      setMsgContent = json['msg_content1'];
    } else if (json['msgcontent1'] != null) {
      setMsgContent = json['msgcontent1'];
    }
  }
}
