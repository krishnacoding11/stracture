// To parse this JSON data, do
//
//     final viewObjectDetailsModel = viewObjectDetailsModelFromJson(jsonString);

import 'dart:convert';

ViewObjectDetailsModel viewObjectDetailsModelFromJson(String str) => ViewObjectDetailsModel.fromJson(json.decode(str));

String viewObjectDetailsModelToJson(ViewObjectDetailsModel data) => json.encode(data.toJson());

class ViewObjectDetailsModel {
  List<Detail> details;

  ViewObjectDetailsModel({
    required this.details,
  });

  factory ViewObjectDetailsModel.fromJson(Map<String, dynamic> json) => ViewObjectDetailsModel(
        details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "details": List<dynamic>.from(details.map((x) => x.toJson())),
      };
}

class Detail {
  String sectionName;
  bool isExpanded;
  List<Property> property;

  Detail({
    required this.sectionName,
    required this.property,
    required this.isExpanded,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        sectionName: json["section-name"],
        isExpanded: json["isExpanded"] = false,
        property: List<Property>.from(json["property"].map((x) => Property.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "section-name": sectionName,
        "isExpanded": isExpanded = false,
        "property": List<dynamic>.from(property.map((x) => x.toJson())),
      };
}

class Property {
  String propertyName;
  String propertyValue;

  Property({
    required this.propertyName,
    required this.propertyValue,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        propertyName: json["property-name"],
        propertyValue: json["property-value"],
      );

  Map<String, dynamic> toJson() => {
        "property-name": propertyName,
        "property-value": propertyValue,
      };
}
