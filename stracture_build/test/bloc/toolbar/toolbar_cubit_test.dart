
import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  di.init(test: true);
  group("Toolbar Cubit:", () {
    ToolbarCubit toolbarCubit = ToolbarCubit();

    test("Initial State", () {
      expect(toolbarCubit.state, ToolbarNavigationItemSelectedState(NavigationMenuItemType.home,"Home"));
    });

    test("Initial State is instance of ToolbarNavigationItemSelectedState", () {
      expect(toolbarCubit.state, isA<ToolbarNavigationItemSelectedState>());
    });

    blocTest<ToolbarCubit, FlowState>(
      'emits [ToolbarNavigationItemSelectedState] when updateSelectedItemByPosition() is called with file',
      build: () => ToolbarCubit(),
      act: (cubit) async => await cubit.updateSelectedItemByPosition(NavigationMenuItemType.files),
      expect: () =>
      [ToolbarNavigationItemSelectedState(NavigationMenuItemType.files,"Files")],
    );

    blocTest<ToolbarCubit, FlowState>(
      'emits [] when updateTitleFromItemType() is called with currentSelectedItem: NavigationMenuItemType.files',
      build: () => ToolbarCubit(),
      act: (cubit) async => await cubit.updateTitleFromItemType(currentSelectedItem:  NavigationMenuItemType.files),
      expect: () => [],
    );
  });
}
