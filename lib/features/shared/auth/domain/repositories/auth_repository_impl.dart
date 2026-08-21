import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/login_success.dart';
import '../../data/models/lawyer_registration_models.dart';
import '../../data/models/registratoin_success.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LoginResult>> login(String email, String password, {bool isLawyer = false}) async {
    try {
      final user = await remoteDataSource.login(email, password, isLawyer: isLawyer);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String accountType,
    required bool termsAccepted,
    required String role,
    String? referralCode,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        accountType: accountType,
        termsAccepted: termsAccepted,
        registerAs: role,
        referralCode: referralCode,
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String phone, required String otpCode, required String password}) async {
    try {
      await remoteDataSource.resetPassword(phone: phone, otpCode: otpCode, password: password);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginResult>> verifyOtp(String phone, String otp, {bool isLawyer = false}) async {
    try {
      final result = await remoteDataSource.verifyOtp(phone, otp, isLawyer: isLawyer);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp(String phone, String type, {bool isLawyer = false}) async {
    try {
      await remoteDataSource.resendOtp(phone, type, isLawyer: isLawyer);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateToken(String fcmToken) async {
    try {
      await remoteDataSource.updateToken(fcmToken);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProviderTypeModel>>> getLawyerProviderTypes() async {
    try {
      final data = await remoteDataSource.getLawyerProviderTypes();
      return Right(data);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LegalSpecializationModel>>> getLawyerSpecializations() async {
    try {
      final data = await remoteDataSource.getLawyerSpecializations();
      return Right(data);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final data = await remoteDataSource.registerLawyer(
        name: name,
        phone: phone,
        email: email,
        password: password,
        civilId: civilId,
        city: city,
        level: level,
        experienceYears: experienceYears,
        providerTypeId: providerTypeId,
        specializationIds: specializationIds,
        imagePath: imagePath,
      );
      return Right(data);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerProfileCompletionResult>> completeLawyerProfile({
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final data = await remoteDataSource.completeLawyerProfile(metadata: metadata);
      return Right(data);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
