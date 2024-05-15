import '../../model/model_vo.dart';

abstract class ModelListRepository {
}

class ModelListRemoteRepository extends ModelListRepository {
  ModelListRemoteRepository();

  List<Model>? modelListFromJson(dynamic response) {
    var modelList = List<Model>.from(response.map((x) => Model.fromJson(x)));

    List<Model> outputList =
        modelList;
    return outputList;
  }
}
