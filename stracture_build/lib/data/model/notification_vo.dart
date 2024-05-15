class NotificationVo {
  NotificationVo({
      String? activityBy,
      String? activityDate,
      String? activityDateTime,
      String? activityFeedId,
      String? activityName,
      String? activityTypeId,
      String? commentMsgId,
      String? dcId,
      String? docId,
      String? docRef,
      String? documentTypeId,
      String? folderId,
      String? folderName,
      String? id,
      String? imgUpdatedDate,
      bool? isDashboardNotificationRead,
      bool? isPasswordProtected,
      String? projectId,
      String? projectName,
      String? recipientId,
      String? resourceTypeId,
      String? revisionId,
      String? uploadFilename,
      String? userId,
      String? viewerId,
      bool? hasOnlineViewerSupport,}){
    _activityBy = activityBy;
    _activityDate = activityDate;
    _activityDateTime = activityDateTime;
    _activityFeedId = activityFeedId;
    _activityName = activityName;
    _activityTypeId = activityTypeId;
    _commentMsgId = commentMsgId;
    _dcId = dcId;
    _docId = docId;
    _docRef = docRef;
    _documentTypeId = documentTypeId;
    _folderId = folderId;
    _folderName = folderName;
    _id = id;
    _imgUpdatedDate = imgUpdatedDate;
    _isDashboardNotificationRead = isDashboardNotificationRead;
    _isPasswordProtected = isPasswordProtected;
    _projectId = projectId;
    _projectName = projectName;
    _recipientId = recipientId;
    _resourceTypeId = resourceTypeId;
    _revisionId = revisionId;
    _uploadFilename = uploadFilename;
    _userId = userId;
    _viewerId = viewerId;
    _hasOnlineViewerSupport = hasOnlineViewerSupport;
}

  NotificationVo.fromJson(dynamic json) {
    _activityBy = json['activityBy'];
    _activityDate = json['activityDate'];
    _activityDateTime = json['activityDateTime'];
    _activityFeedId = json['activityFeedId'];
    _activityName = json['activityName'];
    _activityTypeId = json['activityTypeId'];
    _commentMsgId = json['commentMsgId'];
    _dcId = json['dcId'];
    _docId = json['doc_id'];
    _docRef = json['doc_ref'];
    _documentTypeId = json['document_type_id'];
    _folderId = json['folder_id'];
    _folderName = json['folder_name'];
    _id = json['id'];
    _imgUpdatedDate = json['imgUpdatedDate'];
    _isDashboardNotificationRead = json['isDashboardNotificationRead'];
    _isPasswordProtected = json['isPasswordProtected'];
    _projectId = json['project_id'];
    _projectName = json['project_name'];
    _recipientId = json['recipientId'];
    _resourceTypeId = json['resourceTypeId'];
    _revisionId = json['revision_id'];
    _uploadFilename = json['upload_filename'];
    _userId = json['user_id'];
    _viewerId = json['viewer_id'];
    _hasOnlineViewerSupport = json['hasOnlineViewerSupport'];
  }
  String? _activityBy;
  String? _activityDate;
  String? _activityDateTime;
  String? _activityFeedId;
  String? _activityName;
  String? _activityTypeId;
  String? _commentMsgId;
  String? _dcId;
  String? _docId;
  String? _docRef;
  String? _documentTypeId;
  String? _folderId;
  String? _folderName;
  String? _id;
  String? _imgUpdatedDate;
  bool? _isDashboardNotificationRead;
  bool? _isPasswordProtected;
  String? _projectId;
  String? _projectName;
  String? _recipientId;
  String? _resourceTypeId;
  String? _revisionId;
  String? _uploadFilename;
  String? _userId;
  String? _viewerId;
  bool? _hasOnlineViewerSupport;
 copyWith({  String? activityBy,
  String? activityDate,
  String? activityDateTime,
  String? activityFeedId,
  String? activityName,
  String? activityTypeId,
  String? commentMsgId,
  String? dcId,
  String? docId,
  String? docRef,
  String? documentTypeId,
  String? folderId,
  String? folderName,
  String? id,
  String? imgUpdatedDate,
  bool? isDashboardNotificationRead,
  bool? isPasswordProtected,
  String? projectId,
  String? projectName,
  String? recipientId,
  String? resourceTypeId,
  String? revisionId,
  String? uploadFilename,
  String? userId,
  String? viewerId,
  bool? hasOnlineViewerSupport,
}) => NotificationVo(  activityBy: activityBy ?? _activityBy,
  activityDate: activityDate ?? _activityDate,
  activityDateTime: activityDateTime ?? _activityDateTime,
  activityFeedId: activityFeedId ?? _activityFeedId,
  activityName: activityName ?? _activityName,
  activityTypeId: activityTypeId ?? _activityTypeId,
  commentMsgId: commentMsgId ?? _commentMsgId,
  dcId: dcId ?? _dcId,
  docId: docId ?? _docId,
  docRef: docRef ?? _docRef,
  documentTypeId: documentTypeId ?? _documentTypeId,
  folderId: folderId ?? _folderId,
  folderName: folderName ?? _folderName,
  id: id ?? _id,
  imgUpdatedDate: imgUpdatedDate ?? _imgUpdatedDate,
  isDashboardNotificationRead: isDashboardNotificationRead ?? _isDashboardNotificationRead,
  isPasswordProtected: isPasswordProtected ?? _isPasswordProtected,
  projectId: projectId ?? _projectId,
  projectName: projectName ?? _projectName,
  recipientId: recipientId ?? _recipientId,
  resourceTypeId: resourceTypeId ?? _resourceTypeId,
  revisionId: revisionId ?? _revisionId,
  uploadFilename: uploadFilename ?? _uploadFilename,
  userId: userId ?? _userId,
  viewerId: viewerId ?? _viewerId,
  hasOnlineViewerSupport: hasOnlineViewerSupport ?? _hasOnlineViewerSupport,
);
  String? get activityBy => _activityBy;
  String? get activityDate => _activityDate;
  String? get activityDateTime => _activityDateTime;
  String? get activityFeedId => _activityFeedId;
  String? get activityName => _activityName;
  String? get activityTypeId => _activityTypeId;
  String? get commentMsgId => _commentMsgId;
  String? get dcId => _dcId;
  String? get docId => _docId;
  String? get docRef => _docRef;
  String? get documentTypeId => _documentTypeId;
  String? get folderId => _folderId;
  String? get folderName => _folderName;
  String? get id => _id;
  String? get imgUpdatedDate => _imgUpdatedDate;
  bool? get isDashboardNotificationRead => _isDashboardNotificationRead;
  bool? get isPasswordProtected => _isPasswordProtected;
  String? get projectId => _projectId;
  String? get projectName => _projectName;
  String? get recipientId => _recipientId;
  String? get resourceTypeId => _resourceTypeId;
  String? get revisionId => _revisionId;
  String? get uploadFilename => _uploadFilename;
  String? get userId => _userId;
  String? get viewerId => _viewerId;
  bool? get hasOnlineViewerSupport => _hasOnlineViewerSupport;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['activityBy'] = _activityBy;
    map['activityDate'] = _activityDate;
    map['activityDateTime'] = _activityDateTime;
    map['activityFeedId'] = _activityFeedId;
    map['activityName'] = _activityName;
    map['activityTypeId'] = _activityTypeId;
    map['commentMsgId'] = _commentMsgId;
    map['dcId'] = _dcId;
    map['doc_id'] = _docId;
    map['doc_ref'] = _docRef;
    map['document_type_id'] = _documentTypeId;
    map['folder_id'] = _folderId;
    map['folder_name'] = _folderName;
    map['id'] = _id;
    map['imgUpdatedDate'] = _imgUpdatedDate;
    map['isDashboardNotificationRead'] = _isDashboardNotificationRead;
    map['isPasswordProtected'] = _isPasswordProtected;
    map['project_id'] = _projectId;
    map['project_name'] = _projectName;
    map['recipientId'] = _recipientId;
    map['resourceTypeId'] = _resourceTypeId;
    map['revision_id'] = _revisionId;
    map['upload_filename'] = _uploadFilename;
    map['user_id'] = _userId;
    map['viewer_id'] = _viewerId;
    map['hasOnlineViewerSupport'] = _hasOnlineViewerSupport;
    return map;
  }

}