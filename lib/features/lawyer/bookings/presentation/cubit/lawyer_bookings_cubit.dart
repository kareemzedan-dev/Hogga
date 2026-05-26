import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/bookings/domain/repositories/bookings_repository.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';

abstract class LawyerBookingsState {}

class LawyerBookingsInitial extends LawyerBookingsState {}

class LawyerBookingsLoading extends LawyerBookingsState {}

class LawyerBookingsLoaded extends LawyerBookingsState {
  final List<LawyerBookingModel> bookings;
  final LawyerHomeModel homeData;
  final String? actionError;

  LawyerBookingsLoaded({
    required this.bookings,
    required this.homeData,
    this.actionError,
  });

  LawyerBookingsLoaded copyWith({
    List<LawyerBookingModel>? bookings,
    LawyerHomeModel? homeData,
    String? actionError,
  }) {
    return LawyerBookingsLoaded(
      bookings: bookings ?? this.bookings,
      homeData: homeData ?? this.homeData,
      actionError: actionError,
    );
  }
}

class LawyerBookingsError extends LawyerBookingsState {
  final String message;
  LawyerBookingsError({required this.message});
}

class LawyerBookingsCubit extends Cubit<LawyerBookingsState> {
  final BookingsRepository repository;

  LawyerBookingsCubit({required this.repository}) : super(LawyerBookingsInitial());

  Future<void> fetchBookings() async {
    emit(LawyerBookingsLoading());
    final bookingsFuture = repository.getBookings();
    final homeFuture = repository.getLawyerHome();

    final bookingsResult = await bookingsFuture;
    final homeResult = await homeFuture;

    bookingsResult.fold(
      (failure) => emit(LawyerBookingsError(message: failure.message)),
      (bookings) {
        homeResult.fold(
          (failure) => emit(LawyerBookingsError(message: failure.message)),
          (LawyerHomeModel homeData) => emit(
            LawyerBookingsLoaded(bookings: bookings, homeData: homeData),
          ),
        );
      },
    );
  }

  Future<bool> acceptBooking(String bookingId) async {
    final currentState = state;
    if (currentState is! LawyerBookingsLoaded) return false;

    final result = await repository.acceptBooking(bookingId);
    return result.fold(
      (failure) {
        emit(currentState.copyWith(actionError: failure.message));
        return false;
      },
      (_) {
        fetchBookings();
        return true;
      },
    );
  }

  Future<bool> rejectBooking(String bookingId) async {
    final currentState = state;
    if (currentState is! LawyerBookingsLoaded) return false;

    final result = await repository.rejectBooking(bookingId);
    return result.fold(
      (failure) {
        emit(currentState.copyWith(actionError: failure.message));
        return false;
      },
      (_) {
        fetchBookings();
        return true;
      },
    );
  }

  Future<void> toggleOnlineStatus(bool isOnline) async {
    final currentState = state;
    if (currentState is! LawyerBookingsLoaded) return;

    final optimisticHomeData = currentState.homeData.copyWith(
      settings: currentState.homeData.settings.copyWith(isActive: isOnline),
    );
    emit(currentState.copyWith(homeData: optimisticHomeData));

    final result = await repository.updateOnlineStatus(isOnline);
    result.fold(
      (failure) {
        emit(currentState.copyWith(actionError: failure.message));
        fetchBookings();
      },
      (_) => fetchBookings(),
    );
  }
}
