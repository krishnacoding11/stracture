import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/injection_container.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

String? documentPath;
List<AppType> appTypeList = [];
InAppLocalhostServer localhostServer = InAppLocalhostServer();
bool? isOnlineButtonSyncClicked = true;
DownloadSizeCubit? downloadSizeCubit = getIt<DownloadSizeCubit>();
bool isLogEnable = false;