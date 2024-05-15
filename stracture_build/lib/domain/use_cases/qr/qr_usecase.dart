
import 'package:field/data/local/qr/qr_local_repository_impl.dart';
import 'package:field/data/remote/qr/qr_repository_impl.dart';
import 'package:field/data/repository/qr_repository.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';

import '../../../networking/network_response.dart';

class QrUseCase extends QrRepository<Map,Result> {

  QrRepository? _qrRemoteRepository;

  Future<QrRepository?> getInstance() async {
    //if(_qrRemoteRepository == null) {
    if (isNetWorkConnected()) {
        _qrRemoteRepository = di.getIt<QRRemoteRepository>();
        // _siteRepository = di.getIt<SiteLocalRepository>();
        return _qrRemoteRepository;
      } else {
        _qrRemoteRepository = di.getIt<QRLocalRepository>();
        return _qrRemoteRepository;
      }
    //}
    //return _qrRemoteRepository;
  }

  @override
  Future<Result?> checkQRCodePermission(Map<String, dynamic> request) async{
    await getInstance();
    return await _qrRemoteRepository?.checkQRCodePermission(request);
  }

  @override
  Future<Result?>? getFormPrivilege(Map<String, dynamic> request) async {
    await getInstance();
    return await _qrRemoteRepository?.getFormPrivilege(request);
  }

  @override
  Future<Result?>? getLocationDetails(Map<String, dynamic> request) async {
    await getInstance();
    return await _qrRemoteRepository?.getLocationDetails(request);
  }

  @override
  Future<Result?> getFieldEnableSelectedProjectsAndLocations(Map<String,dynamic> request) async {
    await getInstance();
    return await _qrRemoteRepository?.getFieldEnableSelectedProjectsAndLocations(request);
  }
}