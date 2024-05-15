import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/language_change/language_change_cubit.dart';
import 'package:field/bloc/language_change/language_change_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LanguageChangeCubit languageChangeCubit;
  setUp(() {
    di.init(test: true);
    languageChangeCubit = LanguageChangeCubit();
  });

  group("Language Change Cubit:", () {
    blocTest<LanguageChangeCubit, FlowState>(
      'emits LanguageChangeState',
      build: () {
        return languageChangeCubit;
      },
      act: (cubit) async {
        await cubit.setCurrentLanguageId();
      },
      expect: () {
        return [isA<LanguageChangeState>()];
      },

    );
  });
}
