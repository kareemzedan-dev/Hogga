import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/cases/domain/repositories/cases_repository.dart';
import 'package:hogga/features/lawyer/cases/data/datasources/cases_remote_data_source.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_model.dart';
import 'package:hogga/features/lawyer/cases/data/models/lawyer_case_details_model.dart';

class CasesRepositoryImpl implements CasesRepository {
  final CasesRemoteDataSource remoteDataSource;

  CasesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerCaseModel>>> getCases({String? type}) async {
    try {
      final remoteData = await remoteDataSource.getCases(type: type);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerCaseDetailsModel>> getCaseDetails(int caseId) async {
    try {
      final remoteData = await remoteDataSource.getCaseDetails(caseId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addCaseSession({
    required int caseId,
    required String title,
    required String date,
    required String details,
  }) async {
    try {
      final success = await remoteDataSource.addCaseSession(
        caseId: caseId,
        title: title,
        date: date,
        details: details,
      );
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCaseDocument({
    required int caseId,
    required String title,
    required File document,
  }) async {
    try {
      final success = await remoteDataSource.uploadCaseDocument(
        caseId: caseId,
        title: title,
        document: document,
      );
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
