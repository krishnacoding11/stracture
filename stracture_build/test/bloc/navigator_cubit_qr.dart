import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/navigation/field_navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockQrUseCase extends Mock implements QrUseCase {}

class MockFieldNavigation extends Mock implements FieldNavigator {}

void main() {
  late FieldNavigatorCubit cubit;
  late MockQrUseCase mockQrUseCase;
  late MockFieldNavigation mockFieldNavigation;

  setUp(() {

    mockQrUseCase = MockQrUseCase();
    mockFieldNavigation = MockFieldNavigation();
    cubit = FieldNavigatorCubit(qrUseCase: mockQrUseCase, objNavigator: mockFieldNavigation);
  });

  tearDown(() {
    cubit.close();
  });

  test('isProjectSelected is true by default', () {
    expect(cubit.isProjectSelected, isTrue);
  });



  test('should call getFieldEnableSelectedProjectsAndLocations on success', () async {
    // Arrange
    final locId = 'exampleLocId';
    final projectId = 'exampleProjectId';
    final map = {
      'projectId': projectId,
      'locationIds': locId,
      'isObservationCountRequired': false,
    };
    final successResult = SUCCESS([{'folderId': 'exampleFolderId'}],null,200);
    when(mockQrUseCase.getLocationDetails(map)).thenAnswer((_) async => successResult);
    cubit.getLocationDetails(locId, projectId);
    verify(mockQrUseCase.getLocationDetails(map));
  });

}