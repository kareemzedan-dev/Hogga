import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/more/data/models/privacy_policy_model.dart';
import 'package:hogga/features/user/more/data/repositories/more_repository.dart';

abstract class PrivacyPolicyState {}

class PrivacyPolicyInitial extends PrivacyPolicyState {}

class PrivacyPolicyLoading extends PrivacyPolicyState {}

class PrivacyPolicySuccess extends PrivacyPolicyState {
  final List<PrivacyData> privacyData;
  PrivacyPolicySuccess(this.privacyData);
}

class PrivacyPolicyError extends PrivacyPolicyState {
  final String message;
  PrivacyPolicyError(this.message);
}

class PrivacyPolicyCubit extends Cubit<PrivacyPolicyState> {
  final MoreRepository repository;

  PrivacyPolicyCubit(this.repository) : super(PrivacyPolicyInitial());

  Future<void> getPrivacyPolicy() async {
    emit(PrivacyPolicyLoading());
    final result = await repository.getPrivacyPolicy();
    result.fold(
      (failure) => emit(PrivacyPolicyError(failure.message)),
      (model) => emit(PrivacyPolicySuccess(model.data)),
    );
  }
}
