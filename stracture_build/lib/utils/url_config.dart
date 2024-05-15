import 'package:field/utils/constants.dart';
import 'package:field/utils/url_helper.dart';

enum UrlType {
  adoddle("Adoddle"),
  task("Task"),
  shared("Shared"),
  download("Download"),
  collab("Collab"),
  messanger("Messanger"),
  streamingServer("streamingServer");

  const UrlType(this.text);

  final String text;
}

enum BuildEnvironment {
  qa("QA"),
  live("live"),
  staging("staging"),
  development("development");

  const BuildEnvironment(this.buildEnvironmentName);

  final String buildEnvironmentName;
}

class URLConfig {
  Future<String> getAdoddleUrl() => Future.value("");

  Future<String> getCollabUrl() => Future.value("");

  Future<String> getTaskUrl() => Future.value("");

  Future<String> getDownloadUrl() => Future.value("");

  Future<String> getStreamingServerUrl() => Future.value("");

  String getOAuthUrl() => "";

  factory URLConfig(int cloud, BuildEnvironment environment, int dcId) {
    switch (cloud) {
      case 1:
        switch (environment) {
          case BuildEnvironment.live:
            return LiveURLConfig(dcId);
          case BuildEnvironment.qa:
            return QaURLConfig(dcId);
          case BuildEnvironment.development:
            return DevURLConfig(dcId);
          case BuildEnvironment.staging:
            break;
        }
        return QaURLConfig(dcId);
      // return environment == BuildEnvironment.live
      //     ? LiveURLConfig(dcId)
      //     : QaURLConfig(dcId);
      case 2:
        return STGURLConfig();
      case 3:
        return SBURLConfig();
      case 4:
        return LiveURLConfig(dcId);
      case 5:
        return MTAURLConfig();
      case 6:
        return UAEURLConfig();
      case 7:
        return KSAURLConfig();
      case 8:
        return CanadaURLConfig();
      case 9:
        return HongKongURLConfig();
      default:
        switch (environment) {
          case BuildEnvironment.qa:
          case BuildEnvironment.development:
            return QaURLConfig(dcId);
          case BuildEnvironment.staging:
            return STGURLConfig();
          case BuildEnvironment.live:
            return LiveURLConfig(dcId);
        }
    }
  }
}

class QaURLConfig implements URLConfig {
  int dcId = 1;

  QaURLConfig(this.dcId);

  @override
  Future<String> getAdoddleUrl() async {
    String url = await UrlHelper.getUrl(UrlType.adoddle, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    return dcId == 2 ? Future.value("https://adoddleqab.asite.com") : Future.value("https://adoddleqaak.asite.com");
  }

  @override
  Future<String> getCollabUrl() async {
    String url = await UrlHelper.getUrl(UrlType.collab, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    return dcId == 2 ? Future.value("https://dmsqab.asite.com") : Future.value("https://dmsqaak.asite.com");
  }

  @override
  Future<String> getTaskUrl() async {
    String url = await UrlHelper.getUrl(UrlType.task, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    return dcId == 2 ? Future.value("https://taskqab.asite.com") : Future.value("https://taskqaak.asite.com");
  }

  @override
  Future<String> getDownloadUrl() async {
    String url = await UrlHelper.getUrl(UrlType.download, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    return dcId == 2 ? Future.value("https://syncqab.asite.com") : Future.value("https://syncqaak.asite.com");
  }

  @override
  Future<String> getStreamingServerUrl() async {
    String url = await UrlHelper.getUrl(UrlType.streamingServer, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    return dcId == 2 ? Future.value("wss://3dviewerqab.asite.com/") : Future.value("wss://3dviewerqaak.asite.com/");
  }

  @override
  String getOAuthUrl() {
    return AConstants.oauthUrl;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DevURLConfig implements URLConfig {
  int dcId = 1;

  DevURLConfig(this.dcId);

  @override
  Future<String> getAdoddleUrl() async {
    return Future.value("https://adoddledev.asite.com");
  }

  @override
  Future<String> getCollabUrl() async {
    return Future.value("https://dmsdev.asite.com");
  }

  @override
  Future<String> getTaskUrl() async {
    return Future.value("https://taskdev.asite.com");
  }

  @override
  Future<String> getDownloadUrl() async {
    return Future.value("https://syncdev.asite.com");
  }

  @override
  Future<String> getStreamingServerUrl() async {
    return Future.value("wss://3dviewerdev.asite.com/");
  }

  @override
  String getOAuthUrl() {
    return "https://oauthdev.asite.com";
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SBURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddlesb.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmssb.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://tasksb.asite.com");

  @override
  String getOAuthUrl() => "https://oauthsb.asite.com";

  @override
  Future<String> getDownloadUrl() => Future.value("https://syncsb.asite.com");

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewersb.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class STGURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddlestg.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmsstg.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskstg.asite.com");

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewerstg.asite.com/");

  @override
  String getOAuthUrl() => "https://oauthstg.asite.com";

  @override
  Future<String> getDownloadUrl() => Future.value("https://syncstg.asite.com");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UAEURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddleuae.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmsuae.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskuae.asite.com");

  @override
  String getOAuthUrl() => "https://oauthuae.asite.com";

  @override
  Future<String> getDownloadUrl() => Future.value("https://syncuae.asite.com");

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dvieweruae.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MTAURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddleusgov.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmsusgov.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskusgov.asite.com");

  @override
  String getOAuthUrl() => "https://oauthusgov.asite.com";

  @override
  Future<String> getDownloadUrl() => Future.value("https://syncusgov.asite.com");

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewerusgov.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CanadaURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddleh.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmsh.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskh.asite.com");

  @override
  String getOAuthUrl() => "https://oauthh.asite.com";

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewerh.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class HongKongURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddlehk.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmshk.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskhk.asite.com");

  @override
  String getOAuthUrl() => "https://oauthhk.asite.com";

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewerhk.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class KSAURLConfig implements URLConfig {
  @override
  Future<String> getAdoddleUrl() => Future.value("https://adoddleksa.asite.com");

  @override
  Future<String> getCollabUrl() => Future.value("https://dmsksa.asite.com");

  @override
  Future<String> getTaskUrl() => Future.value("https://taskksa.asite.com");

  @override
  String getOAuthUrl() => "https://oauthksa.asite.com";

  @override
  Future<String> getDownloadUrl() => Future.value("https://syncksa.asite.com");

  @override
  Future<String> getStreamingServerUrl() => Future.value("wss://3dviewerksa.asite.com/");

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class LiveURLConfig implements URLConfig {
  int dcId = 1;

  LiveURLConfig(this.dcId);

  @override
  Future<String> getAdoddleUrl() async {
    String url = await UrlHelper.getUrl(UrlType.adoddle, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    switch (dcId) {
      case 1:
        return Future.value("https://adoddleak.asite.com");
      case 2:
        return Future.value("https://adoddleb.asite.com");
      case 3:
        return Future.value("https://adoddled.asite.com");
      case 4:
        return Future.value("https://adoddlef.asite.com");
      default:
        return Future.value("https://adoddleak.asite.com");
    }
  }

  @override
  Future<String> getCollabUrl() async {
    String url = await UrlHelper.getUrl(UrlType.collab, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    switch (dcId) {
      case 1:
        return Future.value("https://dmsak.asite.com");
      case 2:
        return Future.value("https://dmsb.asite.com");
      case 3:
        return Future.value("https://dmsd.asite.com");
      case 4:
        return Future.value("https://dmsf.asite.com");
      default:
        return Future.value("https://dmsak.asite.com");
    }
  }

  @override
  Future<String> getTaskUrl() async {
    String url = await UrlHelper.getUrl(UrlType.task, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    switch (dcId) {
      case 1:
        return Future.value("https://taskak.asite.com");
      case 2:
        return Future.value("https://taskb.asite.com");
      case 3:
        return Future.value("https://taskd.asite.com");
      case 4:
        return Future.value("https://taskf.asite.com");
      default:
        return Future.value("https://taskak.asite.com");
    }
  }

  @override
  Future<String> getStreamingServerUrl() async {
    String url = await UrlHelper.getUrl(UrlType.streamingServer, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    switch (dcId) {
      case 1:
        return Future.value("wss://3dviewerak.asite.com/");
      case 2:
        return Future.value("wss://3dviewerb.asite.com/");
      case 3:
        return Future.value("wss://3dviewerd.asite.com/");
      case 4:
        return Future.value("wss://3dviewerf.asite.com/");
      default:
        return Future.value("wss://3dviewerak.asite.com/");
    }
  }

  @override
  Future<String> getDownloadUrl() async {
    String url = await UrlHelper.getUrl(UrlType.download, dcId);
    if (url.isNotEmpty) {
      return url;
    }
    switch (dcId) {
      case 1:
        return Future.value("https://syncak.asite.com");
      case 2:
        return Future.value("https://syncb.asite.com");
      case 3:
        return Future.value("https://syncd.asite.com");
      case 4:
        return Future.value("https://syncf.asite.com");
      default:
        return Future.value("https://syncak.asite.com");
    }
  }

  @override
  String getOAuthUrl() => AConstants.oauthUrl;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
