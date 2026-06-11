import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;

  WalletCubit({required this.repository}) : super(WalletInitial());

  Future<void> fetchPayments() async {
    emit(WalletLoading());
    try {
      final response = await repository.getPayments();
      emit(WalletLoaded(response.data));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
