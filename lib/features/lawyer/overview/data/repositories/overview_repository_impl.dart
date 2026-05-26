import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/overview/domain/repositories/overview_repository.dart';
import 'package:hogga/features/lawyer/overview/data/datasources/overview_remote_data_source.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';

class OverviewRepositoryImpl implements OverviewRepository {
  final OverviewRemoteDataSource remoteDataSource;

  OverviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LawyerHomeModel>> getLawyerHome() async {
    try {
      final remoteData = await remoteDataSource.getLawyerHome();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LawyerBookingModel>>> getBookings() async {
    try {
      final remoteData = await remoteDataSource.getBookings();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleActive() async {
    try {
      final success = await remoteDataSource.toggleActive();
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateSettings(Map<String, dynamic> settings) async {
    try {
      final success = await remoteDataSource.updateSettings(settings);
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline) async {
    try {
      final success = await remoteDataSource.updateOnlineStatus(isOnline);
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAvailability(bool isAvailable) async {
    try {
      final success = await remoteDataSource.updateAvailability(isAvailable);
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateFcmToken(String fcmToken) async {
    try {
      final success = await remoteDataSource.updateFcmToken(fcmToken);
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
