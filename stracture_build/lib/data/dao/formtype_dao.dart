

import 'dart:convert';

import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/parser_utility.dart';
import '../model/apptype_vo.dart';

class FormTypeDao extends Dao<AppType> {

  static const tableName = 'FormGroupAndFormTypeListTbl';

  static const projectIdField = "ProjectId";
  static const formTypeIdField = "FormTypeId";
  static const formTypeGroupIdField = "FormTypeGroupId";
  static const formTypeGroupNameField = "FormTypeGroupName";
  static const formTypeGroupCodeField = "FormTypeGroupCode";
  static const formTypeNameField = "FormTypeName";
  static const appBuilderIdField = "AppBuilderId";
  static const instanceGroupIdField = "InstanceGroupId";
  static const templateTypeIdField = "TemplateTypeId";
  static const formTypeDetailJsonField = "FormTypeDetailJson";
  static const allowLocationAssociationField = "AllowLocationAssociation";
  static const canCreateFormsField = "CanCreateForms";
  static const appTypeIdField = "AppTypeId";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$formTypeIdField INTEGER NOT NULL,"
      "$formTypeGroupIdField INTEGER NOT NULL,"
      "$formTypeGroupNameField TEXT NOT NULL,"
      "$formTypeGroupCodeField TEXT,"
      "$formTypeNameField TEXT NOT NULL,"
      "$appBuilderIdField TEXT NOT NULL,"
      "$instanceGroupIdField INTEGER NOT NULL,"
      "$templateTypeIdField INTEGER NOT NULL DEFAULT 1,"
      "$formTypeDetailJsonField TEXT,"
      "$allowLocationAssociationField INTEGER NOT NULL DEFAULT 0,"
      "$canCreateFormsField INTEGER NOT NULL DEFAULT 0,"
      "$appTypeIdField TEXT";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formTypeIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<AppType> fromList(List<Map<String, dynamic>> query) {
    return List<AppType>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  AppType fromMap(Map<String, dynamic> query) {
    AppType item = AppType();
    item.appTypeId = int.parse(query[appTypeIdField] ?? "0");
    item.projectID = query[projectIdField].toString();
    item.formTypeID = query[formTypeIdField].toString();
    item.formTypeGroupID = query[formTypeGroupIdField].toString();
    item.formTypeGroupName = query[formTypeGroupNameField].toString();
    item.code = query[formTypeGroupCodeField].toString();
    item.formTypeName = query[formTypeNameField].toString();
    item.appBuilderCode = query[appBuilderIdField].toString();
    item.instanceGroupId = query[instanceGroupIdField].toString();
    item.templateType = query[templateTypeIdField];
    item.formTypeDetailJson = query[formTypeDetailJsonField].toString();
    Map formDetailJsonField = jsonDecode(query[formTypeDetailJsonField].toString());
    Map  formDetail    = formDetailJsonField["formTypesDetail"] ?? {};
    Map formTypeVO = formDetail["formTypeVO"] ?? {};
    item.isMarkDefault = formTypeVO["isMarkDefault"] ?? false;
    item.allowLocationAssociation = (query[allowLocationAssociationField] == 1) ? true : false;
    item.canCreateForms = (query[canCreateFormsField] == 1) ? true : false;
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(AppType object) {
    return Future.value({
      appTypeIdField:object.appTypeId.toString() ?? "",
      projectIdField: object.projectID?.plainValue() ?? "",
      formTypeIdField: object.formTypeID?.plainValue() ?? "",
      formTypeGroupIdField: object.formTypeGroupID?.toString() ?? "",
      formTypeGroupNameField: object.formTypeGroupName ?? "",
      formTypeGroupCodeField: object.code ?? "",
      formTypeNameField: object.formTypeName ?? "",
      appBuilderIdField: object.appBuilderCode ?? "",
      instanceGroupIdField: object.instanceGroupId?.plainValue() ?? "",
      templateTypeIdField: object.templateType?.toString() ?? "",
      formTypeDetailJsonField: ParserUtility.formTypeJsonDeHashed(jsonData: object.formTypeDetailJson ?? ""),
      allowLocationAssociationField: (object.allowLocationAssociation ?? false) ? 1 : 0,
      canCreateFormsField: (object.canCreateForms ?? false) ? 1 : 0,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<AppType> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<AppType> objects) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(objects);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}