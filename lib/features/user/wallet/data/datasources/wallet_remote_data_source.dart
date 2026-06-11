import 'package:dio/dio.dart';
import '../../../../../core/constants/end_points.dart';
import '../../../../../core/network/api_client.dart';

class WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSource({required this.apiClient});

  Future<Response> getPayments() async {
    return await apiClient.get(AppEndPoints.userPaymentsEndPoint);
  }

  Future<Response> getPaymentDetails(int id) async {
    return await apiClient.get(AppEndPoints.getUserPaymentDetailsEndPoint(id));
  }
}
