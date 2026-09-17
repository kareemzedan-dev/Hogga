import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
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
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> acceptRequest({
    required int requestId,
    required double price,
    String? description,
  }) async {
    try {
      final remoteData = await remoteDataSource.acceptRequest(
        requestId: requestId,
        price: price,
        description: description,
      );
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (e) {
      String? msg;
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            msg = first.first.toString();
          } else if (first != null) {
            msg = first.toString();
          }
        }
        msg ??= data['message']?.toString();
      }
      msg ??= e.message ?? e.toString();
      return Left(ServerFailure(msg));
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
    } on DioException catch (e) {
      String? msg;
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            msg = first.first.toString();
          } else if (first != null) {
            msg = first.toString();
          }
        }
        msg ??= data['message']?.toString();
      }
      msg ??= e.message ?? e.toString();
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
