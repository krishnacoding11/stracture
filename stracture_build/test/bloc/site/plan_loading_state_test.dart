import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:test/test.dart';

void main() {
  group('PlanLoadingState', () {
    test('Test PlanLoadingState props', () {
      final state1 = PlanLoadingState(PlanStatus.loadingPlan);
      final state2 = PlanLoadingState(PlanStatus.loadedPlan);

      expect(state1.props, [PlanStatus.loadingPlan]);
      expect(state2.props, [PlanStatus.loadedPlan]);
    });
  });

  group('LastLocationChangeState', () {
    test('Test LastLocationChangeState props', () {
      final state = LastLocationChangeState();

      // No specific properties to test, just ensure the state can be created.
      expect(state.props, isNotEmpty);
    });
  });

  group('RefreshSiteTaskListState', () {
    test('Test RefreshSiteTaskListState props', () {
      final state = RefreshSiteTaskListState();

      // No specific properties to test, just ensure the state can be created.
      expect(state.props, isNotEmpty);
    });
  });

  group('PinsLoadedState', () {
    test('Test PinsLoadedState props', () {
      final state = PinsLoadedState(type: Pins.all); // You need to define Pins for testing

      // The type property is optional, so the props should be just the timestamp.
      expect(state.props, isNotEmpty);
    });
  });

  group('CloseKeyBoardState', () {
    test('Test CloseKeyBoardState props', () {
      final state = CloseKeyBoardState();

      expect(state.props, isNotEmpty);
    });
  });

  group('ShowObservationDialogState', () {
    test('Test ShowObservationDialogState props', () {
      final state = ShowObservationDialogState(ObservationData.fromJson({}), 10.2, 11.5, 20, 20, true);

      expect(state.x, 10.2);
      expect(state.y, 11.5);
      expect(state.pinHeight, 20);
      expect(state.pinWidth, 20);
      expect(state.isShowDialog, true);
    });
  });

  group('CreateTaskNavigationState', () {
    test('Test CreateTaskNavigationState props', () {
      final state = CreateTaskNavigationState("https://google.com", {"projectID": "12345"}, AppType.fromJson({"formTypeID": "1234"}));

      expect(state.url, "https://google.com");
      expect(state.data, {"projectID": "12345"});
      expect(state.appType, AppType.fromJson({"formTypeID": "1234"}));
    });
  });
}
