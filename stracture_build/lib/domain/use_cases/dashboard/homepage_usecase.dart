import 'package:field/data/local/homepage/homepage_local_repository_impl.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';

import '../../../data/remote/dashboard/homepage_remote_repository_impl.dart';
import '../../../data/repository/dashboard/homepage_repository.dart';
import '../../../networking/network_info.dart';

class HomePageUseCase extends BaseUseCase<HomePageRepository> {
  HomePageRepository? _homePageRepository;

  Future<Result?> getShortcutConfigList(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _homePageRepository!.getShortcutConfigList(request);
    if (result is SUCCESS && result.data != null) {
      result.data = currentAvailableCategoryItems(result.data);
    }
    return result;
  }

  Future<Result?> getPendingShortcutConfigList(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _homePageRepository!.getPendingShortcutConfigList(request);
    if (result is SUCCESS && result.data != null) {
      result.data = currentAvailableCategoryItems(result.data);
    }
    return result;
  }

  HomePageModel currentAvailableCategoryItems(HomePageModel homePageModel) {
    homePageModel.configJsonData?.userProjectConfigTabsDetails?.removeWhere((element) => HomePageSortCutCategory.fromString(element.id.toString()) == HomePageSortCutCategory.undefineCategory);
    return homePageModel;
  }

  Future<Result?>? updateShortcutConfigList(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _homePageRepository!.updateShortcutConfigList(request);
    return result;
  }

  @override
  Future<HomePageRepository?> getInstance() async {
    if (isNetWorkConnected()) {
      _homePageRepository = di.getIt<HomePageRemoteRepository>();
      return _homePageRepository;
    } else {
      _homePageRepository = di.getIt<HomePageLocalRepository>();
      return _homePageRepository;
    }
  }
}
