import 'package:dio/dio.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/payment_details_model.dart';
import '../models/wallet_response_model.dart';

class WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepository({required this.remoteDataSource});

  Future<WalletResponseModel> getPayments() async {
    try {
      final response = await remoteDataSource.getPayments();
      if (response.statusCode == 200) {
        return WalletResponseModel.fromJson(response.data);
      } else {
         throw Exception('Failed to fetch payments: ${response.statusCode}');
      }
    } catch (e) {
      throw e is DioException ? e : Exception(e.toString());
    }
  }

  Future<PaymentDetailsModel> getPaymentDetails(int id) async {
    try {
      final response = await remoteDataSource.getPaymentDetails(id);
      if (response.statusCode == 200) {
         return PaymentDetailsModel.fromJson(response.data['data']);
      } else {
         throw Exception('Failed to fetch payment details: ${response.statusCode}');
      }
    } catch (e) {
      throw e is DioException ? e : Exception(e.toString());
    }
  }
}
