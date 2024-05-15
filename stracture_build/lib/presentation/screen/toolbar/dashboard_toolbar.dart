import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/online_model_viewer/online_model_viewer_cubit.dart';
import '../../../bloc/toolbar/model_tree_title_click_event_cubit.dart';
import '../../managers/font_manager.dart';

class DashboardToolbar extends StatelessWidget {
  final _navigationCubit = getIt<NavigationCubit>();

  DashboardToolbar({super.key});

  final bool isTablet = Utility.isTablet;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolbarCubit, FlowState>(
      builder: (context, state) {
        return buildTitle(navigationItems[_navigationCubit.currSelectedItem]!.title,context);
      },
    );
  }

  Widget buildTitle(String title,BuildContext context) {
    switch (_navigationCubit.currSelectedItem) {
      case NavigationMenuItemType.sites:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: () => getIt<ToolbarTitleClickEventCubit>().openLocationTreeDialog(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: NormalTextWidget(title, key: const Key("AppbarTitle"), maxLines: 1, fontSize: 15.0, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AColors.textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: Icon(
                  Icons.bookmark,
                  size: 15.0,
                  color: AColors.textColor,
                ),
              ),
            ),
          ],
        );
      case NavigationMenuItemType.models:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Utility.closeBanner();
                  if (!isNetWorkConnected() && getIt<SideToolBarCubit>().isSideToolBarEnabled) {
                    if(getIt<OnlineModelViewerCubit>().isCalibListPressed){
                      getIt<SideToolBarCubit>().isWhite = false;
                      getIt<OnlineModelViewerCubit>().isShowPdfView = false;
                      getIt<OnlineModelViewerCubit>().calibListPresentState();
                    }
                    if (Utility.isIos) {
                      getIt<OnlineModelViewerCubit>().callViewObjectFileAssociationDetails();
                    }
                    getIt<ModelTreeTitleClickEventCubit>().openModelTreeDialog();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: NormalTextWidget(title, key: const Key("ModelTreeAppbarTitle"), maxLines: 1, fontSize: 15.0, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium),
                      ),
                      Visibility(
                        visible: !isNetWorkConnected() && getIt<OnlineModelViewerCubit>().isModelTreeOpen,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: AColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child: Icon(
                  Icons.bookmark,
                  size: 15.0,
                  color: AColors.textColor,
                ),
              ),
            ),
          ],
        );
      case NavigationMenuItemType.home:
        return Text(
          title,
          style: TextStyle(color: AColors.textColor, fontSize: 15, fontWeight: AFontWight.medium),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      default:
        return Text(
          _buildToolbarTitle(title, context),
          style: TextStyle(color: AColors.textColor, fontSize: 15, fontWeight: AFontWight.medium),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
    }
  }
  String _buildToolbarTitle(String title, BuildContext context){
    switch (_navigationCubit.currSelectedItem) {
      case NavigationMenuItemType.quality:
        return context.toLocale!.quality_plans;
      case NavigationMenuItemType.tasks:
        return context.toLocale!.lbl_task;
      default:
        return title;

    }
  }
}
