

import 'package:equatable/equatable.dart';

abstract class CBIMSettingsState extends Equatable {}

class PageInitialState extends CBIMSettingsState {
  @override
  List<Object?> get props => [];

}


class InitialState extends CBIMSettingsState {
  @override
  List<Object?> get props => [];
}

class SliderValueChangeState extends CBIMSettingsState {
  final double value;
  SliderValueChangeState(this.value);
  @override
  List<Object?> get props => [value];

}

