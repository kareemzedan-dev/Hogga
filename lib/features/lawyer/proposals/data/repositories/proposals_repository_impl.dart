import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/proposals/domain/repositories/proposals_repository.dart';
import 'package:hogga/features/lawyer/proposals/data/datasources/proposals_remote_data_source.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_available_service.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';
import 'package:hogga/features/lawyer/proposals/domain/entities/available_service_details.dart';

class ProposalsRepositoryImpl implements ProposalsRepository {
  final ProposalsRemoteDataSource remoteDataSource;

  ProposalsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerAvailableService>>>
  getAvailableServices() async {
    try {
      final remoteData = await remoteDataSource.getAvailableServices();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AvailableServiceDetails>> getAvailableServiceDetails(
    int id,
  ) async {
    try {
      final remoteData = await remoteDataSource.getAvailableServiceDetails(id);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LawyerProposal>>> getProposals() async {
    try {
      final remoteData = await remoteDataSource.getProposals();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> submitProposal({
    required int serviceId,
    required double offerPrice,
    required String description,
  }) async {
    try {
      final success = await remoteDataSource.submitProposal(
        serviceId: serviceId,
        offerPrice: offerPrice,
        description: description,
      );
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (e) {
      String? msg;
      if (e.response?.data is Map) {
        msg = e.response?.data['message']?.toString();
      }
      msg ??= e.message ?? e.toString();
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateProposal({
    required int proposalId,
    required double offerPrice,
    required String description,
  }) async {
    try {
      final success = await remoteDataSource.updateProposal(
        proposalId: proposalId,
        offerPrice: offerPrice,
        description: description,
      );
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (e) {
      String? msg;
      if (e.response?.data is Map) {
        msg = e.response?.data['message']?.toString();
      }
      msg ??= e.message ?? e.toString();
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteProposal(int proposalId) async {
    try {
      final message = await remoteDataSource.deleteProposal(proposalId);
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? e.toString();
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
