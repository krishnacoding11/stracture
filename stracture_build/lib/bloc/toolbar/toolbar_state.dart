import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../navigation/navigation_cubit.dart';

class ToolbarNavigationItemSelectedState extends FlowState {
 final NavigationMenuItemType navigationMenuItemType;
 final String? title;
 dynamic notificationResponse;

  ToolbarNavigationItemSelectedState(this.navigationMenuItemType,this.title,{this.notificationResponse});

  @override
  List<Object?> get props => [navigationMenuItemType,title,notificationResponse,];
}
