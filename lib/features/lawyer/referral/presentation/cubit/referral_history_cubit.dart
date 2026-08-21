import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/referral_history_item.dart';
import '../../domain/repositories/referral_repository.dart';
import 'referral_state.dart';

class ReferralHistoryCubit extends Cubit<ReferralHistoryState> {
  final ReferralRepository repository;

  ReferralHistoryCubit({required this.repository})
      : super(const ReferralHistoryState());

  Future<void> loadHistory({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    final targetPage = refresh ? 1 : state.currentPage;

    if (refresh) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    } else {
      if (state.hasReachedMax) return;
      if (state.items.isEmpty) {
        emit(state.copyWith(isLoading: true, errorMessage: null));
      } else {
        emit(state.copyWith(isLoadingMore: true, errorMessage: null));
      }
    }

    final result = await repository.getReferralHistory(page: targetPage);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        ));
      },
      (pageData) {
        final List<ReferralHistoryItem> updatedList =
            refresh ? pageData.items : [...state.items, ...pageData.items];

        final hasReachedMax = pageData.currentPage >= pageData.lastPage ||
            pageData.items.isEmpty;

        emit(state.copyWith(
          items: updatedList,
          currentPage: pageData.currentPage,
          lastPage: pageData.lastPage,
          total: pageData.total,
          isLoading: false,
          isLoadingMore: false,
          hasReachedMax: hasReachedMax,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;
    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await repository.getReferralHistory(page: nextPage);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ));
      },
      (pageData) {
        final updatedList = [...state.items, ...pageData.items];
        final hasReachedMax = pageData.currentPage >= pageData.lastPage ||
            pageData.items.isEmpty;

        emit(state.copyWith(
          items: updatedList,
          currentPage: pageData.currentPage,
          lastPage: pageData.lastPage,
          total: pageData.total,
          isLoadingMore: false,
          hasReachedMax: hasReachedMax,
          errorMessage: null,
        ));
      },
    );
  }
}
