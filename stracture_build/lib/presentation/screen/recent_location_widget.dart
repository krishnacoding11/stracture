import 'package:field/data/model/site_location.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../analytics/event_analytics.dart';
import '../../bloc/QR/navigator_cubit.dart';
import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/recent_location/recent_location_cubit.dart';
import '../../data/model/qrcodedata_vo.dart';
import '../../data_source/forms/form_local_data_source.dart';
import '../../networking/network_info.dart';
import '../../utils/qrcode_utils.dart';
import '../../utils/utils.dart';
import '../../widgets/elevatedbutton.dart';
import '../../widgets/normaltext.dart';
import '../managers/image_constant.dart';

class RecentLocationController {
  void Function()? onTapRecentLocation;
}

class RecentLocationWidget extends StatefulWidget {
  final RecentLocationController? recentLocationOnTap;
  final Function? resetAnimation;
  final bool isEditModeEnable;

  const RecentLocationWidget({Key? key, this.resetAnimation, this.isEditModeEnable = false, this.recentLocationOnTap}) : super(key: key);

  @override
  State<RecentLocationWidget> createState() => RecentLocationWidgetState(recentLocationOnTap!);
}

@visibleForTesting
class RecentLocationWidgetState extends State<RecentLocationWidget> {
  RecentLocationCubit recentLocationCubit = getIt<RecentLocationCubit>();
  SiteLocation? lastLocation;
  late bool isOnline;

  //This string not need localization so add here
  final String exploreLocation = 'Explore The Project Site';
  final String goPreviousLocation = 'Go to Previous Location';

  RecentLocationWidgetState(RecentLocationController _controller) {
    _controller.onTapRecentLocation = onRecentLocationClicked;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recentLocationCubit.initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    isOnline = isNetWorkConnected();
    return BlocBuilder<RecentLocationCubit, FlowState>(builder: (_, state) {
      // Widget childBody = Container();
      // lastLocation = null;
      String widgetTitle = exploreLocation;
      if (state is SuccessState) {
        lastLocation = state.response[0] as SiteLocation?;
      }
      if (state is ErrorState || lastLocation != null) {
        widgetTitle = goPreviousLocation;
      }

      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
                    final double defaultSize = Utility.isTablet ? 90 : 45;
                    final double height = constraints.maxHeight * 0.85 < defaultSize ? constraints.maxHeight * 0.85 : defaultSize * 0.85;
                    return Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        AImageConstants.jumpBackIntoSite,
                        fit: BoxFit.contain,
                        height: height,
                      ),
                    );
                  }),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  child: NormalTextWidget(
                    '${widgetTitle.toString().trim()}\n',
                    key: const Key("key_recent_location_widget_title"),
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaleFactor: 1,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: Utility.isTablet ? 18 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  showAlertDialog(BuildContext context, String msg, FlowState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              alignment: Alignment.center,
              child: Image(
                height: 110,
                image: AssetImage(AImageConstants.alertHeader),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_location_unavailable_error,
                  textAlign: TextAlign.center,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: AColors.textColor,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                NormalTextWidget(
                  context.toLocale!.lbl_location_unavailable_error_message,
                  textAlign: TextAlign.center,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: AColors.textColor,
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            AElevatedButtonWidget(
                key: const Key('dialog_close_btn'),
                btnLabel: "Close",
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                btnLabelClr: AColors.white,
                btnBackgroundClr: AColors.userOnlineColor,
                borderRadius: 5.0,
                onPressed: () {
                  Navigator.of(context).pop();
                  recentLocationCubit.emitState(state);
                }),
          ],
        ),
      ),
    );
  }

  void onRecentLocationClicked() async {
    if (!isOnline && lastLocation != null) {
      FormLocalDataSource formLocalDataSource = FormLocalDataSource();
      await formLocalDataSource.init();
      SiteLocation? siteLocation = await formLocalDataSource.getLocationVOFromDB(projectId: lastLocation!.projectId?.plainValue(), locationId: lastLocation!.pfLocationTreeDetail?.locationId.toString() ?? "");
      if (siteLocation == null) {
        if (context.mounted) {
          context.showSnack(context.toLocale!.lbl_location_not_marked_offline);
        }
        return;
      }
    }
    if (isOnline || recentLocationCubit.isProjectSelected) {
      widget.resetAnimation?.call();
      if (recentLocationCubit.state is! InitialState && recentLocationCubit.state is! LoadingState) {
        QRCodeDataVo? qrObj = QrCodeUtility.getQrCodeDataVoFormLocation(lastLocation);
        if (context.mounted) {
          if (qrObj != null) {
            BlocProvider.of<FieldNavigatorCubit>(context).checkQRCodePermission(qrObj);
            FireBaseEventAnalytics.setEvent(FireBaseEventType.jumpToLastLocation, FireBaseFromScreen.homePage, bIncludeProjectName: true);
          } else {
            BlocProvider.of<NavigationCubit>(context).emitLocationTreeState();
          }
        }
      }
    }
  }
}
