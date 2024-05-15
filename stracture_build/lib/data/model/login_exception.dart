/// AsiteAPIExceptionThrown : {"ERROR_MESSAGE":"Invalid Password given for Authentication","ERROR_DESCRIPTION":"BAD_PASSWORD"}

/// ERROR_CODE : "216"
/// ERROR_MESSAGE : "Invalid Password given for Authentication"
/// ERROR_DESCRIPTION : "BAD_PASSWORD"

class AsiteApiExceptionThrown {
  AsiteApiExceptionThrown({
      String? errorcode,
      String? errormessage,
      String? errordescription,}){
    _errorcode = errorcode;
    _errormessage = errormessage;
    _errordescription = errordescription;
}

  AsiteApiExceptionThrown.fromJson(dynamic json) {
    _errorcode = json['_ERROR_CODE'];
    _errormessage = json['ERROR_MESSAGE'];
    _errordescription = json['ERROR_DESCRIPTION'];
  }
  String? _errorcode;
  String? _errormessage;
  String? _errordescription;
AsiteApiExceptionThrown copyWith({  String? errorcode,String? errormessage,
  String? errordescription,
}) => AsiteApiExceptionThrown(  errorcode: errorcode ?? _errorcode,errormessage: errormessage ?? _errormessage,
  errordescription: errordescription ?? _errordescription,
);
  String? get errorcode => _errorcode;
  String? get errormessage => _errormessage;
  String? get errordescription => _errordescription;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_ERROR_CODE'] = _errorcode;
    map['ERROR_MESSAGE'] = _errormessage;
    map['ERROR_DESCRIPTION'] = _errordescription;
    return map;
  }

}