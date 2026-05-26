import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionCubit({required this.repository}) : super(SubscriptionInitial());

  Future<void> loadSubscriptionData() async {
    emit(SubscriptionLoading());

    final packagesResult = await repository.getPackages();
    final currentSubResult = await repository.getCurrentSubscription();

    packagesResult.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (packages) {
        currentSubResult.fold(
          (failure) => emit(SubscriptionError(failure.message)),
          (currentSubscription) {
            emit(SubscriptionLoaded(
              packages: packages,
              currentSubscription: currentSubscription,
            ));
          },
        );
      },
    );
  }

  Future<void> subscribeToPackage(int packageId) async {
    final currentState = state;
    emit(SubscriptionActionLoading());

    final result = await repository.subscribe(packageId);
    result.fold(
      (failure) {
        emit(SubscriptionError(failure.message));
        if (currentState is SubscriptionLoaded) {
          emit(currentState);
        }
      },
      (message) async {
        emit(SubscriptionActionSuccess(message));
        await loadSubscriptionData();
      },
    );
  }
}
