import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/local/site/site_local_repository.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/remote/dashboard/homepage_remote_repository_impl.dart';
import 'package:field/data/remote/formtype/formtype_repository_impl.dart';
import 'package:field/data/remote/project_list/project_list_repository_impl.dart';
import 'package:field/data/remote/site/site_remote_repository.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/data/remote/task_listing/tasklisting_repository_impl.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/domain/use_cases/dashboard/homepage_usecase.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/domain/use_cases/tasklisting/task_listing_usecase.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/sync_manager.dart';
import 'package:field/sync/sync_task_factory.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/file_utils.dart';
import 'package:get_it/get_it.dart';

import 'data/local/formtype/formtype_local_repository_impl.dart';
import 'data/local/homepage/homepage_local_repository_impl.dart';
import 'data/remote/Filter/filter_repositroy_impl.dart';
import 'data/remote/generic/generic_repository_impl.dart';
import 'data/remote/site/create_form_remote_repository.dart';
import 'database/db_service.dart';
import 'domain/repository/online_model_viewer_repository_impl.dart';
import 'domain/use_cases/Filter/filter_usecase.dart';
import 'domain/use_cases/formtype/formtype_use_case.dart';
import 'domain/use_cases/site/create_form_use_case.dart';
import 'domain/use_cases/site/site_use_case.dart';
import 'sync/calculation/site_form_listing_local_data_soruce.dart';

GetIt getIt = GetIt.instance;

Future<void> init({required bool test}) async {
  if (test == true) {
    _configureMockDependencies();
  }
  _configureDataSourceDependencies();
  _configureRepositoryDependencies();
  _configureBlocDependencies();
  _configureUseCaseDependencies();
  _configureOtherDependencies();

  getIt.registerLazySingleton<AppConfig>(() => AppConfig());
  getIt.registerLazySingleton(() => SyncManager());
  getIt.registerLazySingleton<FileUtility>(() => FileUtility());
  getIt.registerFactoryParam<DBService, String, void>((filePath, _) => DBService(filePath));
  getIt.registerLazySingleton(() => TaskPool(AConstants.maxThreadForMobileDevice));
}

void _configureOtherDependencies() {
  getIt.registerLazySingleton<SyncTaskFactory>(() => SyncTaskFactory());
}

Future<void> _configureDataSourceDependencies() async {
  getIt.registerLazySingleton<OnlineModelViewerRepositoryImpl>(() => OnlineModelViewerRepositoryImpl());
  getIt.registerLazySingleton<SiteFormListingLocalDataSource>(() => SiteFormListingLocalDataSource());
  getIt.registerLazySingleton<SiteLocationLocalDatasource>(() => SiteLocationLocalDatasource());
}

Future<void> _configureRepositoryDependencies() async {
  getIt.registerLazySingleton<ProjectListRemoteRepository>(() => ProjectListRemoteRepository());
  getIt.registerLazySingleton<SiteRemoteRepository>(() => SiteRemoteRepository());
  getIt.registerLazySingleton<SiteLocalRepository>(() => SiteLocalRepository());
  getIt.registerLazySingleton<SiteTaskRemoteRepository>(() => SiteTaskRemoteRepository());
  getIt.registerLazySingleton<SiteTaskLocalRepository>(() => SiteTaskLocalRepository());
  getIt.registerLazySingleton<TaskListingRemoteRepository>(() => TaskListingRemoteRepository());
  getIt.registerLazySingleton<ProjectListLocalRepository>(() => ProjectListLocalRepository());
  getIt.registerLazySingleton<FormTypeRemoteRepository>(() => FormTypeRemoteRepository());
  getIt.registerLazySingleton<FormTypeLocalRepository>(() => FormTypeLocalRepository());
  getIt.registerLazySingleton<CreateFormRemoteRepository>(() => CreateFormRemoteRepository());
  getIt.registerLazySingleton<FilterRemoteRepository>(() => FilterRemoteRepository());
  getIt.registerLazySingleton<GenericRemoteRepository>(() => GenericRemoteRepository());
  getIt.registerLazySingleton<HomePageLocalRepository>(() => HomePageLocalRepository());
  getIt.registerLazySingleton<HomePageRemoteRepository>(() => HomePageRemoteRepository());
}

Future<void> _configureBlocDependencies() async {
  getIt.registerFactory<TaskListingCubit>(() => TaskListingCubit());
  getIt.registerFactory(() => SiteTaskCubit());
  getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
  getIt.registerLazySingleton<SyncCubit>(() => SyncCubit());
  getIt.registerLazySingleton<ProjectListCubit>(() => ProjectListCubit());
  getIt.registerLazySingleton<FilterCubit>(() => FilterCubit());
}

Future<void> _configureUseCaseDependencies() async {
  getIt.registerLazySingleton<ProjectListUseCase>(() => ProjectListUseCase());
  getIt.registerLazySingleton<SiteTaskUseCase>(() => SiteTaskUseCase());
  getIt.registerLazySingleton<TaskListingUseCase>(() => TaskListingUseCase());
  getIt.registerLazySingleton<SiteUseCase>(() => SiteUseCase());
  getIt.registerLazySingleton<FilterUseCase>(() => FilterUseCase());
  getIt.registerLazySingleton<CreateFormUseCase>(() => CreateFormUseCase());
  getIt.registerLazySingleton<FormTypeUseCase>(() => FormTypeUseCase());
  getIt.registerLazySingleton<HomePageUseCase>(() => HomePageUseCase());
}

Future<void> _configureMockDependencies() async {}
