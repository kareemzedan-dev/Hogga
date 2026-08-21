import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/referral_repository.dart';
import 'referral_state.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';

class ReferralCubit extends Cubit<ReferralState> {
  final ReferralRepository repository;

  ReferralCubit({required this.repository}) : super(ReferralInitial());

  Future<void> getReferralCode({ReferralCampaign? campaign}) async {
    emit(ReferralLoading());
    final result = await repository.getMyReferralCode();
    result.fold(
      (failure) => emit(ReferralError(message: failure.message)),
      (data) => emit(ReferralCodeLoaded(codeData: data, campaign: campaign)),
    );
  }
}
