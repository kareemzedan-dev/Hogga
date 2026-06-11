import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/hogga_services/data/models/item_category_model.dart';
import 'package:hogga/features/user/hogga_services/data/repositories/hogga_repository.dart';

abstract class ItemCategoriesState {}

class ItemCategoriesInitial extends ItemCategoriesState {}

class ItemCategoriesLoading extends ItemCategoriesState {}

class ItemCategoriesSuccess extends ItemCategoriesState {
  final List<ItemCategoryData> items;
  ItemCategoriesSuccess(this.items);
}

class ItemCategoriesError extends ItemCategoriesState {
  final String message;
  ItemCategoriesError(this.message);
}

class ItemCategoriesCubit extends Cubit<ItemCategoriesState> {
  final hoggaRepository repository;

  ItemCategoriesCubit(this.repository) : super(ItemCategoriesInitial());

  Future<void> getItemCategories(int childCategoryId) async {
    emit(ItemCategoriesLoading());
    final result = await repository.getItemCategories(childCategoryId);
    result.fold(
      (failure) => emit(ItemCategoriesError(failure.message)),
      (model) => emit(ItemCategoriesSuccess(model.data)),
    );
  }
}
