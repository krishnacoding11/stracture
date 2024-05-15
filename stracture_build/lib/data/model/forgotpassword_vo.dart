/// status : "failed"
/// Message : "Exception Msg"

class ForgotPasswordVo {
  ForgotPasswordVo({
    String? status,
    String? errorMsg,
    String? errorCode,
  }) {
    _status = status;
    _errorMsg = errorMsg;
    _errorCode = errorCode;
  }

  ForgotPasswordVo.fromJson(dynamic json) {
    _status = json['status'];
    _errorMsg = json['errorMsg'];
    _errorCode = json['errorCode'];
  }

  String? _status;
  String? _errorMsg;
  String? _errorCode;

  ForgotPasswordVo copyWith({
    String? status,
    String? errorMsg,
    String? errorCode,
  }) =>
      ForgotPasswordVo(
        status: status ?? _status,
        errorMsg: _errorMsg ?? _errorMsg,
        errorCode: _errorCode ?? _errorCode,
      );

  String? get status => _status;
  String? get errorMsg => _errorMsg;
  String? get errorCode => _errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['Message'] = _errorMsg;
    map['errorCode'] = _errorCode;
    return map;
  }
}
