import '../../domain/entities/referral_code_data.dart';
import '../../domain/entities/referral_history_item.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';

abstract class ReferralState {}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralCodeLoaded extends ReferralState {
  final ReferralCodeData codeData;
  final ReferralCampaign? campaign;

  ReferralCodeLoaded({
    required this.codeData,
    this.campaign,
  });
}

class ReferralError extends ReferralState {
  final String message;

  ReferralError({required this.message});
}

class ReferralHistoryState {
  final List<ReferralHistoryItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  const ReferralHistoryState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  ReferralHistoryState copyWith({
    List<ReferralHistoryItem>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return ReferralHistoryState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }
}
