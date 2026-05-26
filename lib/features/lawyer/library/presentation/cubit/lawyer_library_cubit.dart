import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/library/domain/repositories/library_repository.dart';
import 'package:hogga/features/lawyer/library/data/models/lawyer_library_model.dart';

abstract class LawyerLibraryState {}

class LawyerLibraryInitial extends LawyerLibraryState {}

class LawyerLibraryLoading extends LawyerLibraryState {}

class LawyerLibraryLoaded extends LawyerLibraryState {
  final List<LawyerLibraryItemModel> items;
  final List<LawyerLibraryArticleModel>? articles;
  final LawyerLibraryArticleDetailsModel? articleDetails;

  LawyerLibraryLoaded({
    required this.items,
    this.articles,
    this.articleDetails,
  });

  LawyerLibraryLoaded copyWith({
    List<LawyerLibraryItemModel>? items,
    List<LawyerLibraryArticleModel>? articles,
    LawyerLibraryArticleDetailsModel? articleDetails,
    bool clearArticles = false,
    bool clearDetails = false,
  }) {
    return LawyerLibraryLoaded(
      items: items ?? this.items,
      articles: clearArticles ? null : (articles ?? this.articles),
      articleDetails: clearDetails ? null : (articleDetails ?? this.articleDetails),
    );
  }
}

class LawyerLibraryError extends LawyerLibraryState {
  final String message;
  LawyerLibraryError({required this.message});
}

class LawyerLibraryCubit extends Cubit<LawyerLibraryState> {
  final LibraryRepository repository;

  LawyerLibraryCubit({required this.repository}) : super(LawyerLibraryInitial());

  Future<void> searchLibrary(String query) async {
    if (query.isEmpty) {
      emit(LawyerLibraryInitial());
      return;
    }
    emit(LawyerLibraryLoading());
    final result = await repository.searchLibrary(query);
    result.fold(
      (failure) => emit(LawyerLibraryError(message: failure.message)),
      (items) => emit(LawyerLibraryLoaded(items: items)),
    );
  }

  Future<void> fetchCategoryArticles(int categoryId) async {
    final currentState = state;
    List<LawyerLibraryItemModel> items = [];
    if (currentState is LawyerLibraryLoaded) {
      items = currentState.items;
    }
    
    emit(LawyerLibraryLoading());
    final result = await repository.getCategoryArticles(categoryId);
    result.fold(
      (failure) => emit(LawyerLibraryError(message: failure.message)),
      (articles) => emit(LawyerLibraryLoaded(items: items, articles: articles)),
    );
  }

  Future<void> fetchArticleDetails(int articleId) async {
    final currentState = state;
    List<LawyerLibraryItemModel> items = [];
    List<LawyerLibraryArticleModel>? articles;
    if (currentState is LawyerLibraryLoaded) {
      items = currentState.items;
      articles = currentState.articles;
    }

    emit(LawyerLibraryLoading());
    final result = await repository.getArticleDetails(articleId);
    result.fold(
      (failure) => emit(LawyerLibraryError(message: failure.message)),
      (details) => emit(LawyerLibraryLoaded(items: items, articles: articles, articleDetails: details)),
    );
  }

  /// Navigate backward: from details → article list, from article list → home
  void goBack() {
    final currentState = state;
    if (currentState is LawyerLibraryLoaded) {
      if (currentState.articleDetails != null) {
        // Go back to article list or search results
        emit(LawyerLibraryLoaded(items: currentState.items, articles: currentState.articles));
      } else if (currentState.articles != null) {
        // Go back to home/initial
        emit(LawyerLibraryInitial());
      } else {
        emit(LawyerLibraryInitial());
      }
    } else {
      emit(LawyerLibraryInitial());
    }
  }
}
