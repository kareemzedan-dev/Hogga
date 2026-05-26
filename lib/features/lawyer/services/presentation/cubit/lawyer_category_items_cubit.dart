import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_category_item.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class LawyerCategoryItemsState extends Equatable {
  const LawyerCategoryItemsState();

  @override
  List<Object?> get props => [];
}

class LawyerCategoryItemsInitial extends LawyerCategoryItemsState {}

class LawyerCategoryItemsLoading extends LawyerCategoryItemsState {}

class LawyerCategoryItemsLoaded extends LawyerCategoryItemsState {
  final List<LawyerCategoryItem> items;

  const LawyerCategoryItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class LawyerCategoryItemsError extends LawyerCategoryItemsState {
  final String message;

  const LawyerCategoryItemsError(this.message);

  @override
  List<Object?> get props => [message];
}

class LawyerCategoryItemsCubit extends Cubit<LawyerCategoryItemsState> {
  final ServicesRepository repository;

  LawyerCategoryItemsCubit({required this.repository}) : super(LawyerCategoryItemsInitial());

  Future<void> fetchCategoryItems() async {
    emit(LawyerCategoryItemsLoading());
    final result = await repository.getCategoryItems();
    result.fold(
      (failure) => emit(LawyerCategoryItemsError(failure.message)),
      (items) => emit(LawyerCategoryItemsLoaded(items)),
    );
  }
}
