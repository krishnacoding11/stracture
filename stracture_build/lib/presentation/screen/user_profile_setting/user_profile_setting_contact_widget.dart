import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_label_item.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileSettingContact extends StatefulWidget {
  const UserProfileSettingContact({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingContact> createState() => _UserProfileSettingContact();
}


class _UserProfileSettingContact extends State<UserProfileSettingContact> {
  late UserProfileSettingCubit _userProfileSettingCubit;
  final TextEditingController _contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return createContactWidget(context);
  }

  @override
  void initState() {
    _userProfileSettingCubit = BlocProvider.of<UserProfileSettingCubit>(context);
    super.initState();
    _bindContact();
  }

  _bindContact() {
    _contactController.addListener(() {
      //_userProfileSettingCubit.userProfileSetting.phoneNo = _contactController.text;
      _userProfileSettingCubit.enableContactTick(_contactController.text);
    });
  }

  Widget createContactWidget(BuildContext context){
    return BlocBuilder<UserProfileSettingCubit, FlowState>(
      //buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          return Utility.isTablet? UserProfileSettingLabelItem(
              context: context,
              strLabel: context.toLocale!.lbl_contact,
              strValue: ((_userProfileSettingCubit.userProfileSetting.phoneNo ?? "").isEmpty)?context.toLocale!.lbl_phone_number_placeholder:_userProfileSettingCubit.userProfileSetting.phoneNo!,
              widget: (state is EditUserContact)?getContactTextBox(state, context: context):null,
              onTap: () => isNetWorkConnected()?onContactClick(context):null):
            (state is EditUserContact)?
          getContactTextBox(context: context,state) :
          UserProfileSettingLabelItem(
              context: context,
              strLabel: context.toLocale!.lbl_contact,
              strValue: ((_userProfileSettingCubit.userProfileSetting.phoneNo ?? "").isEmpty)?context.toLocale!.lbl_phone_number_placeholder:_userProfileSettingCubit.userProfileSetting.phoneNo!,
              onTap: () => isNetWorkConnected()?onContactClick(context):null);
        });
  }

  void onContactClick(BuildContext context) async {
    _userProfileSettingCubit.contactlableclick();
    _contactController.text = _userProfileSettingCubit.userProfileSetting.phoneNo ?? "";
  }

  Widget getContactTextBox(FlowState state,{required BuildContext context}) {
    return Container(
      color: AColors.white,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: _contactController,
              style: const TextStyle(fontSize: 16.0, fontFamily: 'Sofia', fontWeight: AFontWight.light),
              textAlignVertical: TextAlignVertical.center,
              maxLength: 15,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: context.toLocale!.lbl_phone_number_placeholder,
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AColors.lightGreyColor)),
                disabledBorder:InputBorder.none,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AColors.lightGreyColor))
              ),
            ),
          ),
          IconButton(
            color: (state as EditUserContact).contactButtonEnabled ? Colors.green:AColors.iconGreyColor,
            onPressed: () => onContactButtonClick(),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }

  onContactButtonClick(){
    if(_contactController.text.isNotEmpty){
      _userProfileSettingCubit.onContactButtonClick(_contactController.text);
    }
    else{
      context.showSnack(context.toLocale!.lbl_error_contact_message);
    }
  }
}