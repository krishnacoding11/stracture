import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/custom_search_view/custom_search_view_cubit.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/domain/common/create_form_helper.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  CreateFormHelper createFormHelper = CreateFormHelper();

  configureCubitDependencies() {
    di.init(test: true);
    // di.getIt.unregister<CreateFormHelper>();
    di.getIt.registerFactory<CreateFormHelper>(() => createFormHelper);
  }

  setUp(() {
    createFormHelper = CreateFormHelper();
  });

  group('Custom search view cubit test  -', () {
    configureCubitDependencies();

    test('Create Form Helper', () {
      final createFormHelper = CreateFormHelper();
      var result = createFormHelper.onPostApiCall(false,"");
      expect(result, isA<Future<CreateFormSelectionCubit>>());
    });
  });
}