import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/more_remote_datasource.dart';
import '../models/contact_us_model.dart';
import '../models/instructions_model.dart';
import '../models/privacy_policy_model.dart';

abstract class MoreRepository {
  Future<Either<Failure, ContactUsModel>> getContactInfo();
  Future<Either<Failure, InstructionsModel>> getInstructions();
  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy();
}

class MoreRepositoryImpl implements MoreRepository {
  final MoreRemoteDataSource remoteDataSource;

  MoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ContactUsModel>> getContactInfo() async {
    try {
      final contactInfo = await remoteDataSource.getContactInfo();
      return Right(contactInfo);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InstructionsModel>> getInstructions() async {
    try {
      final instructions = await remoteDataSource.getInstructions();
      return Right(instructions);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrivacyPolicyModel>> getPrivacyPolicy() async {
    try {
      final privacyPolicy = await remoteDataSource.getPrivacyPolicy();
      return Right(privacyPolicy);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
