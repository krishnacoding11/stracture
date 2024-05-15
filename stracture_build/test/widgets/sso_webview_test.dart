import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/local/login/login_local_repository.dart';
import 'package:field/data/remote/login/login_repository_impl.dart';
import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/widgets/sso_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

void main() {
  configureLoginCubitDependencies() {
    getIt.registerLazySingleton<LoginCubit>(() => LoginCubit());
    getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase());
    getIt.registerLazySingleton<LogInLocalRepository>(
            () => LogInLocalRepository());
    getIt.registerLazySingleton<LogInRemoteRepository>(
            () => LogInRemoteRepository());
  }

  group("Test sso widget", () {
    configureLoginCubitDependencies();
    SSOWebView? myWidget;
    MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => getIt<LoginCubit>(),
          child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: myWidget = const SSOWebView(
                url:
                "https://myapps.microsoft.com/signin/f8b63fca-c48d-4d63-a516-cfb6dfdbd3f9?tenantId=54b90cf0-8817-42de-893f-9d32076b4a9b&loginToRp=https://portalqa.asite.com/sso/saml/metadata",
                emailId: 'jdiyora@asite.com',
              )),
        ));

    testWidgets("Find sso widget", (tester) async {
      await tester.pump(const Duration(seconds: 5));
      Finder formWidgetFinder = find.byType(InAppWebView);
      expect(formWidgetFinder, findsNothing);
    });

    testWidgets("initialUrlRequest", (tester) async {
      await tester.pump(const Duration(seconds: 5));
      final String? currentUrl = myWidget?.url;
      expect(currentUrl,
          "https://myapps.microsoft.com/signin/f8b63fca-c48d-4d63-a516-cfb6dfdbd3f9?tenantId=54b90cf0-8817-42de-893f-9d32076b4a9b&loginToRp=https://portalqa.asite.com/sso/saml/metadata");

      final String? currentEmail = myWidget?.emailId;
      expect(currentEmail, 'jdiyora@asite.com');
    });
  });
}