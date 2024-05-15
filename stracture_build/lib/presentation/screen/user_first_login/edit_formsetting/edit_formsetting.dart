import 'package:field/bloc/formsetting/form_settings_change_event_cubit.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_state.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/behaviors/switch_with_icon.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../analytics/event_analytics.dart';
import '../../../../widgets/progressbar.dart';

class EditFormSetting extends StatefulWidget {
  const EditFormSetting({Key? key}) : super(key: key);

  @override
  State<EditFormSetting> createState() => _EditFormSettingState();
}

class _EditFormSettingState extends State<EditFormSetting> {
  UserFirstLoginSetupCubit userFirstLoginSetupCubit = getIt<UserFirstLoginSetupCubit>();

  @override
  void initState() {
    userFirstLoginSetupCubit.setupCloseOutFormSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => userFirstLoginSetupCubit,
      child: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
          builder: (context, state) => (state is LoadingState)
              ? const ACircularProgress()
              :Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_form_settings,
                fontSize: 18,
                fontWeight: AFontWight.semiBold,
              ),
              SizedBox(
                height: 20,
              ),
              formSettingListItem(),
            ],
          ),
        ),
      ),
    ));
  }

  Widget formSettingListItem() {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: NormalTextWidget(
              context.toLocale!.lbl_include_closed_out_forms,
              fontWeight: AFontWight.medium,
              fontSize: 18,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex:1,
            child: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
              bloc: userFirstLoginSetupCubit,
              buildWhen: (prev, current) => current is ChangeIncludeCloseOutForm,
              builder: (context, state) {
                return SwitchWithIcon(
                  key: const Key("includeCloseOutForm"),
                  height: 30,
                  width: 50,
                  toggleSize: 22,
                  onToggle: (bool value) async {
                    await userFirstLoginSetupCubit.onChangeIncludeCloseOutForm();
                    getIt<FormSettingsChangeEventCubit>().refreshSiteTasks();
                    FireBaseEventAnalytics.setEvent(
                        FireBaseEventType.includeClosedOutForm,
                        FireBaseFromScreen.settings,
                        bIncludeProjectName: true);
                  },
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  value: userFirstLoginSetupCubit.includeCloseOutFormEnable ?? false,
                  activeIcon: Icon(
                    Icons.done,
                    size: 25,
                    color: AColors.themeBlueColor,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    size: 25,
                    color: AColors.hintColor,
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }
}
