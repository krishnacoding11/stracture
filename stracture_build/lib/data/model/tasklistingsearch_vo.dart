import 'dart:convert';
/// criteria : [{"field":"StatusId","operator":1,"values":[0]},{"field":"EntityType","operator":1,"values":[5,2,1]},{"field":"AssigneeId","operator":1,"values":["859155$$OKtKpt"]}]
/// groupField : 1
/// groupRecordLimit : 50
/// recordLimit : 50
/// recordStart : 0

Tasklistingsearchvo tasklistingsearchvoFromJson(String str) => Tasklistingsearchvo.fromJson(json.decode(str));
String tasklistingsearchvoToJson(Tasklistingsearchvo data) => json.encode(data.toJson());
class Tasklistingsearchvo {
  Tasklistingsearchvo({
      List<Criteria>? criteria, 
      int? groupField, 
      int? groupRecordLimit, 
      int? recordLimit, 
      int? recordStart,}){
    _criteria = criteria;
    _groupField = groupField;
    _groupRecordLimit = groupRecordLimit;
    _recordLimit = recordLimit;
    _recordStart = recordStart;
}

  Tasklistingsearchvo.fromJson(dynamic json) {
    if (json['criteria'] != null) {
      _criteria = [];
      json['criteria'].forEach((v) {
        _criteria?.add(Criteria.fromJson(v));
      });
    }
    _groupField = json['groupField'];
    _groupRecordLimit = json['groupRecordLimit'];
    _recordLimit = json['recordLimit'];
    _recordStart = json['recordStart'];
  }
  List<Criteria>? _criteria;
  int? _groupField;
  int? _groupRecordLimit;
  int? _recordLimit;
  int? _recordStart;
Tasklistingsearchvo copyWith({  List<Criteria>? criteria,
  int? groupField,
  int? groupRecordLimit,
  int? recordLimit,
  int? recordStart,
}) => Tasklistingsearchvo(  criteria: criteria ?? _criteria,
  groupField: groupField ?? _groupField,
  groupRecordLimit: groupRecordLimit ?? _groupRecordLimit,
  recordLimit: recordLimit ?? _recordLimit,
  recordStart: recordStart ?? _recordStart,
);
  List<Criteria>? get criteria => _criteria;
  int? get groupField => _groupField;
  int? get groupRecordLimit => _groupRecordLimit;
  int? get recordLimit => _recordLimit;
  int? get recordStart => _recordStart;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_criteria != null) {
      map['criteria'] = _criteria?.map((v) => v.toJson()).toList();
    }
    map['groupField'] = _groupField;
    map['groupRecordLimit'] = _groupRecordLimit;
    map['recordLimit'] = _recordLimit;
    map['recordStart'] = _recordStart;
    return map;
  }

}

/// field : "StatusId"
/// operator : 1
/// values : [0]

Criteria criteriaFromJson(String str) => Criteria.fromJson(json.decode(str));
String criteriaToJson(Criteria data) => json.encode(data.toJson());
class Criteria {
  Criteria({
      String? field, 
      int? operator, 
      List<dynamic>? values,}){
    _field = field;
    _operator = operator;
    _values = values;
}

  Criteria.fromJson(dynamic json) {
    _field = json['field'];
    _operator = json['operator'];
    _values = json['values'] != null ? json['values'].cast<dynamic>() : [];
  }
  String? _field;
  int? _operator;
  List<dynamic>? _values;
Criteria copyWith({  String? field,
  int? operator,
  List<dynamic>? values,
}) => Criteria(  field: field ?? _field,
  operator: operator ?? _operator,
  values: values ?? _values,
);
  String? get field => _field;
  int? get operator => _operator;
  List<dynamic>? get values => _values;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['field'] = _field;
    map['operator'] = _operator;
    map['values'] = _values;
    return map;
  }

}