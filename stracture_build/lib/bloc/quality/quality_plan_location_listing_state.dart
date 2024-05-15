// ignore_for_file: must_be_immutable

import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../presentation/base/state_renderer/state_renderer.dart';

class QualityListState extends FlowState {
  final QualityListInternalState qualityListInternalState;
  final InternalState internalState;

  QualityListState(this.qualityListInternalState, this.internalState);
}

class ActivityListState<T> extends QualityListState {
  T? response;
  StateRendererType? stateRendererType;
  String? time;
  String? message;
  @override
  final InternalState internalState;
  @override
  final QualityListInternalState qualityListInternalState;

  ActivityListState(this.response,this.qualityListInternalState,this.internalState, {this.stateRendererType, this.time, this.message})
      : super(qualityListInternalState, internalState);

  @override
  List<Object?> get props =>
      [qualityListInternalState, internalState, response, time, message];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class LocationListState<T> extends QualityListState {
  T? response;
  StateRendererType? stateRendererType;
  String? time;
  @override
  final InternalState internalState;
  @override
  final QualityListInternalState qualityListInternalState;

  LocationListState(this.response,this.qualityListInternalState,this.internalState, {this.stateRendererType, this.time})
      : super(qualityListInternalState, internalState);

  @override
  List<Object?> get props =>
      [qualityListInternalState, internalState, response, time];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class BreadCrumbState extends FlowState {
  final List<dynamic> breadcrumbList;

  BreadCrumbState(this.breadcrumbList);

@override
List<Object> get props => [breadcrumbList];
}

class RefreshLoading extends FlowState {
  final bool isRefreshLoading;
  final String  time;

  RefreshLoading(this.isRefreshLoading,this.time);

  @override
  List<Object> get props => [isRefreshLoading,time];
}