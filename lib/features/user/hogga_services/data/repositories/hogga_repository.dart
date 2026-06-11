import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/bainah_remote_datasource.dart';
import '../models/item_category_model.dart';
import '../models/legal_case_models.dart';

abstract class hoggaRepository {
  Future<Either<Failure, ItemCategoryModel>> getItemCategories(int childCategoryId);
  Future<Either<Failure, CouponVerificationModel>> verifyCoupon(String code);
  Future<Either<Failure, LegalCaseResponse>> createLegalCase(CreateLegalCaseRequest request);
  Future<Either<Failure, LegalCaseResponse>> uploadLegalCaseDocuments(UploadLegalCaseDocumentsRequest request);
  Future<Either<Failure, AcceptProposalResponse>> acceptProposal(int proposalId);
  Future<Either<Failure, LegalCaseResponse>> cancelLegalCase(int caseId);
}

class hoggaRepositoryImpl implements hoggaRepository {
  final hoggaRemoteDataSource remoteDataSource;

  hoggaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ItemCategoryModel>> getItemCategories(int childCategoryId) async {
    try {
      final result = await remoteDataSource.getItemCategories(childCategoryId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponVerificationModel>> verifyCoupon(String code) async {
    try {
      final result = await remoteDataSource.verifyCoupon(code);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> createLegalCase(CreateLegalCaseRequest request) async {
    try {
      final result = await remoteDataSource.createLegalCase(request);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> uploadLegalCaseDocuments(UploadLegalCaseDocumentsRequest request) async {
    try {
      final result = await remoteDataSource.uploadLegalCaseDocuments(request);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptProposalResponse>> acceptProposal(int proposalId) async {
    try {
      final result = await remoteDataSource.acceptProposal(proposalId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> cancelLegalCase(int caseId) async {
    try {
      final result = await remoteDataSource.cancelLegalCase(caseId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
