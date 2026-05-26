import '../../data/models/package_model.dart';
import '../../data/models/subscription_model.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<PackageModel> packages;
  final SubscriptionModel? currentSubscription;

  SubscriptionLoaded({
    required this.packages,
    this.currentSubscription,
  });
}

class SubscriptionActionLoading extends SubscriptionState {}

class SubscriptionActionSuccess extends SubscriptionState {
  final String message;
  SubscriptionActionSuccess(this.message);
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);
}
