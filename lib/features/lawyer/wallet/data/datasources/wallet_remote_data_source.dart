import 'package:dio/dio.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/constants/end_points.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_model.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transactions_response_model.dart';

abstract class WalletRemoteDataSource {
  Future<LawyerWalletModel> getWallet();
  Future<LawyerWalletTransactionsResponseModel> getWalletTransactions({String? type, int page = 1});
  Future<bool> withdrawRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String iban,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});
  
  @override
  Future<LawyerWalletTransactionsResponseModel> getWalletTransactions({String? type, int page = 1}) async {
    final response = await apiClient.get(
      AppEndPoints.lawyerWalletTransactionsEndPoint,
      queryParameters: {
        if (type != null && type != 'all') 'type': type,
        'page': page,
      },
    );
    return LawyerWalletTransactionsResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<LawyerWalletModel> getWallet() async {
    final response = await apiClient.get(AppEndPoints.lawyerWalletEndPoint);
    return LawyerWalletModel.fromJson(response.data['data']);
  }

  @override
  Future<bool> withdrawRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String iban,
  }) async {
    try {
      final response = await apiClient.post(
        AppEndPoints.lawyerWithdrawEndPoint,
        data: {
          'amount': amount,
          'account_name': accountName,
          'bank_name': bankName,
          'iban': iban,
        },
      );
      if (response.data['status'] != true) {
        throw ServerFailure(response.data['message']?.toString() ?? 'Failed to withdraw');
      }
      return true;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final message = e.response?.data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw ServerFailure(message);
        }
      }
      throw ServerFailure(e.message ?? 'Unknown error');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
