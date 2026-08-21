import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../data/models/login_success.dart';
import '../../data/models/lawyer_registration_models.dart';
import '../../data/models/registratoin_success.dart';


abstract class AuthRepository {
  Future<Either<Failure, LoginResult>> login(String email, String password, {bool isLawyer = false});
  Future<Either<Failure, RegisterResult>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
    required bool termsAccepted,
    required String role,
    String? referralCode,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resetPassword({required String phone, required String otpCode, required String password});
  Future<Either<Failure, LoginResult>> verifyOtp(String phone, String otp, {bool isLawyer = false});
  Future<Either<Failure, void>> resendOtp(String phone, String type, {bool isLawyer = false});
  Future<Either<Failure, List<ProviderTypeModel>>> getLawyerProviderTypes();
  Future<Either<Failure, List<LegalSpecializationModel>>> getLawyerSpecializations();
  Future<Either<Failure, LawyerRegistrationDraft>> registerLawyer({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String civilId,
    required String city,
    required String level,
    required String experienceYears,
    required int providerTypeId,
    required List<int> specializationIds,
    required String imagePath,
  });
  Future<Either<Failure, LawyerProfileCompletionResult>> completeLawyerProfile({
    required Map<String, dynamic> metadata,
  });
  Future<Either<Failure, void>> updateToken(String fcmToken);
  // Future<Either<Failure, UserModel>> getCurrentUser();
}
