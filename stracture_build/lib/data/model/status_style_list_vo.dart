class StatusStyleListVo {
  List<StatusStyleVO>? _statusStyleVO;

  StatusStyleListVo({List<StatusStyleVO>? statusStyleVO}) {
    if (statusStyleVO != null) {
      _statusStyleVO = statusStyleVO;
    }
  }

  List<StatusStyleVO>? get statusStyleVO => _statusStyleVO;
  set statusStyleVO(List<StatusStyleVO>? statusStyleVO) =>
      _statusStyleVO = statusStyleVO;

  StatusStyleListVo.fromJson(Map<String, dynamic> json) {
    if (json['statusStyleVO'] != null) {
      _statusStyleVO = <StatusStyleVO>[];
      json['statusStyleVO'].forEach((v) {
        _statusStyleVO!.add(StatusStyleVO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_statusStyleVO != null) {
      data['statusStyleVO'] =
          _statusStyleVO!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatusStyleVO {
  String? _fontEffect;
  bool? _isActive;
  String? _projectId;
  String? _fontColor;
  String? _statusId;
  String? _statusName;
  String? _fontType;
  String? _statusTypeId;
  String? _backgroundColor;

  StatusStyleVO(
      {String? fontEffect,
        bool? isActive,
        String? projectId,
        String? fontColor,
        String? statusId,
        String? statusName,
        String? fontType,
        String? statusTypeId,
        String? backgroundColor}) {
    if (fontEffect != null) {
      _fontEffect = fontEffect;
    }
    if (isActive != null) {
      _isActive = isActive;
    }
    if (projectId != null) {
      _projectId = projectId;
    }
    if (fontColor != null) {
      _fontColor = fontColor;
    }
    if (statusId != null) {
      _statusId = statusId;
    }
    if (statusName != null) {
      _statusName = statusName;
    }
    if (fontType != null) {
      _fontType = fontType;
    }
    if (statusTypeId != null) {
      _statusTypeId = statusTypeId;
    }
    if (backgroundColor != null) {
      _backgroundColor = backgroundColor;
    }
  }

  String? get fontEffect => _fontEffect;
  set setFontEffect(String? fontEffect) => _fontEffect = fontEffect;
  bool? get isActive => _isActive;
  set setIsActive(bool? isActive) => _isActive = isActive;
  String? get projectId => _projectId;
  set setProjectId(String? projectId) => _projectId = projectId;
  String? get fontColor => _fontColor;
  set setFontColor(String? fontColor) => _fontColor = fontColor;
  String? get statusId => _statusId;
  set setStatusId(String? statusId) => _statusId = statusId;
  String? get statusName => _statusName;
  set setStatusName(String? statusName) => _statusName = statusName;
  String? get fontType => _fontType;
  set setFontType(String? fontType) => _fontType = fontType;
  String? get statusTypeId => _statusTypeId;
  set setStatusTypeId(String? statusTypeId) => _statusTypeId = statusTypeId;
  String? get backgroundColor => _backgroundColor;
  set setBackgroundColor(String? backgroundColor) =>
      _backgroundColor = backgroundColor;

  StatusStyleVO.fromJson(Map<String, dynamic> json) {
    _fontEffect = json['FontEffect'];
    _isActive = json['IsActive'];
    _projectId = json['ProjectId'].toString();
    _fontColor = json['FontColor'];
    _statusId = json['StatusId'].toString();
    _statusName = json['StatusName'];
    _fontType = json['FontType'];
    _statusTypeId = json['StatusTypeId'];
    _backgroundColor = json['BackgroundColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FontEffect'] = _fontEffect;
    data['IsActive'] = _isActive;
    data['ProjectId'] = _projectId;
    data['FontColor'] = _fontColor;
    data['StatusId'] = _statusId;
    data['StatusName'] = _statusName;
    data['FontType'] = _fontType;
    data['StatusTypeId'] = _statusTypeId;
    data['BackgroundColor'] = _backgroundColor;
    return data;
  }
}
