import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../analytics/event_analytics.dart';
import '../../../../bloc/user_first_login_setup/user_first_login_setup_state.dart';
import '../../../../widgets/behaviors/switch_with_icon.dart';
import '../../../../widgets/normaltext.dart';
import '../../../../widgets/progressbar.dart';
import '../../../managers/color_manager.dart';

class EditNotificationSetting extends StatefulWidget {
  const EditNotificationSetting({Key? key}) : super(key: key);

  @override
  State<EditNotificationSetting> createState() =>
      _EditNotificationSettingState();
}

class _EditNotificationSettingState extends State<EditNotificationSetting> {
  UserFirstLoginSetupCubit userFirstLoginSetupCubit =
      di.getIt<UserFirstLoginSetupCubit>();

  @override
  void initState() {
    super.initState();
    userFirstLoginSetupCubit.setupNotification();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => userFirstLoginSetupCubit,
        child: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
          builder: (context, state) => (state is LoadingState)
              ? const ACircularProgress()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NormalTextWidget(
                          context.toLocale!.edit_notification,
                          fontSize: 18,
                          fontWeight: AFontWight.semiBold,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        NormalTextWidget(
                          context.toLocale!
                              .select_how_to_recieve_notification_from_asite,
                          fontSize: 17,
                          fontWeight: AFontWight.regular,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        notificationListItem(context)
                      ],
                    ),
                  )),
        ));
  }

  Widget notificationListItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: NormalTextWidget(
              context.toLocale!.push_notification,
              fontWeight: AFontWight.medium,
              fontSize: 18,
            ),
          ),
          BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
              bloc: userFirstLoginSetupCubit,
              buildWhen: (prev, current) => current is EnablePushNotification,
              builder: (context, state) {
                return SwitchWithIcon(
                  key: const Key("ChangeNotification"),
                  height: 30,
                  width: 50,
                  toggleSize: 22,
                  onToggle: (bool value) {
                    userFirstLoginSetupCubit.onChangePushNotificationEnable();
                    FireBaseEventAnalytics.setEvent(
                        FireBaseEventType.notifications,
                        FireBaseFromScreen.settings,
                        bIncludeProjectName: true);
                  },
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  value:
                      userFirstLoginSetupCubit.isPushNotificationEnable ?? true,
                  activeIcon: Icon(
                    Icons.done,
                    size: 26,
                    color: AColors.themeBlueColor,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    size: 26,
                    color: AColors.hintColor,
                  ),
                );
              })
        ],
      ),
    );
  }
}
