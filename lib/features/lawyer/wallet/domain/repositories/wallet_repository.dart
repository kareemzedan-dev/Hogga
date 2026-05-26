import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_model.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transactions_response_model.dart';

abstract class WalletRepository {
  Future<Either<Failure, LawyerWalletModel>> getWallet();
  Future<Either<Failure, LawyerWalletTransactionsResponseModel>> getWalletTransactions({String? type, int page = 1});
  Future<Either<Failure, bool>> withdrawRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String iban,
  });
}
