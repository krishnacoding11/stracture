import 'package:firebase_analytics/firebase_analytics.dart';

class ServiceAnalytics{
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  static fireEvent(String typeName, Map<String,dynamic> parameters) async{
    await analytics.logEvent(
      name: typeName,
      parameters: parameters,
    );
  }
  static doLogin()async{
    await analytics.logLogin();
  }
  static fireCurrentScreen(String name) async{
    await analytics.setCurrentScreen(screenName: name);
  }
  static fireUserProperties(Map<String,dynamic> parameters) async{
    await analytics.setUserId(id:  parameters["userId"]);
    await analytics.setUserProperty(name: "Name", value: parameters["name"]);
    await analytics.setUserProperty(name: "UserId", value: parameters["userId"]);
    await analytics.setUserProperty(name: "Organization", value: parameters["organizaton"]);
  }

}