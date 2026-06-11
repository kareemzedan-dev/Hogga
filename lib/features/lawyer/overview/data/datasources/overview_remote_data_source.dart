import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_booking_model.dart';

abstract class OverviewRemoteDataSource {
  Future<LawyerHomeModel> getLawyerHome();
  Future<List<LawyerBookingModel>> getBookings();
  Future<bool> toggleActive();
  Future<bool> updateSettings(Map<String, dynamic> settings);
  Future<bool> updateOnlineStatus(bool isOnline);
  Future<bool> updateAvailability(bool isAvailable);
  Future<bool> updateFcmToken(String fcmToken);
}

class OverviewRemoteDataSourceImpl implements OverviewRemoteDataSource {
  final ApiClient apiClient;

  OverviewRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerHomeModel> getLawyerHome() async {
    final response = await apiClient.get(AppEndPoints.lawyerHomeEndPoint);
    return LawyerHomeModel.fromJson(response.data['data']);
  }

  @override
  Future<List<LawyerBookingModel>> getBookings() async {
    final response = await apiClient.get(AppEndPoints.lawyerBookingsEndPoint);
    return (response.data['data'] as List)
        .map((e) => LawyerBookingModel.fromJson(e))
        .toList();
  }

  @override
  Future<bool> toggleActive() async {
    final response = await apiClient.post(AppEndPoints.lawyerToggleActiveEndPoint);
    return response.data['status'] == true;
  }

  @override
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerUpdateSettingsEndPoint,
      data: settings,
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> updateOnlineStatus(bool isOnline) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerOnlineStatusEndPoint,
      data: {'is_active': isOnline},
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> updateAvailability(bool isAvailable) async {
    final response = await apiClient.post(
      AppEndPoints.lawyerAvailabilityEndPoint,
      data: {'is_available': isAvailable},
    );
    return response.data['status'] == true;
  }

  @override
  Future<bool> updateFcmToken(String fcmToken) async {
    final response = await apiClient.put(
      AppEndPoints.lawyerUpdateTokenEndPoint,
      data: {'fcm_token': fcmToken},
    );
    return response.data['status'] == true;
  }
}
