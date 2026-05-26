import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/wallet/domain/repositories/wallet_repository.dart';
import 'package:hogga/features/lawyer/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_model.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transactions_response_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, LawyerWalletTransactionsResponseModel>> getWalletTransactions({String? type, int page = 1}) async {
    try {
      final remoteData = await remoteDataSource.getWalletTransactions(type: type, page: page);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerWalletModel>> getWallet() async {
    try {
      final remoteData = await remoteDataSource.getWallet();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> withdrawRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String iban,
  }) async {
    try {
      final success = await remoteDataSource.withdrawRequest(
        amount: amount,
        accountName: accountName,
        bankName: bankName,
        iban: iban,
      );
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
