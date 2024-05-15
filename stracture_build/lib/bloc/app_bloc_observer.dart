import 'package:field/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    loggerNoStack.d('BlocObserver: onCreate Bloc-- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    loggerNoStack.d('BlocObserver: onChange Bloc type-- ${bloc.runtimeType}');
    loggerNoStack.d('BlocObserver: onChange Bloc CurrentState-- ${change.currentState} ');
    loggerNoStack.d('BlocObserver: onChange Bloc NextState-- ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    loggerNoStack.d('BlocObserver: onError Bloc-- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    loggerNoStack.d('BlocObserver== onClose Bloc-- ${bloc.runtimeType}');
  }
}
