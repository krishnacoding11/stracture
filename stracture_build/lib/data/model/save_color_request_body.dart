import 'dart:convert';

List<SaveColorRequestBody> saveColorRequestBodyFromJson(String str) => List<SaveColorRequestBody>.from(json.decode(str).map((x) => SaveColorRequestBody.fromJson(x)));

String saveColorRequestBodyToJson(List<SaveColorRequestBody> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SaveColorRequestBody {
  String? guid;
  String? color;

  SaveColorRequestBody({
    this.guid,
    this.color,
  });

  factory SaveColorRequestBody.fromJson(Map<String, dynamic> json) => SaveColorRequestBody(
    guid: json["guid"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "guid": guid,
    "color": color,
  };
}
