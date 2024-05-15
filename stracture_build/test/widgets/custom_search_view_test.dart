import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/custom_search_view/custom_search_view_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/widgets/custom_search_view/custom_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../bloc/mock_method_channel.dart';

class MockCustomSearchCubit extends MockCubit<FlowState>
    implements CustomSearchViewCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  Widget getTestWidget(MockCustomSearchCubit dummyCubit, List searchList) {
    return MediaQuery(
      data: const MediaQueryData(),
      child: MultiProvider(
        providers: [
          BlocProvider<CustomSearchViewCubit>(
            create: (context) => dummyCubit,
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Material(
              child: Scrollable(
                viewportBuilder: (BuildContext context, ViewportOffset position) =>
                 CustomSearchSuggestionView(
                  suggestionsCallback: (value) {
                    return searchList;
                  },
                  onSuggestionSelected: (value) {},
                   textFieldConfiguration: SearchTextFormFieldConfiguration(focusNode: FocusNode()),
                  itemBuilder: (_, __, ___) {
                    return Container();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  group('Custom search view Test', () {
    configureLoginCubitDependencies();

    testWidgets('Custom search view load test', (WidgetTester tester) async {
      MockCustomSearchCubit dummyCubit = MockCustomSearchCubit();
      Widget testDrawerWidget = getTestWidget(dummyCubit,[]);
      await tester.pumpWidget(testDrawerWidget);
      expect(find.byKey(const Key("CustomSearchView")), findsOneWidget);
    });
  });
}
