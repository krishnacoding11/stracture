import 'dart:convert';

SiteFormAction siteFormActionFromJson(String str) => SiteFormAction.fromJson(json.decode(str));
String siteFormActionToJson(SiteFormAction data) => json.encode(data.toJson());
class SiteFormAction {
  String? _actionId;
  String? _actionName;
  String? _actionStatus;
  String? _actionDate;
  String? _dueDate;
  String? _recipientId;
  String? _remarks;
  String? _actionTime;
  String? _actionCompleteDate;
  bool? _isActive;
  String? _assignedBy;
  String? _recipientName;
  String? _dueDateInMS;
  String? _actionCompleteDateInMS;
  String? _actionDateInMS;
  bool? _actionDelegated;
  bool? _actionCleared;
  bool? _actionCompleted;

  String? _projectId;
  String? _formId;
  String? _msgId;
  String? _actionNotes;
  String? _priorityId;
  String? _distributorUserId;
  String? _distListId;
  String? _transNum;
  String? _entityType;
  String? _modelId;
  String? _recipientOrgId;
  String? _id;
  String? _viewDate;
  String? _resourceId;
  String? _resourceParentId;
  String? _resourceCode;
  String? _commentMsgId;
  String? _actionStatusName;
  String? _actionDueDateMilliSecond;

  SiteFormAction({
    String? actionId,
    String? actionName,
    String? actionStatus,
    String? actionDate,
    String? dueDate,
    String? recipientId,
    String? remarks,
    String? actionTime,
    String? actionCompleteDate,
    bool? isActive,
    String? assignedBy,
    String? recipientName,
    String? dueDateInMS,
    String? actionCompleteDateInMS,
    bool? actionDelegated,
    bool? actionCleared,
    bool? actionCompleted,
  }) {
    _actionId = actionId;
    _actionName = actionName;
    _actionStatus = actionStatus;
    _actionDate = actionDate;
    _dueDate = dueDate;
    _recipientId = recipientId;
    _remarks = remarks;
    _actionTime = actionTime;
    _actionCompleteDate = actionCompleteDate;
    _isActive = isActive;
    _assignedBy = assignedBy;
    _recipientName = recipientName;
    _dueDateInMS = dueDateInMS;
    _actionCompleteDateInMS = actionCompleteDateInMS;
    _actionDelegated = actionDelegated;
    _actionCleared = actionCleared;
    _actionCompleted = actionCompleted;
  }

  SiteFormAction.fromJson(dynamic json) {
    _actionId = json['actionId'].toString();
    _actionName = json['actionName'].toString();
    _actionStatus = json['actionStatus'].toString();
    _actionDate = json['actionDate'].toString();
    _dueDate = json['dueDate'].toString();
    _recipientId = json['recipientId'].toString();
    _remarks = json['remarks'].toString();
    _actionTime = json['actionTime'].toString();
    _actionCompleteDate = json['actionCompleteDate'].toString();
    _isActive = json['isActive'];
    _assignedBy = json['assignedBy'].toString();
    _recipientName = json['recipientName'].toString();
    _dueDateInMS = json['dueDateInMS'].toString();
    _actionCompleteDateInMS = json['actionCompleteDateInMS'].toString();
    _actionDelegated = json['actionDelegated'];
    _actionCleared = json['actionCleared'];
    _actionCompleted = json['actionCompleted'];
  }

  SiteFormAction.fromMessageJson(dynamic json) {
    setActionId = json['actionId']?.toString();
    setActionName = json['actionName'];
    setActionStatus = json['actionStatus']?.toString();
    setActionDate = json['actionDate'];
    setDueDate = json['dueDate'] ?? json['actionDueDate'];
    setRecipientId = json['recipientId']?.toString();
    setRemarks = json['remarks'];
    setActionTime = json['actionTime'];
    setActionCompleteDate = json['actionCompleteDate'];
    setIsActive = json['isActive'];
    setAssignedBy = json['assignedBy'];
    setRecipientName = json['recipientName'];
    setDueDateInMS = json['dueDateInMS']?.toString();
    setActionCleared = json['isActionCleared'];
    setActionCompleted = json['actionComplete'];

    setMsgId = json['msgId'];
    setActionNotes = json['actionNotes'];
    setPriorityId = json['priorityId']?.toString();
    setDistributorUserId = json['distributorUserId']?.toString();
    setDistListId = json['distListId']?.toString();
    setTransNum = json['transNum']?.toString();
    setEntityType = "";
    setModelId = json['modelId'];
    setRecipientOrgId = json['recipientOrgId'];
    setId = json['id'];
    setViewDate = json['viewDate'];
    setResourceId = json['resourceId']?.toString();
    setCommentMsgId = json['commentMsgId']?.toString();
    setResourceParentId = json['resourceParentId']?.toString();
    setResourceCode = json['resourceCode'];
    setActionStatusName = json['actionStatus_name'];
    setActionDueDateMilliSecond = (json['actionDueDateInMiliSecond']??json["dueDateInMS"])?.toString();
    setActionDateInMS = json['actionDateInMS']?.toString();
    setActionCompleteDateInMS = json['actionCompleteDateInMS']?.toString();
  }

  SiteFormAction copyWith({ String? actionId,
    String? actionName,
    String? actionStatus,
    String? actionDate,
    String? dueDate,
    String? recipientId,
    String? remarks,
    String? actionTime,
    String? actionCompleteDate,
    bool? isActive,
    String? assignedBy,
    String? recipientName,
    String? dueDateInMS,
    String? actionCompleteDateInMS,
    bool? actionDelegated,
    bool? actionCleared,
    bool? actionCompleted,
  }) =>
      SiteFormAction(
        actionId: actionId ?? _actionId,
        actionName: actionName ?? _actionName,
        actionStatus: actionStatus ?? _actionStatus,
        actionDate: actionDate ?? _actionDate,
        dueDate: dueDate ?? _dueDate,
        recipientId: recipientId ?? _recipientId,
        remarks: remarks ?? _remarks,
        actionTime: actionTime ?? _actionTime,
        actionCompleteDate: actionCompleteDate ?? _actionCompleteDate,
        isActive: isActive ?? _isActive,
        assignedBy: assignedBy ?? _assignedBy,
        recipientName: recipientName ?? _recipientName,
        dueDateInMS: dueDateInMS ?? _dueDateInMS,
        actionCompleteDateInMS: actionCompleteDateInMS ?? _actionCompleteDateInMS,
        actionDelegated: actionDelegated ?? _actionDelegated,
        actionCleared: actionCleared ?? _actionCleared,
        actionCompleted: actionCompleted ?? _actionCompleted,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['actionId'] = _actionId;
    map['actionName'] = _actionName;
    map['actionStatus'] = _actionStatus;
    map['actionDate'] = _actionDate;
    map['dueDate'] = _dueDate;
    map['recipientId'] = _recipientId;
    map['remarks'] = _remarks;
    map['actionTime'] = _actionTime;
    map['actionCompleteDate'] = _actionCompleteDate;
    map['isActive'] = _isActive;
    map['assignedBy'] = _assignedBy;
    map['recipientName'] = _recipientName;
    map['dueDateInMS'] = _dueDateInMS;
    map['actionCompleteDateInMS'] = _actionCompleteDateInMS;
    map['actionDelegated'] = _actionDelegated;
    map['actionCleared'] = _actionCleared;
    map['actionCompleted'] = _actionCompleted;
    return map;
  }

  String? get actionId => _actionId;

  String? get actionName => _actionName;

  String? get actionStatus => _actionStatus;

  String? get actionDate => _actionDate;

  String? get dueDate => _dueDate;

  String? get recipientId => _recipientId;

  String? get remarks => _remarks;

  String? get actionTime => _actionTime;

  String? get actionCompleteDate => _actionCompleteDate;

  bool? get isActive => _isActive;

  String? get assignedBy => _assignedBy;

  String? get recipientName => _recipientName;

  String? get dueDateInMS => _dueDateInMS;

  String? get actionCompleteDateInMS => _actionCompleteDateInMS;

  bool? get actionDelegated => _actionDelegated;

  bool? get actionCleared => _actionCleared;

  bool? get actionCompleted => _actionCompleted;


  String? get projectId => _projectId;

  String? get formId => _formId;

  String? get msgId => _msgId;

  String? get actionNotes => _actionNotes;

  String? get priorityId => _priorityId;

  String? get distributorUserId => _distributorUserId;

  String? get distListId => _distListId;

  String? get transNum => _transNum;

  String? get entityType => _entityType;

  String? get modelId => _modelId;

  String? get recipientOrgId => _recipientOrgId;

  String? get id => _id;

  String? get viewDate => _viewDate;

  String? get resourceId => _resourceId;

  String? get resourceParentId => _resourceParentId;

  String? get resourceCode => _resourceCode;

  String? get commentMsgId => _commentMsgId;

  String? get actionStatusName => _actionStatusName;

  String? get actionDueDateMilliSecond => _actionDueDateMilliSecond;

  String? get actionDateInMS => _actionDateInMS;

  set setActionId(String? tmpActionId) => _actionId = tmpActionId;

  set setActionName(String? tmpActionName) => _actionName = tmpActionName;

  set setActionStatus(String? tmpActionStatus) => _actionStatus = tmpActionStatus;

  set setActionDate(String? tmpActionDate) => _actionDate = tmpActionDate;

  set setDueDate(String? tmpDueDate) => _dueDate = tmpDueDate;

  set setRecipientId(String? tmpRecipientId) => _recipientId = tmpRecipientId;

  set setRemarks(String? tmpRemarks) => _remarks = tmpRemarks;

  set setActionTime(String? tmpActionTime) => _actionTime = tmpActionTime;

  set setActionCompleteDate(String? tmpActionCompleteDate) => _actionCompleteDate = tmpActionCompleteDate;

  set setIsActive(bool? tmpIsActive) => _isActive = tmpIsActive;

  set setAssignedBy(String? tmpAssignedBy) => _assignedBy = tmpAssignedBy;

  set setRecipientName(String? tmpRecipientName) => _recipientName = tmpRecipientName;

  set setDueDateInMS(String? tmpDueDateInMS) => _dueDateInMS = tmpDueDateInMS;

  set setActionCompleteDateInMS(String? tmpActionCompleteDateInMS) => _actionCompleteDateInMS = tmpActionCompleteDateInMS;

  set setActionDelegated(bool? tmpActionDelegated) => _actionDelegated = tmpActionDelegated;

  set setActionCleared(bool? tmpActionCleared) => _actionCleared = tmpActionCleared;

  set setActionCompleted(bool? tmpActionCompleted) => _actionCompleted = tmpActionCompleted;


  set setProjectId(String? tmpProjectId) => _projectId = tmpProjectId;

  set setFormId(String? tmpFormId) => _formId = tmpFormId;

  set setMsgId(String? tmpMsgId) => _msgId = tmpMsgId;

  set setActionNotes(String? tmpActionNotes) => _actionNotes = tmpActionNotes;

  set setPriorityId(String? tmpPriorityId) => _priorityId = tmpPriorityId;

  set setDistributorUserId(String? tmpDistributorUserId) => _distributorUserId = tmpDistributorUserId;

  set setDistListId(String? tmpDistListId) => _distListId = tmpDistListId;

  set setTransNum(String? tmpTransNum) => _transNum = tmpTransNum;

  set setEntityType(String? tmpEntityType) => _entityType = tmpEntityType;

  set setModelId(String? tmpModelId) => _modelId = tmpModelId;

  set setRecipientOrgId(String? tmpRecipientOrgId) => _recipientOrgId = tmpRecipientOrgId;

  set setId(String? tmpId) => _id = tmpId;

  set setViewDate(String? tmpViewDate) => _viewDate = tmpViewDate;

  set setResourceId(String? tmpResourceId) => _resourceId = tmpResourceId;

  set setResourceParentId(String? tmpResourceParentId) => _resourceParentId = tmpResourceParentId;

  set setResourceCode(String? tmpResourceCode) => _resourceCode = tmpResourceCode;

  set setCommentMsgId(String? tmpCommentMsgId) => _commentMsgId = tmpCommentMsgId;

  set setActionStatusName(String? tmpActionStatusName) => _actionStatusName = tmpActionStatusName;

  set setActionDueDateMilliSecond(String? tmpActionDueDateMilliSecond) => _actionDueDateMilliSecond = tmpActionDueDateMilliSecond;

  set setActionDateInMS(String? tmpActionDateInMS) => _actionDateInMS = tmpActionDateInMS;
}