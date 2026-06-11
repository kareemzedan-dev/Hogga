import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/wallet_repository.dart';
import 'payment_details_state.dart';

class PaymentDetailsCubit extends Cubit<PaymentDetailsState> {
  final WalletRepository repository;

  PaymentDetailsCubit({required this.repository}) : super(PaymentDetailsInitial());

  Future<void> fetchPaymentDetails(int id) async {
    emit(PaymentDetailsLoading());
    try {
      final details = await repository.getPaymentDetails(id);
      emit(PaymentDetailsLoaded(details));
    } catch (e) {
      emit(PaymentDetailsError(e.toString()));
    }
  }
}
