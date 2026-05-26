import 'package:hogga/features/shared/auth/data/models/user_model.dart';

sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final UserModel user;
  LoginSuccess(this.user);
}

class LoginNeedVerification extends LoginResult {
  final String email;
  LoginNeedVerification(this.email);
}

class OtpVerified extends LoginResult {
  OtpVerified();
}
