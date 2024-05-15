import 'package:field/bloc/view_file_association/view_file_association_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileAssociationCubit', () {
    test('emitFullWidth should update isFullViewObjectDetails correctly', () {
      // Arrange
      final cubit = FileAssociationCubit();
      final isFullWidth = true;

      // Act
      cubit.emitFullWidth(isFullWidth);

      // Assert
      expect(cubit.isFullViewObjectDetails, isFullWidth);
    });

    test('emitFullWidth should emit the correct state', () {
      // Arrange
      final cubit = FileAssociationCubit();
      final isFullWidth = false;

      // Act
      cubit.emitFullWidth(isFullWidth);

      // Assert
      expect(cubit.state, isA<ViewFullScreenFileAssociation>());
      expect((cubit.state as ViewFullScreenFileAssociation).isShow, isFullWidth);
    });
  });
}
