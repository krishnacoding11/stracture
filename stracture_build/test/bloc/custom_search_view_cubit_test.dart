import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/custom_search_view/custom_search_view_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_method_channel.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  CustomSearchViewCubit customSearchViewCubit = CustomSearchViewCubit();


  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<CustomSearchViewCubit>();
    di.getIt.registerFactory<CustomSearchViewCubit>(() => customSearchViewCubit);
  }

  setUp(() {
    customSearchViewCubit = CustomSearchViewCubit();
  });


  group('Custom search view cubit test  -', () {
    configureCubitDependencies();

    blocTest<CustomSearchViewCubit, FlowState>("Loading State if search list loading.",
        build: () {
          return customSearchViewCubit;
        },
        act: (c) => c.getSuggestionsChange(),
        seed: () => LoadingState(stateRendererType:
            StateRendererType.POPUP_LOADING_STATE));




    blocTest<CustomSearchViewCubit, FlowState>(
      "Emit State for setSuggestions list",
      build: () {
        return customSearchViewCubit;
      },
      act: (c) => c.setSuggestions("", []),
      expect: () => [isA<ContentState>()]
    );

    blocTest<CustomSearchViewCubit, FlowState>(
        "Emit State for suggestion Listen",
        build: () {
          return customSearchViewCubit;
        },
        act: (c) => c.setSuggestionListen(),
        expect: () => [isA<ContentState>()]
    );

  });
}
