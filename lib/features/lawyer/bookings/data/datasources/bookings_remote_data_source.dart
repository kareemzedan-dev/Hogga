import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';

abstract class BookingsRemoteDataSource {
  Future<List<LawyerBookingModel>> getBookings();
  Future<LawyerHomeModel> getLawyerHome();
  Future<void> acceptBooking(String bookingId);
  Future<void> rejectBooking(String bookingId);
  Future<void> updateOnlineStatus(bool isOnline);
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final ApiClient apiClient;

  BookingsRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<List<LawyerBookingModel>> getBookings() async {
    final response = await apiClient.get(AppEndPoints.lawyerBookingsEndPoint);
    return (response.data['data'] as List).map((e) => LawyerBookingModel.fromJson(e)).toList();
  }

  @override
  Future<LawyerHomeModel> getLawyerHome() async {
    final response = await apiClient.get(AppEndPoints.lawyerHomeEndPoint);
    return LawyerHomeModel.fromJson(response.data['data']);
  }

  @override
  Future<void> acceptBooking(String bookingId) async {
    await apiClient.post("${AppEndPoints.lawyerBookingsEndPoint}/$bookingId/accept");
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    await apiClient.post("${AppEndPoints.lawyerBookingsEndPoint}/$bookingId/reject");
  }

  @override
  Future<void> updateOnlineStatus(bool isOnline) async {
    await apiClient.post(AppEndPoints.lawyerToggleActiveEndPoint, data: {'is_active': isOnline ? 1 : 0});
  }
}
