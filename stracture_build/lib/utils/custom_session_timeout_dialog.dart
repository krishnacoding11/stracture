import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../bloc/side_tool_bar/side_tool_bar_cubit.dart';
import '../injection_container.dart';
import '../presentation/screen/bottom_navigation/tab_navigator.dart';
import 'navigation_utils.dart';

class CustomSessionTimeOutDialogBox extends StatelessWidget {
  final BuildContext context;
  CustomSessionTimeOutDialogBox({super.key, required this.context});
  final SideToolBarCubit sideToolBarCubit = getIt<SideToolBarCubit>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop();
    NavigationUtils.pushReplaceNamed(
      TabNavigatorRoutes.models,
    );

    return true;
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(7.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.report,
                        color: Colors.red,
                        size: 36,
                      ),
                    ) //
                ),
                const SizedBox(height: 10.0),
                Text(
                  context.toLocale!.something_went_wrong,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontFamily: AFonts.fontFamily,
                      fontWeight: AFontWight.medium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.toLocale!.could_not_load_model,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: AFontWight.bold,),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(color: Colors.black),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  getIt<ModelListCubit>().selectedModelData=null;
                                  Navigator.of(context).pop();
                                  NavigationUtils.pushReplaceNamed(
                                    TabNavigatorRoutes.models,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 5.0, color: Colors.white),
                                ),
                                child: Text(
                                  context.toLocale!.go_to_models_list,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontFamily: AFonts.fontFamily,
                                      fontWeight: AFontWight.bold),
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InsufficientStorageDialogBox extends StatelessWidget {
  final BuildContext context;
  InsufficientStorageDialogBox({super.key, required this.context});
  final SideToolBarCubit sideToolBarCubit = getIt<SideToolBarCubit>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: dialogContent(context),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop();
    NavigationUtils.pushReplaceNamed(
      TabNavigatorRoutes.models,
    );

    return true;
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(7.0),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.report,
                        color: Colors.red,
                        size: 36,
                      ),
                    ) //
                ),
                const SizedBox(height: 10.0),
                Text(
                  context.toLocale!.something_went_wrong,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontFamily: AFonts.fontFamily,
                      fontWeight: AFontWight.medium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.toLocale!.insufficient_storage,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: AFontWight.bold,),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(color: Colors.black),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  getIt<ModelListCubit>().selectedModelData=null;
                                  Navigator.of(context).pop();
                                  NavigationUtils.pushReplaceNamed(
                                    TabNavigatorRoutes.models,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 5.0, color: Colors.white),
                                ),
                                child: Text(
                                  context.toLocale!.go_to_models_list,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontFamily: AFonts.fontFamily,
                                      fontWeight: AFontWight.bold),
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}