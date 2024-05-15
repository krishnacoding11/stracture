import 'package:field/injection_container.dart';
import 'package:field/networking/internet_cubit.dart';

abstract class NetworkInfo {
  bool get isConnected;
}

isNetWorkConnected() {
  bool isConnected = getIt<InternetCubit>().isNetworkConnected;
  return isConnected;
}
