import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:field/offline_injection_container.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter/services.dart';

import '../analytics/event_analytics.dart';
import '../logger/logger.dart';

part '../networking/internet_state.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class InternetCubit extends Cubit<InternetState> implements NetworkInfo {
  late final Connectivity connectivity;
  StreamSubscription? connectivityStreamSubscription;
  late ConnectivityResult _connectionStatus;
  bool isNetworkConnected = true;
  bool isOnline = false;

  InternetCubit() : super(InternetLoading()) {
    connectivity = Connectivity();
    monitorInternetConnection();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<ConnectivityResult> checkConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _connectionStatus = (await connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      Log.i('Couldn\'t check connectivity status error: $e');
      return ConnectivityResult.none;
    }
    return _connectionStatus;
  }

  void monitorInternetConnection() async {
    await checkConnectivity();
    connectivityStreamSubscription = connectivity.onConnectivityChanged.listen((status) async {
      await updateConnectionStatus(result: status);
      switch (status) {
        case ConnectivityResult.mobile:
          emitInternetConnected(ConnectionType.mobile);
          break;
        case ConnectivityResult.wifi:
          emitInternetConnected(ConnectionType.wiFi);
          break;
        case ConnectivityResult.none:
        default:
          emitInternetDisconnected();
          break;
      }
    });
  }

  Future<void> updateConnectionStatus({ConnectivityResult? result}) async {
    bool workOffline = await StorePreference.isWorkOffline();
    if (workOffline) {
      isNetworkConnected = false;
      FireBaseEventAnalytics.setEvent(FireBaseEventType.workOffline, FireBaseFromScreen.headerShortcut,bIncludeProjectName: true);
    } else {
      if (result != null) {
        isNetworkConnected = (result != ConnectivityResult.none);
      } else {
        isNetworkConnected = await getIt<InternetCubit>().isConnected;
        FireBaseEventAnalytics.setEvent(FireBaseEventType.workOnline, FireBaseFromScreen.headerShortcut,bIncludeProjectName: true);
      }
    }

    try {
      if (isNetworkConnected) {
        if (localhostServer.isRunning()) {
          await localhostServer.close();
        }
      } else {
        if (!localhostServer.isRunning()) {
          await localhostServer.start();
        }
      }
    } catch (_) {
      Log.d("Local Host Error");
    }
  }

  void emitInternetConnected(ConnectionType connectionType) {
    if (!isOnline) {
      isOnline = true;
      emit(InternetConnected(connectionType: connectionType));
    }
  }

  void emitInternetDisconnected() {
    Future.delayed(const Duration(seconds: 1), () async {
      if (!(await isConnected)) {
        isOnline = false;
        emit(InternetDisconnected());
      }
    });
  }

  @override
  Future<void> close() async {
    connectivityStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Future<bool> get isConnected async {
    switch (await checkConnectivity()) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        return true;
      default:
        return false;
    }
  }
}

enum ConnectionType { wiFi, mobile }
