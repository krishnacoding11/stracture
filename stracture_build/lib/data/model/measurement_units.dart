import 'package:equatable/equatable.dart';

class MeasurementUnits extends Equatable {
  String key;
  String value;

  MeasurementUnits(this.key, this.value);

  @override
  List<Object?> get props => [this.key, this.value];
}
