import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/bloc/audio/audio_cubit.dart';
import 'package:field/bloc/bim_model_list/bim_project_model_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/bloc/deeplink/deeplink_cubit.dart';
import 'package:field/bloc/formsetting/form_settings_change_event_cubit.dart';
import 'package:field/bloc/image_annotation/image_annotation_cubit.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/notification/notification_cubit.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/online_model_viewer/task_form_list_cubit.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/bloc/quality/quality_plan_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/sidebar/sidebar_cubit.dart';
import 'package:field/bloc/site/create_form_cubit.dart';
import 'package:field/bloc/site/location_tree_cubit.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sitetask/toggle_cubit.dart';
import 'package:field/bloc/sitetask/unique_value_cubit.dart';
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/bloc/toolbar/model_tree_title_click_event_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_offline_cubit.dart';
import 'package:field/bloc/view_file_association/view_file_association_cubit.dart';
import 'package:field/bloc/view_object_details/view_object_details_cubit.dart';
import 'package:field/bloc/web_view/web_view_cubit.dart';
import 'package:field/data/local/Filter/filter_local_repository_impl.dart';
import 'package:field/data/local/cbim_settings/cbim_settings_local_data_source_impl.dart';
import 'package:field/data/local/formtype/formtype_local_repository_impl.dart';
import 'package:field/data/local/login/login_local_repository.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/local/qr/qr_local_repository_impl.dart';
import 'package:field/data/local/site/create_form_local_repository.dart';
import 'package:field/data/local/site/site_local_repository.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/local/task_action_count/taskactioncount_local_repository_impl.dart';
import 'package:field/data/local/userprofilesetting/userprofilesetting_local_repository_impl.dart';
import 'package:field/data/remote/Filter/filter_repositroy_impl.dart';
import 'package:field/data/remote/bim_model_list/bim_project_model_repository.dart';
import 'package:field/data/remote/formtype/formtype_repository_impl.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/data/remote/login/login_repository_impl.dart';
import 'package:field/data/remote/project_list/project_list_repository_impl.dart';
import 'package:field/data/remote/qr/qr_repository_impl.dart';
import 'package:field/data/remote/quality/quality_plan_listing_repository_impl.dart';
import 'package:field/data/remote/site/create_form_remote_repository.dart';
import 'package:field/data/remote/site/site_remote_repository.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/data/remote/task_action_count/taskactioncount_repository_impl.dart';
import 'package:field/data/remote/task_listing/tasklisting_repository_impl.dart';
import 'package:field/data/remote/upload/upload_repository_impl.dart';
import 'package:field/data/remote/userprofilesetting/userprofilesetting_repository_impl.dart';
import 'package:field/data_source/bim_project_model_data_source/bim_project_model_local_data_source_impl.dart';
import 'package:field/data_source/bim_project_model_data_source/bim_project_model_remote_data_source_impl.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/data_source/task_form_list_data_source/task_form_list_local_data_source_impl.dart';
import 'package:field/data_source/task_form_list_data_source/task_form_list_remote_data_source_impl.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/domain/use_cases/bim_model_list_use_cases/bim_project_model_use_case.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/domain/use_cases/model_list_use_case/model_list_use_case.dart';
import 'package:field/domain/use_cases/online_model_vewer_use_case.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/domain/use_cases/task_action_count/task_action_count_usecase.dart';
import 'package:field/domain/use_cases/tasklisting/task_listing_usecase.dart';
import 'package:field/domain/use_cases/upload/upload_usecase.dart';
import 'package:field/domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import 'package:field/firebase/notification_service.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/presentation/navigation/field_navigator.dart';
import 'package:field/sync/sync_manager.dart';
import 'package:field/sync/sync_task_factory.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/widgets/app_permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../bloc/custom_search_view/custom_search_view_cubit.dart';
import '../bloc/image_annotation/annotation_selection_cubit.dart';
import '../bloc/navigation/navigation_cubit.dart';
import '../bloc/password/password_cubit.dart';
import '../bloc/site/create_form_selection_cubit.dart';
import '../bloc/toolbar/toolbar_cubit.dart';
import '../bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import '../data_source/model_list_data_source/model_list_local_data_source_impl.dart';
import '../data_source/model_list_data_source/model_list_remote_data_source_impl.dart';
import 'bloc/cBim_settings/cBim_settings_cubit.dart';
import 'bloc/dashboard/home_page_cubit.dart';
import 'bloc/download_size/download_size_cubit.dart';
import 'bloc/image_sequence/image_sequence_cubit.dart';
import 'bloc/language_change/language_change_cubit.dart';
import 'data/local/homepage/homepage_local_repository_impl.dart';
import 'data/remote/dashboard/homepage_remote_repository_impl.dart';
import 'data/remote/download_size/download_size_repositroy_impl.dart';
import 'data/remote/notification/notification_repository_impl.dart';
import 'database/db_service.dart';
import 'domain/repository/online_model_viewer_repository_impl.dart';
import 'domain/use_cases/cBim_settings/cBim_setting_use_case.dart';
import 'domain/use_cases/dashboard/homepage_usecase.dart';
import 'domain/use_cases/download_size/download_size_usecase.dart';
import 'domain/use_cases/notification/notification_usecase.dart';
import 'domain/use_cases/task_form_listing/task_form_use_case.dart';
import 'sync/calculation/site_form_listing_local_data_soruce.dart';

GetIt getIt = GetIt.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = NotificationService.flutterLocalNotificationsPlugin;

Future<void> init({required bool test}) async {
  if (test == true) {
    _configureMockDependencies();
  }
  _configureDataSourceDependencies();
  _configureRepositoryDependencies();
  _configureBlocDependencies();
  _configureUseCaseDependencies();
  _configureQrCodeDependencies();
  _configureOtherDependencies();

  getIt.registerLazySingleton<ScrollController>(() => ScrollController());
  getIt.registerLazySingleton<AppConfig>(() => AppConfig());
  getIt.registerLazySingleton(() => SyncManager());
  getIt.registerLazySingleton<FileUtility>(() => FileUtility());
  getIt.registerFactoryParam<DBService,String,void>((filePath,_) => DBService(filePath));
}

void _configureOtherDependencies() {
  getIt.registerLazySingleton<SyncTaskFactory>(() => SyncTaskFactory());
}

Future<void> _configureDataSourceDependencies() async {
  getIt.registerLazySingleton<ModelListRemoteDataSourceImpl>(() => ModelListRemoteDataSourceImpl());
  getIt.registerLazySingleton<ModelListLocalDataSourceImpl>(() => ModelListLocalDataSourceImpl());
  getIt.registerLazySingleton<TaskFormListLocalDataSourceImpl>(() => TaskFormListLocalDataSourceImpl());
  getIt.registerLazySingleton<TaskFormListRemoteDataSourceImpl>(() => TaskFormListRemoteDataSourceImpl());
  getIt.registerLazySingleton<CbimSettingsLocalDataSourceImpl>(() => CbimSettingsLocalDataSourceImpl());
  getIt.registerLazySingleton<BimProjectModelListLocalDataSourceImpl>(() => BimProjectModelListLocalDataSourceImpl());
  getIt.registerLazySingleton<BimProjectModelListRemoteDataSourceImpl>(() => BimProjectModelListRemoteDataSourceImpl());
  getIt.registerLazySingleton<OnlineModelViewerRepositoryImpl>(() => OnlineModelViewerRepositoryImpl());
  getIt.registerLazySingleton<SiteFormListingLocalDataSource>(() => SiteFormListingLocalDataSource());
  getIt.registerLazySingleton<SiteLocationLocalDatasource>(() => SiteLocationLocalDatasource());
}

Future<void> _configureRepositoryDependencies() async {
  getIt.registerLazySingleton<LogInLocalRepository>(() => LogInLocalRepository());
  getIt.registerLazySingleton<LogInRemoteRepository>(() => LogInRemoteRepository());
  getIt.registerLazySingleton<HomePageRemoteRepository>(() => HomePageRemoteRepository());
  getIt.registerLazySingleton<ProjectListRemoteRepository>(() => ProjectListRemoteRepository());
  getIt.registerLazySingleton<ProjectListLocalRepository>(() => ProjectListLocalRepository());
  getIt.registerLazySingleton<SiteRemoteRepository>(() => SiteRemoteRepository());
  getIt.registerLazySingleton<SiteLocalRepository>(() => SiteLocalRepository());
  getIt.registerLazySingleton<FilterRemoteRepository>(() => FilterRemoteRepository());
  getIt.registerLazySingleton<FilterLocalRepository>(() => FilterLocalRepository());
  getIt.registerLazySingleton<UserProfileSettingRemoteRepository>(() => UserProfileSettingRemoteRepository());
  getIt.registerLazySingleton<UserProfileSettingLocalRepository>(() => UserProfileSettingLocalRepository());
  getIt.registerLazySingleton<QRRemoteRepository>(() => QRRemoteRepository());
  getIt.registerLazySingleton<QRLocalRepository>(() => QRLocalRepository());
  getIt.registerLazySingleton<CreateFormRemoteRepository>(() => CreateFormRemoteRepository());
  getIt.registerLazySingleton<CreateFormLocalRepository>(() => CreateFormLocalRepository());
  getIt.registerLazySingleton<GenericRemoteRepository>(() => GenericRemoteRepository());
  getIt.registerLazySingleton<SiteTaskRemoteRepository>(() => SiteTaskRemoteRepository());
  getIt.registerLazySingleton<SiteTaskLocalRepository>(() => SiteTaskLocalRepository());
  getIt.registerLazySingleton<TaskActionCountRemoteRepository>(() => TaskActionCountRemoteRepository());
  getIt.registerLazySingleton<TaskActionCountLocalRepository>(() => TaskActionCountLocalRepository());
  getIt.registerLazySingleton<BimProjectModelListRemoteRepository>(() => BimProjectModelListRemoteRepository());
  getIt.registerLazySingleton<TaskListingRemoteRepository>(() => TaskListingRemoteRepository());
  getIt.registerLazySingleton<QualityPlanListingRemoteRepository>(() => QualityPlanListingRemoteRepository());
  getIt.registerLazySingleton<NotificationRemoteRepository>(() => NotificationRemoteRepository());
  getIt.registerLazySingleton<UploadRemoteRepository>(() => UploadRemoteRepository());
  getIt.registerLazySingleton<FormTypeRemoteRepository>(() => FormTypeRemoteRepository());
  getIt.registerLazySingleton<FormTypeLocalRepository>(() => FormTypeLocalRepository());
  getIt.registerLazySingleton<DownloadSizeRepository>(() => DownloadSizeRepository());
  getIt.registerLazySingleton<HomePageLocalRepository>(() => HomePageLocalRepository());

}

Future<void> _configureBlocDependencies() async {
  //registerFactory will create a new instance everytime on call of getIt<LoginCubit>()
  getIt.registerLazySingleton<LoginCubit>(() => LoginCubit());
  getIt.registerLazySingleton<RecentLocationCubit>(() => RecentLocationCubit());
  getIt.registerFactory<CreateFormCubit>(() => CreateFormCubit());
  getIt.registerLazySingleton<ProjectListCubit>(() => ProjectListCubit());
  getIt.registerLazySingleton<BimProjectModelListCubit>(() => BimProjectModelListCubit());
  getIt.registerLazySingleton<SidebarCubit>(() => SidebarCubit());
  getIt.registerLazySingleton<TaskActionCountCubit>(() => TaskActionCountCubit());
  getIt.registerLazySingleton<FormSettingsChangeEventCubit>(() => FormSettingsChangeEventCubit());
  getIt.registerLazySingleton<CBIMSettingsCubit>(() => CBIMSettingsCubit(PageInitialState()));
  getIt.registerFactory<UserProfileSettingCubit>(() => UserProfileSettingCubit());
  getIt.registerFactory<UserProfileSettingOfflineCubit>(() => UserProfileSettingOfflineCubit());
  getIt.registerLazySingleton<DeepLinkCubit>(() => DeepLinkCubit());
  getIt.registerFactory<PlanCubit>(() => PlanCubit());
  getIt.registerFactory<LocationTreeCubit>(() => LocationTreeCubit());
  getIt.registerFactory<PasswordCubit>(() => PasswordCubit());
  getIt.registerFactory<ViewObjectDetailsCubit>(() => ViewObjectDetailsCubit());
  getIt.registerFactory<FileAssociationCubit>(() => FileAssociationCubit());
  getIt.registerFactory<AnnotationSelectionCubit>(() => AnnotationSelectionCubit());
  getIt.registerLazySingleton<PermissionHandlerPermissionService>(() => PermissionHandlerPermissionService());
  getIt.registerLazySingleton<ModelListCubit>(() => ModelListCubit());
  getIt.registerLazySingleton<StorageDetailsCubit>(() => StorageDetailsCubit());
  getIt.registerLazySingleton<OnlineModelViewerCubit>(() => OnlineModelViewerCubit());
  getIt.registerLazySingleton<ModelTreeCubit>(() => ModelTreeCubit());
  getIt.registerLazySingleton<NavigationCubit>(() => NavigationCubit());
  getIt.registerLazySingleton<SideToolBarCubit>(() => SideToolBarCubit());
  getIt.registerLazySingleton<TaskFormListingCubit>(() => TaskFormListingCubit());
  getIt.registerLazySingleton<PdfTronCubit>(() => PdfTronCubit());
  getIt.registerFactory<FilterCubit>(() => FilterCubit());
  getIt.registerFactory(() => FieldNavigatorCubit());
  getIt.registerLazySingleton<ToolbarCubit>(() => ToolbarCubit());
  getIt.registerFactory<ACameraCubit>(() => ACameraCubit());
  getIt.registerFactory<AudioCubit>(() => AudioCubit());
  getIt.registerFactory<UserFirstLoginSetupCubit>(() => UserFirstLoginSetupCubit());
  getIt.registerLazySingleton<ToolbarTitleClickEventCubit>(() => ToolbarTitleClickEventCubit());
  getIt.registerLazySingleton<ModelTreeTitleClickEventCubit>(() => ModelTreeTitleClickEventCubit());
  getIt.registerFactory<TaskListingCubit>(() => TaskListingCubit());
  getIt.registerFactory<QualityPlanListingCubit>(() => QualityPlanListingCubit());
  getIt.registerFactory(() => SiteTaskCubit());
  getIt.registerFactory(() => CreateFormSelectionCubit());
  getIt.registerFactory<WebViewCubit>(() => WebViewCubit());
  getIt.registerFactory(() => ImageAnnotationCubit());
  getIt.registerFactory<ToggleCubit>(() => ToggleCubit());
  getIt.registerFactory<UniqueValueCubit>(() => UniqueValueCubit());
  getIt.registerFactory<CustomSearchViewCubit>(() => CustomSearchViewCubit());
  getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
  getIt.registerFactory<QualityPlanLocationListingCubit>(() => QualityPlanLocationListingCubit());
  getIt.registerLazySingleton<SyncCubit>(() => SyncCubit());
  getIt.registerLazySingleton<ProjectItemCubit>(() => ProjectItemCubit());
  getIt.registerFactory<ImageSequenceCubit>(() => ImageSequenceCubit());
  getIt.registerLazySingleton<NotificationCubit>(() => NotificationCubit());
  getIt.registerFactory<DownloadSizeCubit>(() => DownloadSizeCubit());
  getIt.registerLazySingleton<LanguageChangeCubit>(() => LanguageChangeCubit());
  getIt.registerFactory<HomePageCubit>(() => HomePageCubit());
}

Future<void> _configureUseCaseDependencies() async {
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase());
  getIt.registerLazySingleton<HomePageUseCase>(() => HomePageUseCase());
  getIt.registerLazySingleton<QrUseCase>(() => QrUseCase());
  getIt.registerLazySingleton<CreateFormUseCase>(() => CreateFormUseCase());
  getIt.registerLazySingleton<ProjectListUseCase>(() => ProjectListUseCase());
  getIt.registerLazySingleton<SiteUseCase>(() => SiteUseCase());
  getIt.registerLazySingleton<FilterUseCase>(() => FilterUseCase());
  getIt.registerLazySingleton<ModelListUseCase>(() => ModelListUseCase());
  getIt.registerLazySingleton<CBimSettingUseCase>(() => CBimSettingUseCase());
  getIt.registerLazySingleton<OnlineModelViewerUseCase>(() => OnlineModelViewerUseCase());
  getIt.registerLazySingleton<BimProjectModelListUseCase>(() => BimProjectModelListUseCase());
  getIt.registerLazySingleton<UserProfileSettingUseCase>(() => UserProfileSettingUseCase());
  getIt.registerLazySingleton<SiteTaskUseCase>(() => SiteTaskUseCase());
  getIt.registerLazySingleton<TaskActionCountUseCase>(() => TaskActionCountUseCase());
  getIt.registerLazySingleton<TaskListingUseCase>(() => TaskListingUseCase());
  getIt.registerLazySingleton<TaskFormListingUseCase>(() => TaskFormListingUseCase());
  getIt.registerLazySingleton<QualityPlanListingUseCase>(() => QualityPlanListingUseCase());
  getIt.registerLazySingleton<NotificationUseCase>(() => NotificationUseCase());
  getIt.registerLazySingleton<UploadUseCase>(() => UploadUseCase());
  getIt.registerLazySingleton<FormTypeUseCase>(() => FormTypeUseCase());
  getIt.registerLazySingleton<DownloadSizeUseCase>(() => DownloadSizeUseCase());
}

Future<void> _configureQrCodeDependencies() async {
  getIt.registerFactory(() => FieldNavigator());
}

Future<void> _configureMockDependencies() async {}
