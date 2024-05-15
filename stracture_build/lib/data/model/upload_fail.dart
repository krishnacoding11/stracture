/// id : 1
/// statusCode : 200
/// fileName : ["§12"]
/// messageString : "Error message"

class UploadFail {
  UploadFail({
      num? id, 
      num? statusCode, 
      List<String>? fileName, 
      String? messageString,}){
    _id = id;
    _statusCode = statusCode;
    _fileName = fileName;
    _messageString = messageString;
}

  UploadFail.fromJson(dynamic json) {
    _id = json['id'];
    _statusCode = json['statusCode'];
    _fileName = json['fileName'] != null ? json['fileName'].cast<String>() : [];
    _messageString = json['messageString'];
  }
  num? _id;
  num? _statusCode;
  List<String>? _fileName;
  String? _messageString;
UploadFail copyWith({  num? id,
  num? statusCode,
  List<String>? fileName,
  String? messageString,
}) => UploadFail(  id: id ?? _id,
  statusCode: statusCode ?? _statusCode,
  fileName: fileName ?? _fileName,
  messageString: messageString ?? _messageString,
);
  num? get id => _id;
  num? get statusCode => _statusCode;
  List<String>? get fileName => _fileName;
  String? get messageString => _messageString;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['statusCode'] = _statusCode;
    map['fileName'] = _fileName;
    map['messageString'] = _messageString;
    return map;
  }


  static List<UploadFail> jsonToList(dynamic response) {
    // var jsonData = json.decode(response);
    return List<UploadFail>.from(response.map((x) => UploadFail.fromJson(x)))
        .toList();
  }
}