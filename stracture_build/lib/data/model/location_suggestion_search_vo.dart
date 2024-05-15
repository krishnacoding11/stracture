import 'dart:convert';

class SearchDropdownList {
  String? searchKey;
  String? searchCount;

  SearchDropdownList(this.searchKey, this.searchCount);

  SearchDropdownList.fromJson(dynamic json) {
    searchKey = json['searchKey'].toString();
    searchCount = json['searchCount'].toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['searchKey'] = searchKey;
    map['searchCount'] = searchCount;
    return map;
  }

  static List<SearchDropdownList> jsonListToLocationList(dynamic response) {
    return  List<SearchDropdownList>.from(
        response.map((x) => SearchDropdownList.fromJson(x))).toList();
  }

  static List<SearchDropdownList>? jsonToList(dynamic response) {
    var jsonData = json.decode(response);
    return jsonListToLocationList(jsonData);
  }

}