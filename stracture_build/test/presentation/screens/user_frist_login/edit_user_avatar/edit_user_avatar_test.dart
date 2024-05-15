import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/user_first_login/edit_avatar/edit_avatar.dart';
import 'package:field/widgets/app_permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../bloc/mock_method_channel.dart';

onPressed() {}

class MockFirstUserLoginSetupCubit extends MockCubit<FlowState>
    implements UserFirstLoginSetupCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockFirstUserLoginSetupCubit mockFirstUserLoginSetupCubit = MockFirstUserLoginSetupCubit();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Test Edit user Avatar widget", () {

    configureLoginCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<UserFirstLoginSetupCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: EditAvatar(from: "userSetting",))),
        ));

    testWidgets("Find Edit User Avatar widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));


      Finder selectFromCamera = find.byKey(const Key('SelectFromCamera'));
      Finder selectFromGallery = find.byKey(const Key('SelectFromGallery'));


      expect(selectFromCamera, findsOneWidget);
      expect(selectFromGallery, findsOneWidget);

      expect(tester.widget<InkWell>(selectFromCamera).onTap, isNotNull);
      expect(tester.widget<InkWell>(selectFromGallery).onTap, isNotNull);
    });

    testWidgets("Get Image From Gallery", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      Finder selectFromGallery = find.byKey(const Key('SelectFromGallery'));
      expect(selectFromGallery, findsOneWidget);

      final context = MockBuildContext();
      bool isPermissionGranted = await PermissionHandlerPermissionService().checkAndRequestPhotosPermission(context);
      expect(isPermissionGranted, true);

      when(() => mockFirstUserLoginSetupCubit.getImageFromGallery(context, () {}, selectedFilesCallBack)).thenAnswer((val) => selectedFilesCallBack());
      expect(tester.widget<InkWell>(selectFromGallery).onTap, isNotNull);
    });
  });
}

selectedFilesCallBack() {
  return [
    {
      "valid": {"path": "/data/user/0/com.asite.field/cache/file_picker/Test.pdf", "name": "Test.pdf", "bytes": null, "readStream": null, "size": 3028},
      "inValid": {"path": "/data/user/0/com.asite.field/cache/file_picker/Test.pdf", "name": "Test.pdf", "bytes": null, "readStream": null, "size": 3028}
    }
  ];
}

class MockBuildContext extends Mock implements BuildContext {}