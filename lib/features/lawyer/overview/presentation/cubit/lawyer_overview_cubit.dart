import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/overview/data/models/lawyer_home_model.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/overview/domain/repositories/overview_repository.dart';
import 'package:hogga/features/lawyer/subscription/data/repositories/subscription_repository.dart';
import 'package:hogga/features/lawyer/subscription/data/models/subscription_summary_model.dart';

abstract class LawyerOverviewState {}

class LawyerOverviewInitial extends LawyerOverviewState {}

class LawyerOverviewLoading extends LawyerOverviewState {}

class LawyerOverviewLoaded extends LawyerOverviewState {
  final LawyerHomeModel homeData;
  final String? actionError;

  LawyerOverviewLoaded({
    required this.homeData,
    this.actionError,
  });

  LawyerOverviewLoaded copyWith({
    LawyerHomeModel? homeData,
    String? actionError,
  }) {
    return LawyerOverviewLoaded(
      homeData: homeData ?? this.homeData,
      actionError: actionError,
    );
  }
}

class LawyerOverviewError extends LawyerOverviewState {
  final String message;
  LawyerOverviewError({required this.message});
}

class LawyerOverviewCubit extends Cubit<LawyerOverviewState> {
  final OverviewRepository repository;
  final SubscriptionRepository subscriptionRepository;
  late final StreamSubscription _subscriptionEventSub;

  LawyerOverviewCubit({
    required this.repository,
    required this.subscriptionRepository,
  }) : super(LawyerOverviewInitial()) {
    _subscriptionEventSub = subscriptionRepository.changeStream.listen((_) {
      refreshSubscriptionSummary(); // Targeted refresh
    });
  }

  @override
  Future<void> close() {
    _subscriptionEventSub.cancel();
    return super.close();
  }

  Future<void> getOverviewData() async {
    emit(LawyerOverviewLoading());
    final result = await repository.getLawyerHome();
    result.fold(
      (failure) => emit(LawyerOverviewError(message: failure.message)),
      (homeData) => emit(LawyerOverviewLoaded(homeData: homeData)),
    );
  }

  Future<void> refreshSubscriptionSummary() async {
    if (state is! LawyerOverviewLoaded) return;
    final currentState = state as LawyerOverviewLoaded;

    final result = await subscriptionRepository.getCurrentSubscription();
    result.fold(
      (failure) => null, // Silently ignore or log for background refresh
      (subscription) {
        if (subscription != null) {
          // Map SubscriptionModel to the lightweight SubscriptionSummary entity
          final updatedSummary = SubscriptionSummary(
            status: subscription.status,
            planName: subscription.packageSnapshot.name,
            isVisibleToClients: subscription.isVisibleToClients,
            remainingConsultations: subscription.progress.remaining,
            completionPercentage: subscription.progress.completionPercentage,
          );
          
          final updatedHomeData = currentState.homeData.copyWith(
            subscriptionSummary: updatedSummary,
          );
          
          emit(currentState.copyWith(homeData: updatedHomeData));
        }
      },
    );
  }

  Future<void> toggleOnlineStatus(bool isOnline) async {
    if (state is! LawyerOverviewLoaded) return;
    final currentState = state as LawyerOverviewLoaded;

    final optimisticHomeData = currentState.homeData.copyWith(
      settings: currentState.homeData.settings.copyWith(isActive: isOnline),
    );
    emit(currentState.copyWith(homeData: optimisticHomeData));

    final result = await repository.updateOnlineStatus(isOnline);
    result.fold(
      (failure) {
        // Revert optimistic update on failure
        emit(currentState.copyWith(
          homeData: currentState.homeData,
          actionError: failure.message,
        ));
      },
      (success) {
        // Optimistic update is confirmed, no need to rebuild the entire page.
      },
    );
  }

  Future<void> updateConsultationSetting(String key, bool value) async {
    if (state is! LawyerOverviewLoaded) return;
    final currentState = state as LawyerOverviewLoaded;

    LawyerSettings updatedSettings = currentState.homeData.settings;
    if (key == 'accept_text_consultations') {
      updatedSettings = updatedSettings.copyWith(acceptTextConsultations: value);
    } else if (key == 'accept_instant_consultations') {
      updatedSettings = updatedSettings.copyWith(acceptInstantConsultations: value);
    } else if (key == 'accept_services') {
      updatedSettings = updatedSettings.copyWith(acceptServices: value);
    }

    final optimisticHomeData = currentState.homeData.copyWith(settings: updatedSettings);
    emit(currentState.copyWith(homeData: optimisticHomeData));

    final result = await repository.updateSettings({key: value});
    result.fold(
      (failure) {
        // Revert optimistic update on failure
        emit(currentState.copyWith(
          homeData: currentState.homeData,
          actionError: failure.message,
        ));
      },
      (success) {
        // Optimistic update is confirmed, no need to rebuild the entire page.
      },
    );
  }

  void clearActionError() {
    if (state is LawyerOverviewLoaded) {
      emit((state as LawyerOverviewLoaded).copyWith(actionError: null));
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final result = await repository.updateFcmToken(fcmToken);
    result.fold(
      (failure) => null, // Silently fail for token updates
      (success) => null,
    );
  }
}
