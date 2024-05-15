import 'dart:convert';
/// statusId : 5
/// statusDesc : "To Do"
/// statusName : "To Do"

TaskStatusListVo taskStatusListVoFromJson(String str) => TaskStatusListVo.fromJson(json.decode(str));
String taskStatusListVoToJson(TaskStatusListVo data) => json.encode(data.toJson());
class TaskStatusListVo {
  TaskStatusListVo({
      int? statusId, 
      String? statusDesc, 
      String? statusName,}){
    _statusId = statusId;
    _statusDesc = statusDesc;
    _statusName = statusName;
}

  TaskStatusListVo.fromJson(dynamic json) {
    _statusId = json['statusId'];
    _statusDesc = json['statusDesc'];
    _statusName = json['statusName'];
  }
  int? _statusId;
  String? _statusDesc;
  String? _statusName;
TaskStatusListVo copyWith({  int? statusId,
  String? statusDesc,
  String? statusName,
}) => TaskStatusListVo(  statusId: statusId ?? _statusId,
  statusDesc: statusDesc ?? _statusDesc,
  statusName: statusName ?? _statusName,
);
  int? get statusId => _statusId;
  String? get statusDesc => _statusDesc;
  String? get statusName => _statusName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusId'] = _statusId;
    map['statusDesc'] = _statusDesc;
    map['statusName'] = _statusName;
    return map;
  }

}