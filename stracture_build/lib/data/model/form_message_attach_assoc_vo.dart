

import 'dart:convert';

import '../../utils/field_enums.dart';

class FormMessageAttachAndAssocVO {
  String? _projectId;
  String? _locationId;
  String? _formTypeId;
  String? _formId;
  String? _formMsgId;
  String? _attachType;
  String? _attachAssocDetailJson;
  String? _offlineUploadFilePath;

//For Attachment
  String? _attachDocId;
  String? _attachRevId;
  String? _attachFileName;
  int? _attachSize;

//For Assoc
  String? _assocProjectId;

//For Assoc Doc
  String? _assocDocFolderId;
  String? _assocDocRevisionId;

//For Assoc Form
  String? _assocFormCommId;

//For Assoc Comment/AMessage
  String? _assocCommentMsgId;
  String? _assocCommentId;
  String? _assocCommentRevisionId;

//For Assoc View
  String? _assocViewModelId;
  String? _assocViewId;

//For Assoc List
  String? _assocListModelId;
  String? _assocListId;

  String? get projectId => _projectId;

  String? get formTypeId => _formTypeId;

  String? get formId => _formId;

  String? get locationId => _locationId;

  String? get formMsgId => _formMsgId;

  String? get attachType => _attachType;

  String? get attachAssocDetailJson => _attachAssocDetailJson;

  String? get offlineUploadFilePath => _offlineUploadFilePath;

  String? get attachDocId => _attachDocId;

  String? get attachRevId => _attachRevId;

  String? get attachFileName => _attachFileName;

  int? get attachSize => _attachSize;

  String? get assocProjectId => _assocProjectId;

  String? get assocDocFolderId => _assocDocFolderId;

  String? get assocDocRevisionId => _assocDocRevisionId;

  String? get assocFormCommId => _assocFormCommId;

  String? get assocCommentMsgId => _assocCommentMsgId;

  String? get assocCommentId => _assocCommentId;

  String? get assocCommentRevisionId => _assocCommentRevisionId;

  String? get assocViewModelId => _assocViewModelId;

  String? get assocViewId => _assocViewId;

  String? get assocListModelId => _assocListModelId;

  String? get assocListId => _assocListId;

  set setProjectId(String? tmpProjectId) => _projectId = tmpProjectId;

  set setFormTypeId(String? tmpFormTypeId) => _formTypeId = tmpFormTypeId;

  set setFormId(String? tmpFormId) => _formId = tmpFormId;

  set setLocationId(String? tmpLocationId) => _locationId = tmpLocationId;

  set setFormMsgId(String? tmpFormMsgId) => _formMsgId = tmpFormMsgId;

  set setAttachType(String? tmpAttachType) => _attachType = tmpAttachType;

  set setAttachAssocDetailJson(String? tmpAttachAssocDetailJson) => _attachAssocDetailJson = tmpAttachAssocDetailJson;

  set setOfflineUploadFilePath(String? tmpAttachOfflinePath) => _offlineUploadFilePath = tmpAttachOfflinePath;

  set setAttachDocId(String? tmpAttachDocId) => _attachDocId = tmpAttachDocId;

  set setAttachRevId(String? tmpAttachRevId) => _attachRevId = tmpAttachRevId;

  set setAttachFileName(String? tmpAttachFileName) => _attachFileName = tmpAttachFileName;

  set setAttachSize(int? tmpAttachSize) => _attachSize = tmpAttachSize;

  set setAssocProjectId(String? tmpAssocProjectId) => _assocProjectId = tmpAssocProjectId;

  set setAssocDocFolderId(String? tmpAssocDocFolderId) => _assocDocFolderId = tmpAssocDocFolderId;

  set setAssocDocRevisionId(String? tmpAssocDocRevisionId) => _assocDocRevisionId = tmpAssocDocRevisionId;

  set setAssocFormCommId(String? tmpAssocFormCommId) => _assocFormCommId = tmpAssocFormCommId;

  set setAssocCommentMsgId(String? tmpAssocCommentMsgId) => _assocCommentMsgId = tmpAssocCommentMsgId;

  set setAssocCommentId(String? tmpAssocCommentId) => _assocCommentId = tmpAssocCommentId;

  set setAssocCommentRevisionId(String? tmpAssocCommentRevisionId) => _assocCommentRevisionId = tmpAssocCommentRevisionId;

  set setAssocViewModelId(String? tmpAssocViewModelId) => _assocViewModelId = tmpAssocViewModelId;

  set setAssocViewId(String? tmpAssocViewId) => _assocViewId = tmpAssocViewId;

  set setAssocListModelId(String? tmpAssocListModelId) => _assocListModelId = tmpAssocListModelId;

  set setAssocListId(String? tmpAssocListId) => _assocListId = tmpAssocListId;

  FormMessageAttachAndAssocVO();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    return map;
  }

  FormMessageAttachAndAssocVO.fromJson(dynamic json) {
    setFormMsgId = json['parentMsgId'];
    setAttachType = json['type'];
    setAttachAssocDetailJson = jsonEncode(json);
    EAttachmentAndAssociationType eAttachType = EAttachmentAndAssociationType.fromNumber(int.parse(attachType ?? "-1"));
    switch (eAttachType) {
      case EAttachmentAndAssociationType.files:
        setAssocProjectId = json['projectId'];
        setAssocDocFolderId = json['folderId'];
        setAssocDocRevisionId = json['revisionId'];
        setAttachFileName = json['fileName'];
        setAttachSize = getFileSizeFromString(json['fileSize'] ?? "");
        break;
      case EAttachmentAndAssociationType.discussions:
        setAssocProjectId = json['projectId'];
        setAssocCommentMsgId = json['commentMsgId'];
        setAssocCommentId = json['commId'];
        setAssocCommentRevisionId = json['revisionId'];
        break;
      case EAttachmentAndAssociationType.apps:
      case EAttachmentAndAssociationType.references:
        setAssocProjectId = json['projectId'];
        setAssocFormCommId = json['commId'];
        break;
      case EAttachmentAndAssociationType.attachments:
        setAttachDocId = json['docId'];
        setAttachRevId = json['revisionId'];
        setAttachFileName = json['fileName'];
        setAttachSize = getFileSizeFromString(json['fileSize'] ?? "");
        break;

      case EAttachmentAndAssociationType.views:
        setAssocProjectId = json['projectId'];
        setAssocViewModelId = json['modelId'];
        setAssocViewId = json['viewId'];
        break;
      case EAttachmentAndAssociationType.lists:
        setAssocProjectId = json['projectId'];
        setAssocListModelId = json['modelId'];
        setAssocListId = json['listId'];
        break;
      default:
    }
  }

  /// param fileSize="1457 KB"
  /// return 1457
  int getFileSizeFromString(String fileSize) {
    String newFileSize = fileSize.replaceAll(RegExp('[^0-9]'), "");
    newFileSize = newFileSize.isEmpty ? newFileSize = "0" : newFileSize;
    return int.parse(newFileSize);
  }
}