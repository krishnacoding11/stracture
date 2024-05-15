class OfflineActivityVo {
  String? projectId;
  String? formTypeId;
  String? formId;
  String? msgId;
  String? actionId;
  String? distListId;
  String? offlineRequestData;
  String? createdDateInMs;


  OfflineActivityVo({this.projectId, this.formTypeId, this.formId,this.msgId,this.actionId,this.distListId,this.offlineRequestData,this.createdDateInMs});

  OfflineActivityVo.fromJson(Map<String, dynamic> json) {
    projectId = json['projectId'];
    formTypeId = json['formTypeId'];
    formId = json['formId'];
    msgId = json['msgId'];
    actionId = json['actionId'];
    distListId = json['distListId'];
    offlineRequestData = json['offlineRequestData'];
    createdDateInMs = json['createdDateInMs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projectId'] = projectId;
    data['formTypeId'] = formTypeId;
    data['formId'] = formId;
    data['msgId'] = msgId;
    data['actionId'] = actionId;
    data['distListId'] = distListId;
    data['offlineRequestData'] = offlineRequestData;
    data['createdDateInMs'] = createdDateInMs;
    return data;
  }
}