import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';

abstract class OverviewRepository {
  Future<Either<Failure, LawyerHomeModel>> getLawyerHome();
  Future<Either<Failure, List<LawyerBookingModel>>> getBookings();
  Future<Either<Failure, bool>> toggleActive();
  Future<Either<Failure, bool>> updateSettings(Map<String, dynamic> settings);
  Future<Either<Failure, bool>> updateOnlineStatus(bool isOnline);
  Future<Either<Failure, bool>> updateAvailability(bool isAvailable);
  Future<Either<Failure, bool>> updateFcmToken(String fcmToken);
}
