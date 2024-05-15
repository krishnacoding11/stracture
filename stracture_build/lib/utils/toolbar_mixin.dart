import 'package:field/logger/logger.dart';

import '../bloc/navigation/navigation_cubit.dart';
import '../bloc/toolbar/toolbar_cubit.dart';
import '../injection_container.dart';

mixin ToolbarTitle {
  void updateTitle(
      String? title, NavigationMenuItemType navigationMenuItemType) async {
    var toolBarCubit = getIt<ToolbarCubit>();
    // var navigationCubit = getIt<NavigationCubit>();
    toolBarCubit.updateTitleFromItemType(
        currentSelectedItem: navigationMenuItemType, title: title);
    Log.d(title);
    toolBarCubit.updateSelectedItemByPosition(navigationMenuItemType);
  }
}
