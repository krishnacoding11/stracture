
enum QRCodeType { qrLocation, qrFolder, qrFormType, qrUnKnown}

class QRCodeDataVo {
  QRCodeDataVo({
    QRCodeType? qrCodeType,
    String? projectId,
    String? parentLocationId,
    String? locationId,
    String? parentFolderId,
    String? folderId,
    String? revisionId,
    String? instanceGroupId,
    int? dcId,
  }) {
    _qrCodeType = qrCodeType;
    _projectId = projectId;
    _locationId = locationId;
    _folderId = folderId;
    _parentLocationId = parentLocationId;
    _parentFolderId = parentFolderId;
    _revisionId = revisionId;
    _instanceGroupId = instanceGroupId;
    _dcId = dcId;
  }

  QRCodeDataVo.fromMap(Map<String,dynamic> objectMap) {
    _qrCodeType = objectMap['QRCodeType'];
    _projectId = objectMap['projId'];
    switch(_qrCodeType){
      case QRCodeType.qrLocation:{
        _parentLocationId = objectMap['pLocId'];
        _locationId = objectMap['locId'];
        _revisionId = objectMap['revId'];
        _folderId = objectMap['folId'] ?? "";
        _parentFolderId = objectMap['pFolId'] ?? "";
      }
        break;
      case QRCodeType.qrFormType:{
        _instanceGroupId = objectMap['instGrpId'];
      }
        break;
      case QRCodeType.qrFolder:{
        _folderId = objectMap['folId'];
        _parentFolderId = objectMap['pFolId'];
      }
        break;
      default:{}
    }
  }

  QRCodeType? _qrCodeType;
  String? _projectId;
  String? _parentLocationId;
  String? _locationId;
  String? _parentFolderId;
  String? _folderId;
  String? _revisionId;
  String? _instanceGroupId;
  int? _dcId;

  QRCodeDataVo copyWith({
    QRCodeType? qrCodeType,
    String? projectId,
    String? parentLocationId,
    String? locationId,
    String? parentFolderId,
    String? folderId,
    String? revisionId,
    String? instanceGroupId,
    int? dcId,
  }) =>
      QRCodeDataVo(
        qrCodeType: qrCodeType ?? _qrCodeType,
        projectId: projectId ?? _projectId,
        locationId: locationId ?? _locationId,
        folderId: folderId ?? _folderId,
        parentLocationId: parentLocationId ?? _parentLocationId,
        parentFolderId: parentFolderId ?? _parentFolderId,
        revisionId: revisionId ?? _revisionId,
        instanceGroupId: instanceGroupId ?? _instanceGroupId,
        dcId: dcId ?? _dcId,
      );

  QRCodeType? get qrCodeType => _qrCodeType;

  String? get projectId => _projectId;

  String? get locationId => _locationId;

  String? get folderId => _folderId;

  String? get parentLocationId => _parentLocationId;

  String? get parentFolderId => _parentFolderId;

  String? get revisionId => _revisionId;

  String? get instanceGroupId => _instanceGroupId;

  int? get dcId => _dcId;

  set setQrCodeType(QRCodeType name) {
    _qrCodeType = name;
  }

  set setLocationId(String loc) {
    _locationId = loc;
  }

  set setDcId(int dc){
    _dcId = dc;
  }
}