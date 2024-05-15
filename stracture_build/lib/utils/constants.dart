import 'dart:convert';

import 'package:field/utils/url_config.dart';
import 'package:flutter/services.dart';

class AConstants {
  static const fieldAppParam = "FieldApp=Field2.0";

  static const urlAsitedotcom = "https://www.asite.com";
  static const urlTermsOfUse = "$urlAsitedotcom/terms-of-use#terms";
  static const urlPrivacyPolicy = "$urlAsitedotcom/legal-terms-of-use#privacy";
  static const urlHelp = "https://asitefield-help.asite.com";
  static const urlAbout = "$urlAsitedotcom/about";

  static const String keyLastAppVersionCode = "lastAppVersionCode";
  static const String keyListWidth = "dialogHorizontalWidth";
  static const String keyLanguageData = "languageData";
  static const String keyUserData = "userData";
  static const String keyProjectData = "project";
  static const String keyIsPushNotificationEnable = "isPushNotificationEnable";
  static const String keyIncludeCloseOutForm = "includeCloseOutForm";
  static const int applicationId = 3;
  static const String allProjectsItemId = "-1";
  static const String name = "Name";
  static const String favouriteProjectsItemId = "-2";
  static const String cookie = 'Cookie';
  static const String projectsTab = "projectTab";
  static const String recentProject = "recentProject";
  static const String recentModel = "recentModel";
  static const String userFirstLogin = "userFirstLogin";
  static const String projectSelection = "projectSelection";
  static const String projectListFromSite = "projectListFromSite";
  static const String camera = "Camera";
  static const String gallery = "Gallery";
  static const String projectListFromQuality = "projectListFromQuality";
  static const String recentSearchQualityPlan = "recentSearchQualityPlan";
  static const String selectedPinFilter = "selectedPinFilter";
  static const String recentSearchLocation = "recentSearchLocation";
  static const String recentForm = "recentForm";
  static const String localLanguageDateFormatStorage = "localLanguageDateFormatStorage";
  static const String userCurrentDateFormat = "userCurrentDateFormat";
  static const String userCurrentLanguage = "userCurrentLanguage";
  static const String temperatureUnit = "temperatureUnit";
  static const String workOffline = "workOffline";
  static const String deviceToken = "deviceToken";
  static const String keyAppConfig = "AppConfig";
  static const String keyisLanguageChange = "isLanguageChange";
  static const String keyGeoTagEnabled = "geoSettingEnable";
  static const String homePage = "homePage";
  static const String filterFormInitialValue = "Filtered Form";

  // Network calling URL

  static late String collabUrl;
  static late String adoddleUrl;
  static String modelName = "";
  static late String oauthUrl;
  static late String taskUrl;
  static late String downloadUrl;
  static late String streamingServerUrl;
  static const String loginUrl = '/apilogin/cbim/';
  static const String logoutUrl = '/api/workspace/logout?applicationTypeId=3';
  static const String checkSsoUrl = '/login/getLoginCloudsDetail?emailId=%s';
  static const String projectListUrl = '/adoddlenavigatorapi/workspace/fieldEnabledSelectedProjects';
  static const String getPopupData = '/adoddlenavigatorapi/workspace/getPopupData';
  static const String userImageUri = '/commonapi/user/userImg?userId=%s&v=%s';
  static const String pdfDownloadUrl = "/api/workspace/%s/folder/%s/singleFileDownload/%s/false";
  static const String xfdfDownloadUrl = "/commonapi/pfdrawingservice/downloadXFDF?projectId=%s&revisionId=%s";
  static const String scsDownloadUrl = "/commonapi/model/download-chopped-file?projectId=%s&revisionId=%s&folderId=%s&floorNumber=%s";

  static const String getQualitySearchData = '/adoddle/filter';
  static const String locationTreeUrl = "/commonapi/pflocationservice/getLocationTree";
  static const String sendPasswordLink = "/commonapi/user/sendPasswordLink";
  static const String resetPasswordUrl = "/commonapi/user/resetPassword";
  static const String userprofileSettingUrl = "/adoddle/dashboard?action_id=205&_=%s&isUserImageFlagRequired=true";
  static const String csrfTokenUrl = "/adoddlenavigatorapi/csrf/generateCSRFToken";
  static const String favoriteProjectUrl = "/adoddle/projects";
  static const String getModels = "/adoddle/models";
  static const String checkQRCodeUrl = "/commonapi/qrcode/checkPermission";
  static const String formPermissionUrl = "/commonapi/form/getProjectAppTypeFormListByFormTypeIds";
  static const String locationTreeByAnnotationIdUrl = "/commonapi/pflocationservice/getLocationTreeByAnnotation";
  static const String locationDetailsByLocationIds = "/commonapi/pflocationservice/getLocationDetailsByLocationIds";
  static const String planObservationList = "/commonapi/pfobservationservice/getObservationListByPlan";
  static const String getHashUrl = "/commonapi/pfprojectfieldservice/getFieldsHashedValue";
  static const String getFieldAppTypeList = "/commonapi/pfobservationservice/getFieldAppTypeList";
  static const String getLocationDetails = "/commonapi/pflocationservice/getLocationDetailsByLocationIds";
  static const String siteTasksUrl = "/commonapi/pfobservationservice/getObservationList";
  static const String formExternalAttachUrl = "/commonapi/form/getExternalAttachmentsDetails";
  static const String viewThumbUrl = "/commonapi/thumbnail/viewThumb";
  static const String getTaskActionCountUrl = "/commonapi/task/getTaskCount?entityTypeId=%s&appType=%s&projectIds=%s&resourceStatus=%s";
  static const String getSearchTaskUrl = "/commonapi/task/searchTasks";
  static const String getTaskStatusListUrl = "/task/taskStatus/getTaskStatusList";
  static const String getDefectFilter = "/commonapi/userSearchFilterService/getUserSearchFilterColumn";
  static const String getFilterSiteTaskListUrl = "/adoddle/filter";
  static const String adoddleFilter = "/adoddle/filter";
  static const String adoddleApps = "/adoddle/apps";
  static const String adoddleSiteListing = "/adoddle/listing";
  static const String modelListURL = "/commonapi/model/getProjectModels";
  static const String bimProjectModelUrl = "/adoddle/models";
  static const String scsFileDownloadUri = '/commonapi/model/downloadSCS?projectId=%s&folderId=%s&revisionId=%s';
  static const String htmlFilePath = 'assets/files/offline.html';
  static const String htmlAnimationPath = 'assets/files/cBIM_Loader_Corrected/cBIM-Loader-alt.html';
  static const String qualityPlanLocationListing = "/commonapi/qaplan/viewQAPlanData";
  static const String syncLogFilePath = "sync-log.txt";
  static const String weatherDetails = "/commonapi/weather/getWeatherDetails";
  static const String getUserWithSubscription = "/commonapi/user/getUserWithSubscription";
  static const String getAllAppDcUrl = "/commonapi/pfprojectfieldservice/getAllApplicationsDcsUrls";
  static const String getActivityByPlanIdURL = '/commonapi/qaplan/viewQAPlanData';
  static const String getQualityPlanBreadCrumb = '/commonapi/qaplan/getQualityPlanBreadCrumb';
  static const String manageQAEntityData = '/commonapi/qaplan/manageQAEntityData';
  static const String getDashboardNotifications = '/commonapi/watch/getDashboardNotifications';
  static const String saveUserDeviceDetails = '/commonapi/pushnotificationservice/saveUserDeviceDetails';
  static const String getTaskFileFormData = '/adoddle/search';
  static const String projectListForSyncUrl = "/adoddlenavigatorapi/workspace/offLineFolderList/";
  static const String columnHeaderListSyncUrl = "/commonapi/form/getConfigurableColumn";
  static const String getFormListSyncUrl = "/commonapi/pfobservationservice/getObservationList";
  static const String siteFormTypeListForSyncUrl = "/commonapi/pfprojectfieldservice/getLatestProjectDefectFormTypeId";
  static const String siteFormTypeHTMLTemplateZipSyncUrl = "/dmsa/DownloadServlet?action_id=199&isFromSystemLevel=false&project_id=%s&formTypeId=%s";
  static const String siteCustomAttributeFormTypeSyncUrl = "/commonapi/form/getcustomAttributeDetailsByFormTypeId";
  static const String formTypeAttributeSetDetailSyncUrl = "/commonapi/manageAttribute/getAttributeSetDetails";
  static const String siteDistributionFormTypeSyncUrl = "/adoddlenavigatorapi/form/getDistributionList";
  static const String siteControllerFormTypeSyncUrl = "/commonapi/form/getFormTypeControllerUsers";
  static const String siteStatusFormTypeSyncUrl = "/commonapi/form/getStatusDetailsByFormTypeId";
  static const String siteFixFieldFormTypeSyncUrl = "/commonapi/htmlForm/getFixFieldFromData";
  static const String getFormMessageDataInBatchUrl = "/commonapi/form/getBatchFormMessageData";
  static const String getFormAttachmentBatchDownloadUrl = "/download/document/downloadZipSingleCall";
  static const String getServerTime = "/commonapi/pfprojectfieldservice/getServerTime";
  static const String getDeviceConfigurationUrl = "/commonapi/pfprojectfieldservice/getConfigurationForDevice";
  static const String getFieldsHashedValueUrl = "/commonapi/pfprojectfieldservice/getFieldsHashedValue";
  static const String getStatusStyleForProjectUrl = "/commonapi/pfprojectfieldservice/getStatusStyleForProject";
  static const String getManageTypeListUrl = "/commonapi/defectTypeservice/getDefectTypesForProjects";
  static const String getOfflineSyncDataSizeUrl = "/commonapi/pflocationservice/getOfflineSyncDataSize";
  static const String discardedFormIdsUrl = "/commonapi/pfobservationservice/getNotCreatedFormIds";

  static const String getChoppedFileStatus = '/commonapi/model/get-chopped-file-status';
  static const String processChoppedFiles = '/commonapi/model/process-chopped-file';
  static const String sendModelRequestForOffline = '/commonapi/model/sendRequestToSetModelForOfflineView';
  static const String canManageFile = '/adoddlenavigatorapi/workspace/offLineFolderList/';
  static const String getFloorDetails = '/commonapi/model/get-chopped-file-floor-details';

  //Workspace settings for geo tag
  static const String getWorkspaceSetting = '/commonapi/workspace/getWorkspacesInformationSettings';

  //Homepage shortcuts
  static const String manageDeviceHomePage = '/commonapi/pfprojectfieldservice/manageDeviceHomePage';
  static const String homePageDataForConfiguration = '/commonapi/pfprojectfieldservice/getFieldHomePageDataForButtonConfiguration?projectId=%s&appType=%d&isFromMapView=%s';

  //new url for filter for field app
  static String getSearchModelUrl(String projectId) {
    return "/commonapi/model/$projectId/searchModels";
  }
  static const String getTaskFormListing = '/adoddle/communications';

  //failureSSOUrl
  static const String ssoAsiteAdfsUrl = "https://sso.asite.com/adfs/ls/IdpInitiatedSignOn.aspx";
  static const String userDbFile = "fieldUser.db";
  static const String dataDbFile = "fieldData.db";
  static const String userProfile = "userProfile.jpg";
  static const String userReference = "userReference.db";
  static const String languageListUrl = "/commonapi/language/languageList?t=%s";
  static const String dashboardUrl = "/adoddle/dashboard";
  static const String uploadAttachmentUrl = "/adoddle/upload";
  static const String uploadInlineAttachmentUrl = "/adoddle/adoddleUpload";
  static const String uploadInlineAttachmentUrlXSN = "/adoddle/xsl/xdoc.jsp";
  static const String getSearchLocationList = "/adoddle/getPopupData";
  static const String getSuggestedSearchLocationList = "/commonapi/pfprojectfieldservice/locationSearchKeyWordCount";

  //UPLOAD URLS
  static const String uploadEventValidation = "/commonapi/event/uploadEventValidation";
  static const String simpleFileUpload = "/adoddlenavigatorapi/documents/simple_upload_file";

  static const String saveForm = "/adoddlenavigatorapi/form/saveForm/";
  static const String formDistAction = "/commonapi/form/commitDistribution";
  static const String clearFormForAckOrForActionUri = "/commonapi/form/clearFormForAckOrForAction";
  static const String discardDraftUri = "/commonapi/form/discardDraftMessage";
  static const String appsReleaseRespondsUri = "/commonapi/form/updateMsgStatus";
  static const String formStatusChange = "/commonapi/form/submitFormChangeStatus";

  static const siteTab = 110;
  static const autoSyncTab = 1;

  // for site end drawer Duration
  static const int siteEndDrawerDuration = 250;

  //POC
  static const String twoThreePoc = '2D/3D poc';
  static const String federatedModel = 'Federated Model Screen';
  static const String selectScsFile = 'Select SCS file';
  static const String performancePoc = 'Performance POC';
  static const String customPerformancePoc = 'Custom Performance POC';
  static const String heavyModelLoading = 'Heavy Model Loading';

  // user for to display existing login account for selection
  static const int userAccountLimit = 10;

  //Login Type
  static const String keyCloudTypeData = "cloud_type_data";
  static const String keyLoginType = "login_type";
  static const String keyCreatePasswordLink = "Create_Password_Link";
  static const int keyCloudLogin = 1;
  static const int keySsoLogin = 2;

  static const String asiteCloud = "Asite Cloud";
  static const String usCloud = "Asite US Gov. Cloud";
  static const String uaeCloud = "Asite UAE Cloud";
  static const String ksaCloud = "Asite KSA Cloud";
  static const String sandboxCloud = "Asite Sandbox Cloud";

  static const String termConditionPath = "assets/html/term&condition.html";
  static const List<String> siteAppBuilderIds = ["asi-site", "sng-def"];
  static const String keyLastApiCallTimestamp = "lastApiCallTimeStamp";
  static const String viewFormURL = "/adoddle/view/communications/viewForm.jsp";
  static const String viewFileURL = "/adoddle/viewer/fileView.jsp";

  //File Downloadin
  static const String needToDownload = "Need to download";
  static const String fileNotDownloaded = "File can not be downloaded.";
  static const String fileDownloaded = "File Downloaded.";
  static const String enterMemoryLimit = "Please Enter Memory Limit.";
  static const String selectModel = "Select Model";
  static const String pleaseSelectModel = "Please Select Model.";
  static const String withoutMemoryLimit = "Without Memory Limit";
  static const String memoryLimit = "Memory Limit";
  static const String withMemoryLimit = "With Memory Limit";

  static const String enterMemory = "Enter Memory Limit";
  static const String onlineWebView = "Online Web View";
  static const String pleaseWaitFileDownloading = "Please wait, File is downloading";
  static const String noModelsFound = "No Models Found.";
  static const String reset = "Reset";
  static const String makeTransparent = "Make Transparent";
  static const String focus = "Focus";
  static const String isolate = "Isolate";
  static const String assignColor = "Assign Color";
  static const String viewObjectDetail = "View Object Detail";
  static const String modelsLoadedSuccessfully = "Models Loaded Successfully.";
  static const String modelLoadedSuccessfully = "Model Loaded Successfully.";
  static const String cancel = "Cancel";
  static const String clear = "Clear";
  static const int thresholdCompletedTask = 25;
  static BuildEnvironment buildEnvironment = BuildEnvironment.qa;
  static String? buildFlavor;

  static const ADODDLE_FORM_PERMISSIONS = 167;
  static const PROJECT_PRIVILEGES_MULTI = 1342;
  static const PROJECT_PRIVILEGES = 207;
  static const FILE_VIEW_ATTRIBUTE_DETAILS = 1305;
  static const FILE_OFFLINE_MARKUP_LIST = 227;
  static const FILE_SAVE_COMMENT = 228;
  static const FILE_SAVE_DRAFT_COMMENT = 229;
  static const FILE_MARKUP_ID_BY_NAME = 230;
  static const ATTACHMENT_ASSOCIATION_COLUMN_HEADER = 1722;
  static const FILE_CREATE_COMMENT = 1728;
  static const FILE_EDIT_DRAFT = 1729;
  static const ATTACHMENT_ASSOCIATION = 1721;
  static const DISTRIBUTION = 11;
  static const DISTRIBUTION_ALONE = 26;
  static const VIEW_FORM_MSG_DETAILS_ACTION = 115;
  static const MESSAGE_THREADS = 114;
  static const COMMENT_MESSAGE_LISTING = 148;
  static const REPLY_ACTION_ID = 905;
  static const EDIT_AND_DISTRIBUTE = 904;
  static const INITIATE_EDIT_FORM_MSG_COMMITED = 953;
  static const REQUEST_DISCARD_DRAFT = 963;
  static const REQUEST_EDIT_ORI = 966;
  static const DISPLAY_FORM_CHANGE_STATUS = 571;
  static const REQUEST_SAVE_STATUS_CHANGE = 572;
  static const REQUEST_SAVE_ACKNOWLEDGEMENT = 20;
  static const REQUEST_SAVE_ACTION = 21;
  static const REQUEST_SAVE_DISTRIBUTION = 19;
  static const REQUEST_RELEASE_RESPONSE = 181;
  static const REQUEST_FIELD_ENABLED_PROJECT = 222;
  static const REQUEST_GET_RESULT_ASSOCIATE_LOCATION_TREE_BY_SEARCH = 221;
  static const REQUEST_LOCATION = 223;
  static const REQUEST_LOCATION_TREE = 224;
  static const REQUEST_GET_OBSERVATION_LIST_BY_PLAN = 225;
  static const REQUEST_GET_ASSOCIATE_LOCATION_TREE_BY_SEARCH = 1002;
  static const REQUEST_COPY_DEFECT = 903;
  static const BRAVA_FILE_VIEW_IN_PDFTRON = 1509;

  static String getCalibrationList(String projectId, String modelId) {
    return "/commonapi/2d3dcalibration/$projectId/$modelId";
  }

  static loadProperty() async {
    buildFlavor = await const MethodChannel("build_flavor").invokeMethod<String>('getFlavor');
    buildFlavor ??= "QA";
    setUrlPropertyByBuildFlavor(buildFlavor!);
  }

  static Future<void> setUrlPropertyByBuildFlavor(String buildFlavor) async {
    buildEnvironment = BuildEnvironment.values.firstWhere((element) => element.buildEnvironmentName == buildFlavor);
    String jsonString = await rootBundle.loadString('assets/json/config.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString)[buildFlavor];
    adoddleUrl = jsonMap['ADODDLE_URL'];
    collabUrl = jsonMap['COLLAB_URL'];
    taskUrl = jsonMap['TASK_URL'];
    oauthUrl = jsonMap['OAUTH_URL'];
    streamingServerUrl = jsonMap['STREAMING_SERVER_URL'];
    downloadUrl = jsonMap["DOWNLOAD_URL"];
  }

  static const String setAuditTrail = "/commonapi/model/insertModelAuditTrail";

  static const String saveColor = "/commonapi/model/saveBimObjectsColor";

  static String getColor(String projectId, String modelId) {
    return "/commonapi/model/getBimObjectsColor?modelId=$modelId&recordStartFrom=1&projectId=$projectId&maxObjectColors=10000";
  }

  static String getFileAssociation(String projectId, String modelId) {
    return "/commonapi/model/getModelExternalAttachmentList?projectId=$projectId&bimModelId=$modelId";
  }

  static String getFileAssociationByObjectId = "/adoddle/objectManagerController";
  static String getThreeDAppTypeList = "/adoddle/apps";

  static const String couldNotFindCalibData = "Could not find Calibrated drawings. Please create Calibration in Adoddle Web and try again.";

  static const String inProcess = "in process";
  static const String inQueue = "in queue";
  static const String failed = "Failed";
  static const String error = "Error";
  static const String checkBox = "checkBox";
  static const String completed = "completed";
  static const String latest = "latest";
  static const String superseded = "superseded";
  static const String ok = "ok";
  static const String models = "Model Files";
  static const String colorPicker = "Colour Picker";
  static const String itemTile = "itemTile";
  static const String resetLower = "reset";
  static const String revisionNotYetProcessed = "revision not yet processed";
  static const String reProcess = "failed. revision need to re-process again";

  static const String defaultFormStatusColor = "#848484";

  //side_tool_bar_screen
  static const String key_main_container = "key_main_container";
  static const String key_side_tool_bar_icons_column = "key_side_tool_bar_icons_column";
  static const String key_home = "key_home";
  static const String key_joystick = "key_joystick";
  static const String key_orbit = "key_orbit";
  static const String key_pdf = "key_pdf";
  static const String key_color_palette = "key_color_palette";
  static const String key_model = "key_model";
  static const String key_reset = "key_reset";
  static const String key_ruler_asset = "key_ruler_asset";
  static const String key_angle_asset = "key_angle_asset";
  static const String key_side_toolbar = "key_side_toolbar";
  static const String key_arrow_left = "key_arrow_left";
  static const String key_set_margin_container = "key_arrow_left";
  static const String key_edit_font = "key_edit_font";
  static const String key_free_hand_marker = "key_free_hand_marker";
  static const String key_plan_reset = "key_plan_reset";
  static const String key_arrow_left_marker = "key_arrow_left_marker";
  static const String key_slice_x = "key_slice_x";
  static const String key_slice_y = "key_slice_y";
  static const String key_slice_z = "key_slice_z";
  static const String key_show_slice = "key_show_slice";
  static const String key_inverse_slice = "key_inverse_slice";
  static const String key_hide_slice = "key_hide_slice";
  static const String key_arrow_left_cutting_plane = "key_arrow_left_cutting_plane";

  static const String ddmmyyyy = "dd/mm/yyyy";
  static const String dateFormatAssociation = "MMM dd, yyyy hh:mm:ss a";

  static const String pdf = "pdf";
  static const String bcf = "bcf";
  static const String csv = "csv";
  static const String jpeg = "jpeg";
  static const String jpg = "jpg";
  static const String png = "png";
  static const String ppsx = "ppsx";
  static const String pptm = "pptm";
  static const String pptx = "pptx";
  static const String rar = "rar";
  static const String rfa = "rfa";
  static const String rft = "rft";
  static const String rte = "rte";
  static const String rvt = "rvt";
  static const String ifc = "ifc";
  static const String vcf = "vcf";
  static const String xls = "xls";
  static const String zip = "zip";
  static const String numberHundredTen = "110";
  static const int maxThreadForMobileDevice = 3;
  static const String tempAttachmentZip = "temp_attach_zip";
  static const String logEmailId = "logbuddy@asite.com";
  static const String logPassword = "Logbuddy@1234";
  static const String logSessionId = "logger_session_id";
  static const String logProjId = '2137971';
  static const String live = r"104331877$$qdZhSp";
  static const String LIVE_ADODDLE_URL = 'https://adoddle.asite.com';
  static const String LIVE_COLLAB_URL = "https://dms.asite.com";
  static const String key_valid_name_regex = "[-0-9a-zA-Z _]";
}
