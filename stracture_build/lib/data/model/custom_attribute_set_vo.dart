
import 'dart:convert';

// List<CustomAttributeSetVo> customAttributeSetVoFromJson(String str) => List<CustomAttributeSetVo>.from(json.decode(str).map((x) => CustomAttributeSetVo.fromJson(x)));

// String customAttributeSetVoToJson(List<CustomAttributeSetVo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomAttributeSetVo {
  String? projectId;
  String? attributeSetId;
  String? serverResponse;

  CustomAttributeSetVo({
    this.serverResponse,
    this.attributeSetId,
    this.projectId
  });

  CustomAttributeSetVo.fromJson(dynamic json) {
    // json = jsonDecode(json);
      final key = json.key;
      final value = json.value;

      serverResponse=jsonEncode(value);
      attributeSetId = key;

  }
  //
  // Map<String, dynamic> toJson() => {
  //   "childAttributeName": childAttributeName,
  //   "parentAttributeName": parentAttributeName,
  //   "parentChildRelation": Map.from(parentChildRelation!).map((k, v) => MapEntry<String, dynamic>(k, v)),
  // };
  static List<CustomAttributeSetVo> getCustomAttributeVOList(dynamic json) {
    json = jsonDecode(json);
    List<CustomAttributeSetVo> attributeSetVOList = [];
    for (final mapEntry in json.entries) {
      attributeSetVOList.add(CustomAttributeSetVo.fromJson(mapEntry));
    }
    return attributeSetVOList;
  }

}
