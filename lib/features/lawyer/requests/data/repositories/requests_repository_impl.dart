import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/requests/domain/repositories/requests_repository.dart';
import 'package:hogga/features/lawyer/requests/data/datasources/requests_remote_data_source.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_model.dart';
import 'package:hogga/features/lawyer/requests/data/models/lawyer_case_request_details_model.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource remoteDataSource;

  RequestsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerCaseRequestModel>>> getCaseRequests() async {
    try {
      final remoteData = await remoteDataSource.getCaseRequests();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerCaseRequestDetailsModel>> getCaseRequestDetails(int requestId) async {
    try {
      final remoteData = await remoteDataSource.getCaseRequestDetails(requestId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> acceptRequest(int requestId) async {
    try {
      final remoteData = await remoteDataSource.acceptRequest(requestId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> rejectRequest(int requestId) async {
    try {
      final remoteData = await remoteDataSource.rejectRequest(requestId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
