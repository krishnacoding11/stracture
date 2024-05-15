import 'package:equatable/equatable.dart';

import 'apptype_vo.dart';

class AppTypeGroup extends Equatable {
  String? formTypeName;
  List<AppType>? formAppType;
  bool? isExpanded;

  AppTypeGroup({this.formTypeName, this.formAppType, this.isExpanded = false});

  AppTypeGroup.fromJson(Map<String, dynamic> json) {
    formTypeName = json['formTypeName'];
    if (json['formAppType'] != null) {
      formAppType = <AppType>[];
      json['formAppType'].forEach((v) {
        formAppType!.add(AppType.fromJson(v));
      });
    }
    isExpanded = json['isExpanded'];
  }

  @override
  List<Object?> get props => [];

  AppTypeGroup copy({formTypeName, formAppType, isExpanded}) => AppTypeGroup(
      formAppType: formAppType ?? this.formAppType,
      formTypeName: formTypeName ?? this.formTypeName,
      isExpanded: isExpanded ?? this.isExpanded);
}
