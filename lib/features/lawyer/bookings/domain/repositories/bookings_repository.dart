import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';

abstract class BookingsRepository {
  Future<Either<Failure, List<LawyerBookingModel>>> getBookings();
  Future<Either<Failure, LawyerHomeModel>> getLawyerHome();
  Future<Either<Failure, void>> acceptBooking(String bookingId);
  Future<Either<Failure, void>> rejectBooking(String bookingId);
  Future<Either<Failure, void>> updateOnlineStatus(bool isOnline);
}
