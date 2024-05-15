/// sucess_files : ["IMG_0143.jpeg"]
/// failedAttachedFiles : [""]
/// thinUploadDocVOs : [{"kickOffW orkflow":true,"attachmentCounter":0,"fileSysLocation":"//qaukfilepremium.file.core.windows .net/fileshare/files/project_2116416/collabspace/folders/95935508/26680312.jpeg","viewerId ":0,"localRevisionId":0,"proxyUserId":2017529,"fileFormatType":0,"distributionApply":false,"customObjectComponentId":0,"referenceRevisionId":0,"worksetTypeId":0,"fromAdrive":false,"emailType":0,"revCounter":1,"drawing":false,"planId":522,"documentTitle":"IMG_0143","amsS erverId":0,"primaryEmail":false,"new":true,"dateConversionRequired":true,"bimIssueNumber":0,"folderId":95935508,"revision":"-","emailImportance":0,"statusId":998,"fileSize":58676," passwordProtected":false,"folderTypeId":0,"tempId":0,"revisionNotes":"","projectId":2116416,"indexUpdateTimeMillis":0,"worksetId":0,"userTypeId":1,"uploadFilename":"IMG_0143.jpeg","shared":false,"docId":13290837,"documentTypeId":1,"mergeLevel":0,"msgId":0,"scale":"","su bscriptionTypeId":5,"className":"attachment","documentRef":"IMG_0143","attachIssueNumber":0,"recordRetentionPolicyStatus":0,"purposeOfIssueId":0,"zipFileSize":0,"attachPasswordProt ected":false,"hasAttachment":false,"file":false,"customObjectComponentObjectId":0,"bimMode lId":0,"delActivityId":6130370,"docFileName":"26680312.jpeg","revisionDistributionDate":"2 023-05-09 07:34:29.712","drawingSeriesId":0,"privateRevision":false,"solrUpdate":false,"or gContextParamVO":{"billToOrgId":609752,"orgName":"Asite Solutions Ltd","locationIp":"202.1 31.102.147","userName":"Mayur Raval m.","userId":2017529,"projectId":0,"generateURI":true,"orgId":5763307,"email":"m.raval@asite.com"},"bimIssueNumberModel":0,"fromReport":false,"p rojectViewerId":7,"distLaterId":0,"generateURI":true,"paperSize":"0","fromEb":false,"revis ionId":26680312,"zipFileVirusInfected":false,"createdDate":"2023-04-10 13:01:18.0","authou rUserId":2017529,"checkIn":false,"checkOutStatus":false}]
/// remove_files : [""]

class SimpleFileUpload {
  SimpleFileUpload({
      List<String>? sucessFiles, 
      List<String>? failedAttachedFiles, 
      List<ThinUploadDocVOs>? thinUploadDocVOs, 
      List<String>? removeFiles,}){
    _sucessFiles = sucessFiles;
    _failedAttachedFiles = failedAttachedFiles;
    _thinUploadDocVOs = thinUploadDocVOs;
    _removeFiles = removeFiles;
}

  SimpleFileUpload.fromJson(dynamic json) {
    _sucessFiles = json['sucess_files'] != null ? json['sucess_files'].cast<String>() : [];
    _failedAttachedFiles = json['failedAttachedFiles'] != null ? json['failedAttachedFiles'].cast<String>() : [];
    if (json['thinUploadDocVOs'] != null) {
      _thinUploadDocVOs = [];
      json['thinUploadDocVOs'].forEach((v) {
        _thinUploadDocVOs?.add(ThinUploadDocVOs.fromJson(v));
      });
    }
    _removeFiles = json['remove_files'] != null ? json['remove_files'].cast<String>() : [];
  }
  List<String>? _sucessFiles;
  List<String>? _failedAttachedFiles;
  List<ThinUploadDocVOs>? _thinUploadDocVOs;
  List<String>? _removeFiles;
SimpleFileUpload copyWith({  List<String>? sucessFiles,
  List<String>? failedAttachedFiles,
  List<ThinUploadDocVOs>? thinUploadDocVOs,
  List<String>? removeFiles,
}) => SimpleFileUpload(  sucessFiles: sucessFiles ?? _sucessFiles,
  failedAttachedFiles: failedAttachedFiles ?? _failedAttachedFiles,
  thinUploadDocVOs: thinUploadDocVOs ?? _thinUploadDocVOs,
  removeFiles: removeFiles ?? _removeFiles,
);
  List<String>? get sucessFiles => _sucessFiles;
  List<String>? get failedAttachedFiles => _failedAttachedFiles;
  List<ThinUploadDocVOs>? get thinUploadDocVOs => _thinUploadDocVOs;
  List<String>? get removeFiles => _removeFiles;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sucess_files'] = _sucessFiles;
    map['failedAttachedFiles'] = _failedAttachedFiles;
    if (_thinUploadDocVOs != null) {
      map['thinUploadDocVOs'] = _thinUploadDocVOs?.map((v) => v.toJson()).toList();
    }
    map['remove_files'] = _removeFiles;
    return map;
  }

}

/// kickOffW orkflow : true
/// attachmentCounter : 0
/// fileSysLocation : "//qaukfilepremium.file.core.windows .net/fileshare/files/project_2116416/collabspace/folders/95935508/26680312.jpeg"
/// viewerId  : 0
/// localRevisionId : 0
/// proxyUserId : 2017529
/// fileFormatType : 0
/// distributionApply : false
/// customObjectComponentId : 0
/// referenceRevisionId : 0
/// worksetTypeId : 0
/// fromAdrive : false
/// emailType : 0
/// revCounter : 1
/// drawing : false
/// planId : 522
/// documentTitle : "IMG_0143"
/// amsS erverId : 0
/// primaryEmail : false
/// new : true
/// dateConversionRequired : true
/// bimIssueNumber : 0
/// folderId : 95935508
/// revision : "-"
/// emailImportance : 0
/// statusId : 998
/// fileSize : 58676
///  passwordProtected : false
/// folderTypeId : 0
/// tempId : 0
/// revisionNotes : ""
/// projectId : 2116416
/// indexUpdateTimeMillis : 0
/// worksetId : 0
/// userTypeId : 1
/// uploadFilename : "IMG_0143.jpeg"
/// shared : false
/// docId : 13290837
/// documentTypeId : 1
/// mergeLevel : 0
/// msgId : 0
/// scale : ""
/// su bscriptionTypeId : 5
/// className : "attachment"
/// documentRef : "IMG_0143"
/// attachIssueNumber : 0
/// recordRetentionPolicyStatus : 0
/// purposeOfIssueId : 0
/// zipFileSize : 0
/// attachPasswordProt ected : false
/// hasAttachment : false
/// file : false
/// customObjectComponentObjectId : 0
/// bimMode lId : 0
/// delActivityId : 6130370
/// docFileName : "26680312.jpeg"
/// revisionDistributionDate : "2 023-05-09 07:34:29.712"
/// drawingSeriesId : 0
/// privateRevision : false
/// solrUpdate : false
/// or gContextParamVO : {"billToOrgId":609752,"orgName":"Asite Solutions Ltd","locationIp":"202.1 31.102.147","userName":"Mayur Raval m.","userId":2017529,"projectId":0,"generateURI":true,"orgId":5763307,"email":"m.raval@asite.com"}
/// bimIssueNumberModel : 0
/// fromReport : false
/// p rojectViewerId : 7
/// distLaterId : 0
/// generateURI : true
/// paperSize : "0"
/// fromEb : false
/// revis ionId : 26680312
/// zipFileVirusInfected : false
/// createdDate : "2023-04-10 13:01:18.0"
/// authou rUserId : 2017529
/// checkIn : false
/// checkOutStatus : false

class ThinUploadDocVOs {
  ThinUploadDocVOs({
      bool? kickOffWorkflow, 
      num? attachmentCounter, 
      String? fileSysLocation, 
      num? viewerId, 
      num? localRevisionId, 
      num? proxyUserId, 
      num? fileFormatType, 
      bool? distributionApply, 
      num? customObjectComponentId, 
      num? referenceRevisionId, 
      num? worksetTypeId, 
      bool? fromAdrive, 
      num? emailType, 
      num? revCounter, 
      bool? drawing, 
      num? planId, 
      String? documentTitle, 
      num? amsServerId, 
      bool? primaryEmail,
      bool? dateConversionRequired, 
      num? bimIssueNumber, 
      num? folderId, 
      String? revision, 
      num? emailImportance, 
      num? statusId, 
      num? fileSize, 
      bool? passwordProtected, 
      num? folderTypeId, 
      num? tempId, 
      String? revisionNotes, 
      num? projectId, 
      num? indexUpdateTimeMillis, 
      num? worksetId, 
      num? userTypeId, 
      String? uploadFilename, 
      bool? shared, 
      num? docId, 
      num? documentTypeId, 
      num? mergeLevel, 
      num? msgId, 
      String? scale, 
      num? subscriptionTypeId, 
      String? className, 
      String? documentRef, 
      num? attachIssueNumber, 
      num? recordRetentionPolicyStatus, 
      num? purposeOfIssueId, 
      num? zipFileSize, 
      bool? attachPasswordProtected, 
      bool? hasAttachment, 
      bool? file, 
      num? customObjectComponentObjectId, 
      num? bimModelId, 
      num? delActivityId, 
      String? docFileName, 
      String? revisionDistributionDate, 
      num? drawingSeriesId, 
      bool? privateRevision, 
      bool? solrUpdate, 
      OrGContextParamVo? orgContextParamVO, 
      num? bimIssueNumberModel, 
      bool? fromReport, 
      num? projectViewerId, 
      num? distLaterId, 
      bool? generateURI, 
      String? paperSize, 
      bool? fromEb, 
      num? revisionId, 
      bool? zipFileVirusInfected, 
      String? createdDate, 
      num? authourUserId, 
      bool? checkIn, 
      bool? checkOutStatus,}){
    _kickOffWorkflow = kickOffWorkflow;
    _attachmentCounter = attachmentCounter;
    _fileSysLocation = fileSysLocation;
    _viewerId = viewerId;
    _localRevisionId = localRevisionId;
    _proxyUserId = proxyUserId;
    _fileFormatType = fileFormatType;
    _distributionApply = distributionApply;
    _customObjectComponentId = customObjectComponentId;
    _referenceRevisionId = referenceRevisionId;
    _worksetTypeId = worksetTypeId;
    _fromAdrive = fromAdrive;
    _emailType = emailType;
    _revCounter = revCounter;
    _drawing = drawing;
    _planId = planId;
    _documentTitle = documentTitle;
    _amsServerId = amsServerId;
    _primaryEmail = primaryEmail;
    _dateConversionRequired = dateConversionRequired;
    _bimIssueNumber = bimIssueNumber;
    _folderId = folderId;
    _revision = revision;
    _emailImportance = emailImportance;
    _statusId = statusId;
    _fileSize = fileSize;
    _passwordProtected = passwordProtected;
    _folderTypeId = folderTypeId;
    _tempId = tempId;
    _revisionNotes = revisionNotes;
    _projectId = projectId;
    _indexUpdateTimeMillis = indexUpdateTimeMillis;
    _worksetId = worksetId;
    _userTypeId = userTypeId;
    _uploadFilename = uploadFilename;
    _shared = shared;
    _docId = docId;
    _documentTypeId = documentTypeId;
    _mergeLevel = mergeLevel;
    _msgId = msgId;
    _scale = scale;
    _subscriptionTypeId = subscriptionTypeId;
    _className = className;
    _documentRef = documentRef;
    _attachIssueNumber = attachIssueNumber;
    _recordRetentionPolicyStatus = recordRetentionPolicyStatus;
    _purposeOfIssueId = purposeOfIssueId;
    _zipFileSize = zipFileSize;
    _attachPasswordProtected = attachPasswordProtected;
    _hasAttachment = hasAttachment;
    _file = file;
    _customObjectComponentObjectId = customObjectComponentObjectId;
    _bimModelId = bimModelId;
    _delActivityId = delActivityId;
    _docFileName = docFileName;
    _revisionDistributionDate = revisionDistributionDate;
    _drawingSeriesId = drawingSeriesId;
    _privateRevision = privateRevision;
    _solrUpdate = solrUpdate;
    _orgContextParamVO = orgContextParamVO;
    _bimIssueNumberModel = bimIssueNumberModel;
    _fromReport = fromReport;
    _projectViewerId = projectViewerId;
    _distLaterId = distLaterId;
    _generateURI = generateURI;
    _paperSize = paperSize;
    _fromEb = fromEb;
    _revisionId = revisionId;
    _zipFileVirusInfected = zipFileVirusInfected;
    _createdDate = createdDate;
    _authourUserId = authourUserId;
    _checkIn = checkIn;
    _checkOutStatus = checkOutStatus;
}

  ThinUploadDocVOs.fromJson(dynamic json) {
    _kickOffWorkflow = json['kickOffW orkflow'];
    _attachmentCounter = json['attachmentCounter'];
    _fileSysLocation = json['fileSysLocation'];
    _viewerId = json['viewerId '];
    _localRevisionId = json['localRevisionId'];
    _proxyUserId = json['proxyUserId'];
    _fileFormatType = json['fileFormatType'];
    _distributionApply = json['distributionApply'];
    _customObjectComponentId = json['customObjectComponentId'];
    _referenceRevisionId = json['referenceRevisionId'];
    _worksetTypeId = json['worksetTypeId'];
    _fromAdrive = json['fromAdrive'];
    _emailType = json['emailType'];
    _revCounter = json['revCounter'];
    _drawing = json['drawing'];
    _planId = json['planId'];
    _documentTitle = json['documentTitle'];
    _amsServerId = json['amsS erverId'];
    _primaryEmail = json['primaryEmail'];
    _dateConversionRequired = json['dateConversionRequired'];
    _bimIssueNumber = json['bimIssueNumber'];
    _folderId = json['folderId'];
    _revision = json['revision'];
    _emailImportance = json['emailImportance'];
    _statusId = json['statusId'];
    _fileSize = json['fileSize'];
    _passwordProtected = json[' passwordProtected'];
    _folderTypeId = json['folderTypeId'];
    _tempId = json['tempId'];
    _revisionNotes = json['revisionNotes'];
    _projectId = json['projectId'];
    _indexUpdateTimeMillis = json['indexUpdateTimeMillis'];
    _worksetId = json['worksetId'];
    _userTypeId = json['userTypeId'];
    _uploadFilename = json['uploadFilename'];
    _shared = json['shared'];
    _docId = json['docId'];
    _documentTypeId = json['documentTypeId'];
    _mergeLevel = json['mergeLevel'];
    _msgId = json['msgId'];
    _scale = json['scale'];
    _subscriptionTypeId = json['su bscriptionTypeId'];
    _className = json['className'];
    _documentRef = json['documentRef'];
    _attachIssueNumber = json['attachIssueNumber'];
    _recordRetentionPolicyStatus = json['recordRetentionPolicyStatus'];
    _purposeOfIssueId = json['purposeOfIssueId'];
    _zipFileSize = json['zipFileSize'];
    _attachPasswordProtected = json['attachPasswordProt ected'];
    _hasAttachment = json['hasAttachment'];
    _file = json['file'];
    _customObjectComponentObjectId = json['customObjectComponentObjectId'];
    _bimModelId = json['bimMode lId'];
    _delActivityId = json['delActivityId'];
    _docFileName = json['docFileName'];
    _revisionDistributionDate = json['revisionDistributionDate'];
    _drawingSeriesId = json['drawingSeriesId'];
    _privateRevision = json['privateRevision'];
    _solrUpdate = json['solrUpdate'];
    _orgContextParamVO = json['or gContextParamVO'] != null ? OrGContextParamVo.fromJson(json['or gContextParamVO']) : null;
    _bimIssueNumberModel = json['bimIssueNumberModel'];
    _fromReport = json['fromReport'];
    _projectViewerId = json['p rojectViewerId'];
    _distLaterId = json['distLaterId'];
    _generateURI = json['generateURI'];
    _paperSize = json['paperSize'];
    _fromEb = json['fromEb'];
    _revisionId = json['revis ionId'];
    _zipFileVirusInfected = json['zipFileVirusInfected'];
    _createdDate = json['createdDate'];
    _authourUserId = json['authou rUserId'];
    _checkIn = json['checkIn'];
    _checkOutStatus = json['checkOutStatus'];
  }
  bool? _kickOffWorkflow;
  num? _attachmentCounter;
  String? _fileSysLocation;
  num? _viewerId;
  num? _localRevisionId;
  num? _proxyUserId;
  num? _fileFormatType;
  bool? _distributionApply;
  num? _customObjectComponentId;
  num? _referenceRevisionId;
  num? _worksetTypeId;
  bool? _fromAdrive;
  num? _emailType;
  num? _revCounter;
  bool? _drawing;
  num? _planId;
  String? _documentTitle;
  num? _amsServerId;
  bool? _primaryEmail;
  bool? _new;
  bool? _dateConversionRequired;
  num? _bimIssueNumber;
  num? _folderId;
  String? _revision;
  num? _emailImportance;
  num? _statusId;
  num? _fileSize;
  bool? _passwordProtected;
  num? _folderTypeId;
  num? _tempId;
  String? _revisionNotes;
  num? _projectId;
  num? _indexUpdateTimeMillis;
  num? _worksetId;
  num? _userTypeId;
  String? _uploadFilename;
  bool? _shared;
  num? _docId;
  num? _documentTypeId;
  num? _mergeLevel;
  num? _msgId;
  String? _scale;
  num? _subscriptionTypeId;
  String? _className;
  String? _documentRef;
  num? _attachIssueNumber;
  num? _recordRetentionPolicyStatus;
  num? _purposeOfIssueId;
  num? _zipFileSize;
  bool? _attachPasswordProtected;
  bool? _hasAttachment;
  bool? _file;
  num? _customObjectComponentObjectId;
  num? _bimModelId;
  num? _delActivityId;
  String? _docFileName;
  String? _revisionDistributionDate;
  num? _drawingSeriesId;
  bool? _privateRevision;
  bool? _solrUpdate;
  OrGContextParamVo? _orgContextParamVO;
  num? _bimIssueNumberModel;
  bool? _fromReport;
  num? _projectViewerId;
  num? _distLaterId;
  bool? _generateURI;
  String? _paperSize;
  bool? _fromEb;
  num? _revisionId;
  bool? _zipFileVirusInfected;
  String? _createdDate;
  num? _authourUserId;
  bool? _checkIn;
  bool? _checkOutStatus;
ThinUploadDocVOs copyWith({  bool? kickOffWorkflow,
  num? attachmentCounter,
  String? fileSysLocation,
  num? viewerId,
  num? localRevisionId,
  num? proxyUserId,
  num? fileFormatType,
  bool? distributionApply,
  num? customObjectComponentId,
  num? referenceRevisionId,
  num? worksetTypeId,
  bool? fromAdrive,
  num? emailType,
  num? revCounter,
  bool? drawing,
  num? planId,
  String? documentTitle,
  num? amsServerId,
  bool? primaryEmail,
  bool? dateConversionRequired,
  num? bimIssueNumber,
  num? folderId,
  String? revision,
  num? emailImportance,
  num? statusId,
  num? fileSize,
  bool? passwordProtected,
  num? folderTypeId,
  num? tempId,
  String? revisionNotes,
  num? projectId,
  num? indexUpdateTimeMillis,
  num? worksetId,
  num? userTypeId,
  String? uploadFilename,
  bool? shared,
  num? docId,
  num? documentTypeId,
  num? mergeLevel,
  num? msgId,
  String? scale,
  num? subscriptionTypeId,
  String? className,
  String? documentRef,
  num? attachIssueNumber,
  num? recordRetentionPolicyStatus,
  num? purposeOfIssueId,
  num? zipFileSize,
  bool? attachPasswordProtected,
  bool? hasAttachment,
  bool? file,
  num? customObjectComponentObjectId,
  num? bimModelId,
  num? delActivityId,
  String? docFileName,
  String? revisionDistributionDate,
  num? drawingSeriesId,
  bool? privateRevision,
  bool? solrUpdate,
  OrGContextParamVo? orgContextParamVO,
  num? bimIssueNumberModel,
  bool? fromReport,
  num? projectViewerId,
  num? distLaterId,
  bool? generateURI,
  String? paperSize,
  bool? fromEb,
  num? revisionId,
  bool? zipFileVirusInfected,
  String? createdDate,
  num? authourUserId,
  bool? checkIn,
  bool? checkOutStatus,
}) => ThinUploadDocVOs(  kickOffWorkflow: kickOffWorkflow ?? _kickOffWorkflow,
  attachmentCounter: attachmentCounter ?? _attachmentCounter,
  fileSysLocation: fileSysLocation ?? _fileSysLocation,
  viewerId: viewerId ?? _viewerId,
  localRevisionId: localRevisionId ?? _localRevisionId,
  proxyUserId: proxyUserId ?? _proxyUserId,
  fileFormatType: fileFormatType ?? _fileFormatType,
  distributionApply: distributionApply ?? _distributionApply,
  customObjectComponentId: customObjectComponentId ?? _customObjectComponentId,
  referenceRevisionId: referenceRevisionId ?? _referenceRevisionId,
  worksetTypeId: worksetTypeId ?? _worksetTypeId,
  fromAdrive: fromAdrive ?? _fromAdrive,
  emailType: emailType ?? _emailType,
  revCounter: revCounter ?? _revCounter,
  drawing: drawing ?? _drawing,
  planId: planId ?? _planId,
  documentTitle: documentTitle ?? _documentTitle,
  amsServerId: amsServerId ?? _amsServerId,
  primaryEmail: primaryEmail ?? _primaryEmail,
  dateConversionRequired: dateConversionRequired ?? _dateConversionRequired,
  bimIssueNumber: bimIssueNumber ?? _bimIssueNumber,
  folderId: folderId ?? _folderId,
  revision: revision ?? _revision,
  emailImportance: emailImportance ?? _emailImportance,
  statusId: statusId ?? _statusId,
  fileSize: fileSize ?? _fileSize,
  passwordProtected: passwordProtected ?? _passwordProtected,
  folderTypeId: folderTypeId ?? _folderTypeId,
  tempId: tempId ?? _tempId,
  revisionNotes: revisionNotes ?? _revisionNotes,
  projectId: projectId ?? _projectId,
  indexUpdateTimeMillis: indexUpdateTimeMillis ?? _indexUpdateTimeMillis,
  worksetId: worksetId ?? _worksetId,
  userTypeId: userTypeId ?? _userTypeId,
  uploadFilename: uploadFilename ?? _uploadFilename,
  shared: shared ?? _shared,
  docId: docId ?? _docId,
  documentTypeId: documentTypeId ?? _documentTypeId,
  mergeLevel: mergeLevel ?? _mergeLevel,
  msgId: msgId ?? _msgId,
  scale: scale ?? _scale,
  subscriptionTypeId: subscriptionTypeId ?? _subscriptionTypeId,
  className: className ?? _className,
  documentRef: documentRef ?? _documentRef,
  attachIssueNumber: attachIssueNumber ?? _attachIssueNumber,
  recordRetentionPolicyStatus: recordRetentionPolicyStatus ?? _recordRetentionPolicyStatus,
  purposeOfIssueId: purposeOfIssueId ?? _purposeOfIssueId,
  zipFileSize: zipFileSize ?? _zipFileSize,
  attachPasswordProtected: attachPasswordProtected ?? _attachPasswordProtected,
  hasAttachment: hasAttachment ?? _hasAttachment,
  file: file ?? _file,
  customObjectComponentObjectId: customObjectComponentObjectId ?? _customObjectComponentObjectId,
  bimModelId: bimModelId ?? _bimModelId,
  delActivityId: delActivityId ?? _delActivityId,
  docFileName: docFileName ?? _docFileName,
  revisionDistributionDate: revisionDistributionDate ?? _revisionDistributionDate,
  drawingSeriesId: drawingSeriesId ?? _drawingSeriesId,
  privateRevision: privateRevision ?? _privateRevision,
  solrUpdate: solrUpdate ?? _solrUpdate,
  orgContextParamVO: orgContextParamVO ?? _orgContextParamVO,
  bimIssueNumberModel: bimIssueNumberModel ?? _bimIssueNumberModel,
  fromReport: fromReport ?? _fromReport,
  projectViewerId: projectViewerId ?? _projectViewerId,
  distLaterId: distLaterId ?? _distLaterId,
  generateURI: generateURI ?? _generateURI,
  paperSize: paperSize ?? _paperSize,
  fromEb: fromEb ?? _fromEb,
  revisionId: revisionId ?? _revisionId,
  zipFileVirusInfected: zipFileVirusInfected ?? _zipFileVirusInfected,
  createdDate: createdDate ?? _createdDate,
  authourUserId: authourUserId ?? _authourUserId,
  checkIn: checkIn ?? _checkIn,
  checkOutStatus: checkOutStatus ?? _checkOutStatus,
);
  bool? get kickOffWorkflow => _kickOffWorkflow;
  num? get attachmentCounter => _attachmentCounter;
  String? get fileSysLocation => _fileSysLocation;
  num? get viewerId => _viewerId;
  num? get localRevisionId => _localRevisionId;
  num? get proxyUserId => _proxyUserId;
  num? get fileFormatType => _fileFormatType;
  bool? get distributionApply => _distributionApply;
  num? get customObjectComponentId => _customObjectComponentId;
  num? get referenceRevisionId => _referenceRevisionId;
  num? get worksetTypeId => _worksetTypeId;
  bool? get fromAdrive => _fromAdrive;
  num? get emailType => _emailType;
  num? get revCounter => _revCounter;
  bool? get drawing => _drawing;
  num? get planId => _planId;
  String? get documentTitle => _documentTitle;
  num? get amsServerId => _amsServerId;
  bool? get primaryEmail => _primaryEmail;
  bool? get dateConversionRequired => _dateConversionRequired;
  num? get bimIssueNumber => _bimIssueNumber;
  num? get folderId => _folderId;
  String? get revision => _revision;
  num? get emailImportance => _emailImportance;
  num? get statusId => _statusId;
  num? get fileSize => _fileSize;
  bool? get passwordProtected => _passwordProtected;
  num? get folderTypeId => _folderTypeId;
  num? get tempId => _tempId;
  String? get revisionNotes => _revisionNotes;
  num? get projectId => _projectId;
  num? get indexUpdateTimeMillis => _indexUpdateTimeMillis;
  num? get worksetId => _worksetId;
  num? get userTypeId => _userTypeId;
  String? get uploadFilename => _uploadFilename;
  bool? get shared => _shared;
  num? get docId => _docId;
  num? get documentTypeId => _documentTypeId;
  num? get mergeLevel => _mergeLevel;
  num? get msgId => _msgId;
  String? get scale => _scale;
  num? get subscriptionTypeId => _subscriptionTypeId;
  String? get className => _className;
  String? get documentRef => _documentRef;
  num? get attachIssueNumber => _attachIssueNumber;
  num? get recordRetentionPolicyStatus => _recordRetentionPolicyStatus;
  num? get purposeOfIssueId => _purposeOfIssueId;
  num? get zipFileSize => _zipFileSize;
  bool? get attachPasswordProtected => _attachPasswordProtected;
  bool? get hasAttachment => _hasAttachment;
  bool? get file => _file;
  num? get customObjectComponentObjectId => _customObjectComponentObjectId;
  num? get bimModelId => _bimModelId;
  num? get delActivityId => _delActivityId;
  String? get docFileName => _docFileName;
  String? get revisionDistributionDate => _revisionDistributionDate;
  num? get drawingSeriesId => _drawingSeriesId;
  bool? get privateRevision => _privateRevision;
  bool? get solrUpdate => _solrUpdate;
  OrGContextParamVo? get orgContextParamVO => _orgContextParamVO;
  num? get bimIssueNumberModel => _bimIssueNumberModel;
  bool? get fromReport => _fromReport;
  num? get projectViewerId => _projectViewerId;
  num? get distLaterId => _distLaterId;
  bool? get generateURI => _generateURI;
  String? get paperSize => _paperSize;
  bool? get fromEb => _fromEb;
  num? get revisionId => _revisionId;
  bool? get zipFileVirusInfected => _zipFileVirusInfected;
  String? get createdDate => _createdDate;
  num? get authourUserId => _authourUserId;
  bool? get checkIn => _checkIn;
  bool? get checkOutStatus => _checkOutStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['kickOffW orkflow'] = _kickOffWorkflow;
    map['attachmentCounter'] = _attachmentCounter;
    map['fileSysLocation'] = _fileSysLocation;
    map['viewerId '] = _viewerId;
    map['localRevisionId'] = _localRevisionId;
    map['proxyUserId'] = _proxyUserId;
    map['fileFormatType'] = _fileFormatType;
    map['distributionApply'] = _distributionApply;
    map['customObjectComponentId'] = _customObjectComponentId;
    map['referenceRevisionId'] = _referenceRevisionId;
    map['worksetTypeId'] = _worksetTypeId;
    map['fromAdrive'] = _fromAdrive;
    map['emailType'] = _emailType;
    map['revCounter'] = _revCounter;
    map['drawing'] = _drawing;
    map['planId'] = _planId;
    map['documentTitle'] = _documentTitle;
    map['amsS erverId'] = _amsServerId;
    map['primaryEmail'] = _primaryEmail;
    map['dateConversionRequired'] = _dateConversionRequired;
    map['bimIssueNumber'] = _bimIssueNumber;
    map['folderId'] = _folderId;
    map['revision'] = _revision;
    map['emailImportance'] = _emailImportance;
    map['statusId'] = _statusId;
    map['fileSize'] = _fileSize;
    map[' passwordProtected'] = _passwordProtected;
    map['folderTypeId'] = _folderTypeId;
    map['tempId'] = _tempId;
    map['revisionNotes'] = _revisionNotes;
    map['projectId'] = _projectId;
    map['indexUpdateTimeMillis'] = _indexUpdateTimeMillis;
    map['worksetId'] = _worksetId;
    map['userTypeId'] = _userTypeId;
    map['uploadFilename'] = _uploadFilename;
    map['shared'] = _shared;
    map['docId'] = _docId;
    map['documentTypeId'] = _documentTypeId;
    map['mergeLevel'] = _mergeLevel;
    map['msgId'] = _msgId;
    map['scale'] = _scale;
    map['su bscriptionTypeId'] = _subscriptionTypeId;
    map['className'] = _className;
    map['documentRef'] = _documentRef;
    map['attachIssueNumber'] = _attachIssueNumber;
    map['recordRetentionPolicyStatus'] = _recordRetentionPolicyStatus;
    map['purposeOfIssueId'] = _purposeOfIssueId;
    map['zipFileSize'] = _zipFileSize;
    map['attachPasswordProt ected'] = _attachPasswordProtected;
    map['hasAttachment'] = _hasAttachment;
    map['file'] = _file;
    map['customObjectComponentObjectId'] = _customObjectComponentObjectId;
    map['bimMode lId'] = _bimModelId;
    map['delActivityId'] = _delActivityId;
    map['docFileName'] = _docFileName;
    map['revisionDistributionDate'] = _revisionDistributionDate;
    map['drawingSeriesId'] = _drawingSeriesId;
    map['privateRevision'] = _privateRevision;
    map['solrUpdate'] = _solrUpdate;
    if (_orgContextParamVO != null) {
      map['or gContextParamVO'] = _orgContextParamVO?.toJson();
    }
    map['bimIssueNumberModel'] = _bimIssueNumberModel;
    map['fromReport'] = _fromReport;
    map['p rojectViewerId'] = _projectViewerId;
    map['distLaterId'] = _distLaterId;
    map['generateURI'] = _generateURI;
    map['paperSize'] = _paperSize;
    map['fromEb'] = _fromEb;
    map['revis ionId'] = _revisionId;
    map['zipFileVirusInfected'] = _zipFileVirusInfected;
    map['createdDate'] = _createdDate;
    map['authou rUserId'] = _authourUserId;
    map['checkIn'] = _checkIn;
    map['checkOutStatus'] = _checkOutStatus;
    return map;
  }

}

/// billToOrgId : 609752
/// orgName : "Asite Solutions Ltd"
/// locationIp : "202.1 31.102.147"
/// userName : "Mayur Raval m."
/// userId : 2017529
/// projectId : 0
/// generateURI : true
/// orgId : 5763307
/// email : "m.raval@asite.com"

class OrGContextParamVo {
  OrGContextParamVo({
    num? billToOrgId,
    String? orgName,
    String? locationIp,
    String? userName,
    num? userId,
    num? projectId,
    bool? generateURI,
    num? orgId,
    String? email,}) {
    _billToOrgId = billToOrgId;
    _orgName = orgName;
    _locationIp = locationIp;
    _userName = userName;
    _userId = userId;
    _projectId = projectId;
    _generateURI = generateURI;
    _orgId = orgId;
    _email = email;
  }

  OrGContextParamVo.fromJson(dynamic json) {
    _billToOrgId = json['billToOrgId'];
    _orgName = json['orgName'];
    _locationIp = json['locationIp'];
    _userName = json['userName'];
    _userId = json['userId'];
    _projectId = json['projectId'];
    _generateURI = json['generateURI'];
    _orgId = json['orgId'];
    _email = json['email'];
  }

  num? _billToOrgId;
  String? _orgName;
  String? _locationIp;
  String? _userName;
  num? _userId;
  num? _projectId;
  bool? _generateURI;
  num? _orgId;
  String? _email;

  OrGContextParamVo copyWith({ num? billToOrgId,
    String? orgName,
    String? locationIp,
    String? userName,
    num? userId,
    num? projectId,
    bool? generateURI,
    num? orgId,
    String? email,
  }) =>
      OrGContextParamVo(billToOrgId: billToOrgId ?? _billToOrgId,
        orgName: orgName ?? _orgName,
        locationIp: locationIp ?? _locationIp,
        userName: userName ?? _userName,
        userId: userId ?? _userId,
        projectId: projectId ?? _projectId,
        generateURI: generateURI ?? _generateURI,
        orgId: orgId ?? _orgId,
        email: email ?? _email,
      );

  num? get billToOrgId => _billToOrgId;

  String? get orgName => _orgName;

  String? get locationIp => _locationIp;

  String? get userName => _userName;

  num? get userId => _userId;

  num? get projectId => _projectId;

  bool? get generateURI => _generateURI;

  num? get orgId => _orgId;

  String? get email => _email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['billToOrgId'] = _billToOrgId;
    map['orgName'] = _orgName;
    map['locationIp'] = _locationIp;
    map['userName'] = _userName;
    map['userId'] = _userId;
    map['projectId'] = _projectId;
    map['generateURI'] = _generateURI;
    map['orgId'] = _orgId;
    map['email'] = _email;
    return map;
  }
}