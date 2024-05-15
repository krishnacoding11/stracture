import 'dart:async';
import 'dart:convert';

import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/homepage/home_page_view.dart';
import 'package:field/presentation/screen/site_routes/create_form_dialog/create_form_dialog.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/QR/navigator_cubit.dart';
import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/site/create_form_selection_cubit.dart';
import '../../../bloc/toolbar/toolbar_cubit.dart';
import '../../../data/model/apptype_vo.dart';
import '../../../data/model/qrcodedata_vo.dart';
import '../../../domain/common/create_form_helper.dart';
import '../../../injection_container.dart';
import '../../../logger/logger.dart';
import '../../../networking/network_info.dart';
import '../../../utils/file_form_utility.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/qrcode_utils.dart';
import '../../../utils/utils.dart';
import '../../../widgets/a_progress_dialog.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../managers/color_manager.dart';
import '../bottom_navigation/tab_navigator.dart';

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  final FieldNavigatorCubit _navigatorCubit = getIt<FieldNavigatorCubit>();
  AProgressDialog? aProgressDialog;
  final CreateFormSelectionCubit createFormSelectionCubit = getIt<CreateFormSelectionCubit>();
  final HomePageCubit homePageCubit = getIt<HomePageCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => _navigatorCubit), BlocProvider(create: (_) => createFormSelectionCubit), BlocProvider(create: (_) => homePageCubit)],
      child: MultiBlocListener(
          listeners: [
            BlocListener<FieldNavigatorCubit, FlowState>(
              listener: (_, state) async {
                if (state is SuccessState) {
                  closeProgressDialog();
                  if (!state.response.toString().isNullOrEmpty() && state.response["qrCodeType"] == QRCodeType.qrLocation) {
                    if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.sites) {
                      getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
                      getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
                    }
                    await Future.delayed(const Duration(milliseconds: 100));
                    NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: state.response["arguments"]);
                  } else if (!state.response.toString().isNullOrEmpty() && state.response["qrCodeType"] == QRCodeType.qrFormType) {
                    List<AppType> appTypeList = _navigatorCubit.getAppTypeList(state.response["formData"]);
                    if (appTypeList.isNotEmpty && appTypeList.first.canCreateForms == true) {
                      var map = state.response["arguments"];
                      map['isFrom'] = FromScreen.dashboard;
                      homePageCubit.emitShowFormCreateDialogState(map["url"], map, map["name"] ?? "");
                    } else {
                      Utility.showAlertWithOk(context, context.toLocale!.quality_no_create_form_permission);
                    }
                  }
                } else if (state is ErrorState) {
                  closeProgressDialog();
                  Log.d(state.message);
                  if (state.data != null && state.data is FromScreen && state.data == FromScreen.dashboard) {
                    Utility.showAlertWithOk(context, context.toLocale!.something_went_wrong);
                  } else if (state.code == 601 || state.code == 404) {
                    dynamic jsonResponse = jsonDecode(state.message);
                    String errorMsg = jsonResponse['msg'];
                    errorMsg = errorMsg.isNullOrEmpty() ? QrCodeUtility.getQrError(jsonResponse['key']) : errorMsg;
                    Utility.showAlertWithOk(context, errorMsg);
                  } else {
                    Utility.showQRAlertDialog(context, state.message.isNullOrEmpty() ? context.toLocale!.something_went_wrong : state.message);
                  }
                } else if (state is LoadingState) {
                  showProgressDialog();
                }
              },
            ),
            BlocListener<CreateFormSelectionCubit, FlowState>(listener: (_, state) async {
              if (state is LoadingState) {
                showProgressDialog();
              } else if (state is SuccessState) {
                closeProgressDialog();
                homePageCubit.showSiteTaskFormDialog(state.response);
              }
            }),
            BlocListener<HomePageCubit, FlowState>(
              listener: (_, state) async {
                if (state is ShowFormCreationOptionsDialogState) {
                  await showCreateFormDialog(context, await CreateFormHelper().onPostApiCall(false, "2"));
                } else if (state is ShowFormCreateDialogState) {
                  await FileFormUtility.showFormCreateDialog(context, frmViewUrl: state.frmViewUrl, data: state.data, title: state.title);
                } else if (state is NavigateTaskListingScreenState) {
                  NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.tasks, argument: {"isFrom": state.taskType});
                } else if (state is NavigateSiteListingScreenState) {
                  navigateSiteListingFromShortcutFilter(state);
                } else if (state is NoFormsMessageState) {
                  context.showSnack(context.toLocale!.lbl_can_not_create_forms);
                } else if (state is HomePageItemLoadingState && state.stateRendererType == StateRendererType.POPUP_LOADING_STATE) {
                  showProgressDialog();
                } else {
                  closeProgressDialog();
                }
              },
            )
          ],
          child: Scaffold(
            backgroundColor: AColors.themeLightColor,
            body: HomePageView(),
            resizeToAvoidBottomInset: false,
          )),
    );
  }

  showProgressDialog() {
    aProgressDialog ??= AProgressDialog(context, useSafeArea: true, isWillPopScope: true, dismissable: false);
    aProgressDialog?.show();
  }

  closeProgressDialog() {
    aProgressDialog?.dismiss();
  }

  Future<void> showCreateFormDialog(BuildContext context, CreateFormSelectionCubit createFormSelectionCubit) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext _) {
          return BlocProvider(
            key: Key('key_bloc_provider_create_form_dialog'),
            create: (_) => createFormSelectionCubit,
            child: const CreateFormDialog(
              key: Key('key_show_create_form_dialog'),
            ),
          );
        }).then((value) async {
      if (value is AppType) {
        if (!isNetWorkConnected() && value.templateType.isXSN) {
          Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
        } else {
          homePageCubit.showSiteTaskFormDialog(value);
        }
      }
    });
  }

  navigateSiteListingFromShortcutFilter(NavigateSiteListingScreenState state) {
    closeProgressDialog();
    getIt<ToolbarCubit>().updateTitleFromItemType(currentSelectedItem: NavigationMenuItemType.sites, title: state.arguments["projectDetail"].projectName);
    getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
    getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
    NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: state.arguments);
  }
}
