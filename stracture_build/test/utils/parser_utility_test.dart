
import 'package:field/utils/parser_utility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FormType Json De-Hashed data test', () {
    String inputData = "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}";
    String expectedData = "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\",\"had\":\"0\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\",\"num_days\":1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\",\"num_days\":2,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}";
    String outputData = ParserUtility.formTypeJsonDeHashed(jsonData: inputData);
    expect(true, outputData==expectedData);
  });

  test('Sent Action Json De-Hashed data test', () {
    String inputData = "[{\"projectId\":\"0\$\$GLgvTZ\",\"resourceParentId\":11602758,\"resourceId\":12303949,\"resourceCode\":\"ORI001\",\"resourceStatusId\":0,\"msgId\":\"12303949\$\$9YRrBv\",\"commentMsgId\":\"12303949\$\$IsZiTZ\",\"actionId\":3,\"actionName\":\"Respond\",\"actionStatus\":0,\"priorityId\":0,\"actionDate\":\"Thu Jul 13 13:40:36 BST 2023\",\"dueDate\":\"Fri Jul 21 06:59:59 BST 2023\",\"distributorUserId\":2017529,\"recipientId\":1161363,\"remarks\":\"\",\"distListId\":13711658,\"transNum\":\"-1\",\"actionTime\":\"6 Days\",\"actionCompleteDate\":\"\",\"instantEmailNotify\":\"true\",\"actionNotes\":\"\",\"entityType\":0,\"instanceGroupId\":\"0\$\$zIQWnb\",\"isActive\":true,\"modelId\":\"0\$\$FQuNk4\",\"assignedBy\":\"Mayur Raval m.,Asite Solutions Ltd\",\"recipientName\":\"Chandresh Patel, Asite Solutions\",\"recipientOrgId\":\"3\",\"id\":\"ACTC13711658_1161363_3_1_12303949_11602758\",\"viewDate\":\"\",\"assignedByOrgName\":\"Asite Solutions Ltd\",\"distributionLevel\":0,\"distributionLevelId\":\"0\$\$NQVpDJ\",\"dueDateInMS\":1689919199000,\"actionCompleteDateInMS\":0,\"actionDelegated\":false,\"actionCleared\":false,\"actionCompleted\":false,\"assignedByEmail\":\"m.raval@asite.com\",\"assignedByRole\":\"\",\"generateURI\":true}]";
    String expectedData = "[{\"projectId\":\"0\,\"resourceParentId\":11602758,\"resourceId\":12303949,\"resourceCode\":\"ORI001\",\"resourceStatusId\":0,\"msgId\":\"12303949\",\"commentMsgId\":\"12303949\",\"actionId\":3,\"actionName\":\"Respond\",\"actionStatus\":0,\"priorityId\":0,\"actionDate\":\"Thu Jul 13 13:40:36 BST 2023\",\"dueDate\":\"Fri Jul 21 06:59:59 BST 2023\",\"distributorUserId\":2017529,\"recipientId\":1161363,\"remarks\":\"\",\"distListId\":13711658,\"transNum\":\"-1\",\"actionTime\":\"6 Days\",\"actionCompleteDate\":\"\",\"instantEmailNotify\":\"true\",\"actionNotes\":\"\",\"entityType\":0,\"instanceGroupId\":\"0\",\"isActive\":true,\"modelId\":\"0\",\"assignedBy\":\"Mayur Raval m.,Asite Solutions Ltd\",\"recipientName\":\"Chandresh Patel, Asite Solutions\",\"recipientOrgId\":\"3\",\"id\":\"ACTC13711658_1161363_3_1_12303949_11602758\",\"viewDate\":\"\",\"assignedByOrgName\":\"Asite Solutions Ltd\",\"distributionLevel\":0,\"distributionLevelId\":\"0\",\"dueDateInMS\":1689919199000,\"actionCompleteDateInMS\":0,\"actionDelegated\":false,\"actionCleared\":false,\"actionCompleted\":false,\"assignedByEmail\":\"m.raval@asite.com\",\"assignedByRole\":\"\",\"generateURI\":true}]";
    String outputData = ParserUtility.sentActionsJsonDeHashed(jsonData: inputData);
    expect(true, outputData==expectedData);
  });

  test('Draft Sent Action Json De-Hashed data test', () {
    String inputData = "[{\"actionID\":\"7\$\$pq65jX\",\"userID\":\"859155\$\$IWuS49\",\"actionNotes\":\"\",\"actionDueDate\":\"\",\"userOrgName\":\"Asite Solutions\",\"fname\":\"Saurabh\",\"lname\":\"Banethia (5327)\",\"actionName\":\"For Information\",\"emailId\":\"sbanethia@asite.com\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000\",\"isSendNotification\":false,\"userCannotOverrideNotification\":false,\"user_type\":1,\"projectId\":\"0\$\$GLgvTZ\",\"dueDays\":0,\"distListId\":0,\"distributorId\":0,\"generateURI\":true},{\"actionID\":\"7\$\$pq65jX\",\"userID\":\"859155\$\$IWuS49\",\"actionNotes\":\"\",\"actionDueDate\":\"\",\"userOrgName\":\"Asite Solutions\",\"fname\":\"Saurabh\",\"lname\":\"Banethia (5327)\",\"actionName\":\"For Information\",\"emailId\":\"sbanethia@asite.com\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000\",\"isSendNotification\":false,\"userCannotOverrideNotification\":false,\"user_type\":1,\"projectId\":\"0\$\$GLgvTZ\",\"dueDays\":0,\"distListId\":0,\"distributorId\":859155,\"generateURI\":true}]";
    String expectedData = "[{\"actionID\":\"7\",\"userID\":\"859155\",\"actionNotes\":\"\",\"actionDueDate\":\"\",\"userOrgName\":\"Asite Solutions\",\"fname\":\"Saurabh\",\"lname\":\"Banethia (5327)\",\"actionName\":\"For Information\",\"emailId\":\"sbanethia@asite.com\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000\",\"isSendNotification\":false,\"userCannotOverrideNotification\":false,\"user_type\":1,\"projectId\":\"0\",\"dueDays\":0,\"distListId\":0,\"distributorId\":0,\"generateURI\":true},{\"actionID\":\"7\",\"userID\":\"859155\",\"actionNotes\":\"\",\"actionDueDate\":\"\",\"userOrgName\":\"Asite Solutions\",\"fname\":\"Saurabh\",\"lname\":\"Banethia (5327)\",\"actionName\":\"For Information\",\"emailId\":\"sbanethia@asite.com\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000\",\"isSendNotification\":false,\"userCannotOverrideNotification\":false,\"user_type\":1,\"projectId\":\"0\",\"dueDays\":0,\"distListId\":0,\"distributorId\":859155,\"generateURI\":true}]";
    String outputData = ParserUtility.draftSentActionsJsonDeHashed(jsonData: inputData);
    expect(true, outputData==expectedData);
  });
}