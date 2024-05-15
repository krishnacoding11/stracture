import 'package:field/data/model/measurement_units.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  late MeasurementUnits measurementUnitsOne;
  late MeasurementUnits measurementUnitsTwo;

  setUp(() {
    measurementUnitsOne=MeasurementUnits("sqmm", "mm2");
    measurementUnitsTwo=MeasurementUnits("sqmm", "mm2");
  });

  group("Measurement Units Model Test :", () {
    test("Equal method unit testing", () {
      expect(measurementUnitsOne.key, measurementUnitsTwo.key);
      expect(measurementUnitsOne.value, measurementUnitsTwo.value);
    });

    test("Equal Props method unit testing", () {
      expect(measurementUnitsOne.props, measurementUnitsTwo.props);
    });
  });
}
