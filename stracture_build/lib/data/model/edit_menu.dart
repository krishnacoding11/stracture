import 'dart:convert';

class EditOperationMenuModel {
  EditOperationMenuModel({
    this.imagePath,
    this.actionUrl,
  });

  EditOperationMenuModel.fromJson(dynamic json) {
    actionUrl = json['folder_title'];
    imagePath = json['globalKey'];
  }

  String? imagePath;
  String? actionUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['folder_title'] = actionUrl;
    map['globalKey'] = imagePath;
    return map;
  }
  static List<EditOperationMenuModel> jsonListToLocationList(dynamic response) {
    return  List<EditOperationMenuModel>.from(
        response.map((x) => EditOperationMenuModel.fromJson(x))).toList();
  }

  static List<EditOperationMenuModel>? jsonToList(dynamic response) {
    var jsonData = json.decode(response);
    return jsonListToLocationList(jsonData);
  }
}
