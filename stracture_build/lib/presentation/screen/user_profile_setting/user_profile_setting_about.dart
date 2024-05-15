import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../../../auth/secrets.dart';
import '../../../widgets/normaltext.dart';

class UserProfileSettingAbout extends StatefulWidget {
  const UserProfileSettingAbout({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingAbout> createState() => _UserProfileSettingAboutState();
}

class _UserProfileSettingAboutState extends State<UserProfileSettingAbout> {
  UserFirstLoginSetupCubit userFirstLoginSetupCubit = di.getIt<UserFirstLoginSetupCubit>();

  @override
  void initState() {
    userFirstLoginSetupCubit.setupNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_about,
                fontSize: 18,
                fontWeight: AFontWight.semiBold,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  //const Icon(Icons.ice_skating),
                  Image.asset('assets/images/app_logo.png'),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(
                        child: NormalTextWidget(
                          context.toLocale!.lbl_field_version(fieldVersionKey),
                          fontSize: 15,
                          fontWeight: AFontWight.medium,
                        ),
                      ),
                      SizedBox(
                        child: NormalTextWidget(
                          context.toLocale!.lbl_released_on(releaseDateKey),
                        color: AColors.grColor,
                        fontSize: 13,
                        fontWeight: AFontWight.medium,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
