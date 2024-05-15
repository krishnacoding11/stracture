import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/site/create_form_selection_state.dart';
import '../../../../widgets/normaltext.dart';
import '../../../../widgets/sidebar/sidebar_divider_widget.dart';

class CreateFilterDialog extends StatefulWidget {
  String title;
  List<String> listItems;
  CreateFilterDialog({Key? key, required this.title, required this.listItems}) : super(key: key);

  @override
  State<CreateFilterDialog> createState() => _CreateFilterDialogState();
}

class _CreateFilterDialogState extends State<CreateFilterDialog> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
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
                    textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.18),
                    widget.title,
                    fontSize: 18.0,
                    fontWeight: AFontWight.semiBold,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    getSearchFormView(),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: widget.listItems.isEmpty
                            ? Center(
                                child: Text("No data found"),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Utility.isTablet ? Axis.vertical : Axis.horizontal,
                                padding: const EdgeInsets.only(top: 10, left: 10),
                                itemCount: widget.listItems.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop(widget.listItems[index]);
                                      },
                                      child: ListTile(
                                        title: Text(widget.listItems[index]),
                                      ));
                                })),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget getSearchFormView() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            width: 14,
          ),
          const Icon(Icons.search),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: TextFormField(
              key: Key("key_search_textformfield"),
              controller: searchController,
              onTap: () {},
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: context.toLocale!.text_search_for,
              ),
            ),
          ),
          const SizedBox(
            width: 14,
          ),
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
