import 'model_vo.dart';
import 'online_model_viewer_request_model.dart';

class OnlineModelViewerArguments {
  bool isShowSideToolBar;
  String projectId;
  Model model;
  OnlineViewerModelRequestModel onlineViewerModelRequestModel;
  Map<String, dynamic>? offlineParams;

  OnlineModelViewerArguments({
    required this.projectId,
    required this.isShowSideToolBar,
    required this.onlineViewerModelRequestModel,
    required this.offlineParams,
    required this.model,
  });

  factory OnlineModelViewerArguments.fromJson(Map<String, dynamic> json) => OnlineModelViewerArguments(
    projectId: json["projectId"],
    isShowSideToolBar: json["isShowSideToolBar"],
    onlineViewerModelRequestModel: json["onlineViewerModelRequestModel"],
    offlineParams: json["offlineParams"],
    model: json["model"],
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "isShowSideToolBar": isShowSideToolBar,
    "onlineViewerModelRequestModel": onlineViewerModelRequestModel,
    "offlineParams": offlineParams,
    "model": model,
  };
}
