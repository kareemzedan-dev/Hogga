import 'package:hogga/features/shared/auth/data/models/user_model.dart';

sealed class RegisterResult {}
class RegisterSuccess extends RegisterResult {
  final UserModel user;
  RegisterSuccess(this.user);
}

class RegisterNeedVerification extends RegisterResult {
  final String email;
  RegisterNeedVerification(this.email);
}
