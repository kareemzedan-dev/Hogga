import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_model.dart';
import 'package:hogga/features/lawyer/wallet/data/models/lawyer_wallet_transaction_model.dart';
import 'package:hogga/features/lawyer/wallet/domain/repositories/wallet_repository.dart';

abstract class LawyerWalletState {}

class LawyerWalletInitial extends LawyerWalletState {}

class LawyerWalletLoading extends LawyerWalletState {}

class LawyerWalletLoaded extends LawyerWalletState {
  final LawyerWalletModel wallet;
  final List<LawyerWalletTransactionModel> transactions;
  final bool hasReachedMax;
  final int currentPage;
  final String currentFilter;

  LawyerWalletLoaded({
    required this.wallet,
    required this.transactions,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentFilter = 'all',
  });

  LawyerWalletLoaded copyWith({
    LawyerWalletModel? wallet,
    List<LawyerWalletTransactionModel>? transactions,
    bool? hasReachedMax,
    int? currentPage,
    String? currentFilter,
  }) {
    return LawyerWalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class LawyerWalletError extends LawyerWalletState {
  final String message;
  LawyerWalletError({required this.message});
}

class LawyerWalletActionLoading extends LawyerWalletState {}

class LawyerWalletActionSuccess extends LawyerWalletState {
  final String message;
  LawyerWalletActionSuccess({required this.message});
}

class LawyerWalletActionError extends LawyerWalletState {
  final String message;
  LawyerWalletActionError({required this.message});
}

class LawyerWalletCubit extends Cubit<LawyerWalletState> {
  final WalletRepository repository;

  LawyerWalletCubit({required this.repository}) : super(LawyerWalletInitial());

  Future<void> getWalletData({String filter = 'all'}) async {
    emit(LawyerWalletLoading());

    final walletResult = await repository.getWallet();
    final transactionsResult = await repository.getWalletTransactions(type: filter, page: 1);

    walletResult.fold(
      (failure) => emit(LawyerWalletError(message: failure.message)),
      (wallet) {
        transactionsResult.fold(
          (failure) => emit(LawyerWalletError(message: failure.message)),
          (transactionsData) {
            emit(LawyerWalletLoaded(
              wallet: wallet,
              transactions: transactionsData.data,
              hasReachedMax: transactionsData.currentPage >= transactionsData.lastPage,
              currentPage: 1,
              currentFilter: filter,
            ));
          },
        );
      },
    );
  }

  Future<void> loadMoreTransactions() async {
    if (state is LawyerWalletLoaded) {
      final currentState = state as LawyerWalletLoaded;
      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final transactionsResult = await repository.getWalletTransactions(
        type: currentState.currentFilter,
        page: nextPage,
      );

      transactionsResult.fold(
        (failure) => null,
        (transactionsData) {
          final newTransactions = List<LawyerWalletTransactionModel>.from(currentState.transactions)
            ..addAll(transactionsData.data);
          emit(currentState.copyWith(
            transactions: newTransactions,
            hasReachedMax: transactionsData.currentPage >= transactionsData.lastPage,
            currentPage: nextPage,
          ));
        },
      );
    }
  }

  Future<void> withdrawRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String iban,
  }) async {
    final previousState = state;
    emit(LawyerWalletActionLoading());

    final result = await repository.withdrawRequest(
      amount: amount,
      accountName: accountName,
      bankName: bankName,
      iban: iban,
    );

    result.fold(
      (failure) {
        emit(LawyerWalletActionError(message: failure.message));
        if (previousState is LawyerWalletLoaded) emit(previousState);
      },
      (success) {
        emit(LawyerWalletActionSuccess(message: AppStrings.withdrawalRequestSubmittedSuccessfully));
        getWalletData(filter: (previousState is LawyerWalletLoaded) ? previousState.currentFilter : 'all');
      },
    );
  }
}
