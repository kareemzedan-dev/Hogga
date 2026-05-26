import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/bookings/domain/repositories/bookings_repository.dart';
import 'package:hogga/features/lawyer/bookings/data/datasources/bookings_remote_data_source.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource remoteDataSource;

  BookingsRepositoryImpl({required this.remoteDataSource});

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
  Future<Either<Failure, void>> acceptBooking(String bookingId) async {
    try {
      await remoteDataSource.acceptBooking(bookingId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectBooking(String bookingId) async {
    try {
      await remoteDataSource.rejectBooking(bookingId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus(bool isOnline) async {
    try {
      await remoteDataSource.updateOnlineStatus(isOnline);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
