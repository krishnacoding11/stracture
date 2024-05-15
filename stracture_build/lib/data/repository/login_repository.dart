
enum AuthenticationStatus { unknown, authenticated, unauthenticated , inProgress}

abstract class LogInRepository<REQUEST,RESPONSE> {
   Future<RESPONSE?>? doLogin(Map<String, dynamic> request);
   Future<RESPONSE?>? login2FA(Map<String,dynamic> request);
   Future<RESPONSE?>? getUserSSODetails(Map<String,dynamic> request);
}