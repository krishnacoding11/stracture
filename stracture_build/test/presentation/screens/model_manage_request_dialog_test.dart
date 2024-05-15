import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_dialogs/model_manage_request.dart';
import 'package:field/widgets/model_dialogs/model_request_set_offline_dialog.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../bloc/mock_method_channel.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  Map<String, dynamic> arguments = {};
  MockBuildContext context = MockBuildContext();

  configureLoginCubitDependencies() {
    init(test: true);
  }

  setUp(() async {
    List<FloorDetail> floorDetailsList = [];
    arguments = {
      RequestConstants.projectId: '2134298\$\$4Dizau',
      RequestConstants.floorList: floorDetailsList,
      RequestConstants.modelId: '41568\$\$mWexLq',
      RequestConstants.calibrateList: [],
      "bimModelsName": '0109 D',
    };
  });

  void onIconClicked() async {}

  Widget getTestWidget() {
    return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en')
        ],
        home: ModelManageRequestDialog(projectId: '2134298\$\$4Dizau', modelId: '41568\$\$mWexLq'));
  }

  group('Model Tree Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_manage_request_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_center')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_container')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_column')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_offline_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_revision_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_align')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_align_superseded')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_align_all')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_model_manage')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_row')), findsOneWidget);
      expect(find.byKey(Key('key_manage_request_expanded')), findsOneWidget);
      expect(find.byKey(Key('key_button_text_select_widget')), findsOneWidget);
    });
  });
}
