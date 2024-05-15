
import 'package:field/bloc/sidebar/sidebar_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';

class UserProfileSidebarState extends FlowState {
  final String userFirstname;
  final String userImageUri;
  final Map<String, String> headerData;

  UserProfileSidebarState(this.userFirstname,this.userImageUri,this.headerData);

  @override
  List<Object> get props => [userFirstname,userImageUri,headerData];

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class MenuListSidebarState extends FlowState {
  final List<SidebarMenuItemType> menuList;

  MenuListSidebarState(this.menuList);

  @override
  List<Object> get props => [menuList];

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class MenuSidebarSelectedItemState extends FlowState {
  final SidebarMenuItemType selectedItem;

  MenuSidebarSelectedItemState(this.selectedItem);

  @override
  List<Object> get props => [MenuSidebarSelectedItemState];

  @override
  String getMessage() {
    return "";
  }

  @override
  StateRendererType getStateRendererType() {
    return StateRendererType.CONTENT_SCREEN_STATE;
  }
}