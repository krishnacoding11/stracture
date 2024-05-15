import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
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
        home: ModelRequestSetOfflineDialog(
          context,
          onTap: () {}, model: Model(),
        ));
  }

  group('Model Tree Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_center_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_container_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_column_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_image_asset_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_model_request_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_padding_model_set_request_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_row_model_set_request_dialog')), findsOneWidget);
    });
  });
}
