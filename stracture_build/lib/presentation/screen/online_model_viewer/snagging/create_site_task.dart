import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/site/create_form_selection_state.dart';
import '../../../../../widgets/normaltext.dart';
import '../../../../../widgets/sidebar/sidebar_divider_widget.dart';

class CreateSiteTask extends StatefulWidget {
  const CreateSiteTask({Key? key}) : super(key: key);

  @override
  State<CreateSiteTask> createState() => _CreateSiteTaskState();
}

class _CreateSiteTaskState extends State<CreateSiteTask> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dialogContent(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.87,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AColors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 50),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: NormalTextWidget(
                    context.toLocale!.lbl_create_site_form,
                    fontSize: 18.0,
                    fontWeight: AFontWight.semiBold,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 25),
                          color: Colors.black54,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ADividerWidget(
              thickness: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(flex: Orientation.portrait == orientation ? 12 : 6, child: appTypeListView(context)),
                    Divider(
                      thickness: 3.0,
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                              color: AColors.white,
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: AColors.themeBlueColor, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                            color: AColors.themeBlueColor,
                          ),
                          child: Text(
                            "create",
                            style: TextStyle(color: AColors.white, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget getTextEditorFormView(IconData? iconData, String hintText, bool isDropdown, bool isLeadingIcon) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: isLeadingIcon ? 14 : 0,
          ),
          isLeadingIcon ? Icon(iconData) : Container(),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: TextFormField(
              key: Key("key_recently_added_task_textformfield"),
              onTap: () {},
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                suffixIcon: isDropdown ? Icon(Icons.arrow_drop_down_rounded) : Icon(null),
              ),
              onFieldSubmitted: (String value) async {
                context.closeKeyboard();
              },
              onChanged: (value) {},
            ),
          ),
          const SizedBox(
            width: 14,
          ),
        ],
      ),
    );
  }

  Widget appTypeListView(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                getTextEditorFormView(null, "Recently created task", true, false),
                const SizedBox(
                  height: 20,
                ),
                getTextEditorFormView(null, "Task title*", false, false),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: getTextEditorFormView(null, "Task type", true, false),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: getTextEditorFormView(null, "Workspace", true, false),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                getTextEditorFormView(null, "Locations", true, false),
                const SizedBox(
                  height: 20,
                ),
                getTextEditorFormView(null, "Object group", true, false),
                const SizedBox(
                  height: 20,
                ),
                getTextEditorFormView(null, "Description", false, false),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: getTextEditorFormView(Icons.calendar_month, "Task type", true, true),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: getTextEditorFormView(Icons.calendar_month, "Workspace", true, true),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                getTextEditorFormView(null, "Assign to", true, false),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
              child: Container(
            height: 190,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Attachment",
                style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget appFormListView(List<AppType>? appType) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      key: Key("key_form_list_view"),
      height: getListHeight(appType!.length),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 1, color: AColors.lightGreyColor),
          Expanded(
              child: GridView.builder(
                  key: Key("key_gridview"),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Utility.isTablet ? 6 : 2, childAspectRatio: Utility.isTablet ? (MediaQuery.of(context).size.width / 100) / deviceHeight : getChildAspectRationPhone(deviceHeight)),
                  shrinkWrap: true,
                  itemCount: appType.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int appFormIndex) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, appType[appFormIndex]);
                      },
                      child: Padding(
                        key: Key("key_grid_item"),
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AImageConstants.formType,
                              fit: BoxFit.fitHeight,
                              width: Utility.isTablet ? 65 : 58,
                              height: Utility.isTablet ? 65 : 58,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: NormalTextWidget(appType[appFormIndex].formTypeName!, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium, maxLines: 2, fontSize: (Utility.isTablet ? 18 : 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(16.0),
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget _emptyMsgWidget(String msg) {
    return Center(
      key: Key("key_empty_view_msg"),
      child: NormalTextWidget(msg),
    );
  }

  double getChildAspectRationPhone(deviceHeight) {
    return deviceHeight > 840 ? deviceHeight / (deviceHeight * 0.9) : deviceHeight / (deviceHeight * 1.15);
  }
}

double getListHeight(int length) {
  int deviceType = Utility.isTablet ? 6 : 2; // 2 for phone and
  double a = length / deviceType;
  return ((length % deviceType == 0) ? a.toInt() : (a + 1).toInt()) * 160.0;
}
