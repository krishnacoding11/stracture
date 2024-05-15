import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/login/login_state.dart';

class PasswordCubit extends BaseCubit {
  bool _obscureText = true;

  PasswordCubit() : super(LoginPasswordToggle(true));

  togglePasswordVisibility() {
    _obscureText = !_obscureText;
    emitState(LoginPasswordToggle(_obscureText));
  }
}