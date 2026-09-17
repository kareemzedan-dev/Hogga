import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/features/lawyer/specializations/data/models/lawyer_specialization_model.dart';
import 'package:hogga/features/lawyer/specializations/domain/repositories/lawyer_specializations_repository.dart';

abstract class LawyerSpecializationsState {}

class LawyerSpecializationsInitial extends LawyerSpecializationsState {}

class LawyerSpecializationsLoading extends LawyerSpecializationsState {}

class LawyerSpecializationsLoaded extends LawyerSpecializationsState {
  final List<LawyerSpecializationCategoryModel> categories;
  final Set<int> selectedItemIds;

  LawyerSpecializationsLoaded({
    required this.categories,
    required this.selectedItemIds,
  });

  LawyerSpecializationsLoaded copyWith({
    List<LawyerSpecializationCategoryModel>? categories,
    Set<int>? selectedItemIds,
  }) {
    return LawyerSpecializationsLoaded(
      categories: categories ?? this.categories,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}

class LawyerSpecializationsUpdating extends LawyerSpecializationsState {
  final List<LawyerSpecializationCategoryModel> categories;
  final Set<int> selectedItemIds;

  LawyerSpecializationsUpdating({
    required this.categories,
    required this.selectedItemIds,
  });
}

class LawyerSpecializationsSuccess extends LawyerSpecializationsState {
  final String message;
  final List<LawyerSpecializationCategoryModel> categories;
  final Set<int> selectedItemIds;

  LawyerSpecializationsSuccess({
    required this.message,
    required this.categories,
    required this.selectedItemIds,
  });
}

class LawyerSpecializationsUpdateError extends LawyerSpecializationsState {
  final String message;
  final List<LawyerSpecializationCategoryModel> categories;
  final Set<int> selectedItemIds;

  LawyerSpecializationsUpdateError({
    required this.message,
    required this.categories,
    required this.selectedItemIds,
  });
}

class LawyerSpecializationsError extends LawyerSpecializationsState {
  final String message;

  LawyerSpecializationsError({required this.message});
}

class LawyerSpecializationsCubit extends Cubit<LawyerSpecializationsState> {
  final LawyerSpecializationsRepository repository;

  LawyerSpecializationsCubit({required this.repository})
    : super(LawyerSpecializationsInitial());

  List<LawyerSpecializationCategoryModel> _categories = [];
  final Set<int> _selectedIds = {};

  Future<void> getSpecializations() async {
    emit(LawyerSpecializationsLoading());
    final result = await repository.getSpecializations();
    result.fold(
      (failure) => emit(LawyerSpecializationsError(message: failure.message)),
      (categories) {
        _categories = categories;
        _selectedIds.clear();

        for (final cat in categories) {
          for (final item in cat.items) {
            if (item.isSelected) {
              _selectedIds.add(item.id);
            }
          }
        }

        AppPreferences().saveLawyerSpecializationIds(_selectedIds.toList());

        emit(
          LawyerSpecializationsLoaded(
            categories: _categories,
            selectedItemIds: Set.from(_selectedIds),
          ),
        );
      },
    );
  }

  void toggleItem(int itemId) {
    if (state is LawyerSpecializationsLoaded ||
        state is LawyerSpecializationsSuccess ||
        state is LawyerSpecializationsUpdateError) {
      if (_selectedIds.contains(itemId)) {
        _selectedIds.remove(itemId);
      } else {
        _selectedIds.add(itemId);
      }
      emit(
        LawyerSpecializationsLoaded(
          categories: _categories,
          selectedItemIds: Set.from(_selectedIds),
        ),
      );
    }
  }

  void toggleCategory(int categoryId) {
    if (state is! LawyerSpecializationsLoaded &&
        state is! LawyerSpecializationsSuccess &&
        state is! LawyerSpecializationsUpdateError) {
      return;
    }
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const LawyerSpecializationCategoryModel(
        id: -1,
        nameAr: '',
        nameEn: '',
        items: [],
      ),
    );
    if (category.id == -1 || category.items.isEmpty) return;

    final allItemIds = category.items.map((i) => i.id).toSet();
    final allSelected = allItemIds.every((id) => _selectedIds.contains(id));

    if (allSelected) {
      _selectedIds.removeAll(allItemIds);
    } else {
      _selectedIds.addAll(allItemIds);
    }

    emit(
      LawyerSpecializationsLoaded(
        categories: _categories,
        selectedItemIds: Set.from(_selectedIds),
      ),
    );
  }

  void clearAll() {
    _selectedIds.clear();
    emit(
      LawyerSpecializationsLoaded(
        categories: _categories,
        selectedItemIds: Set.from(_selectedIds),
      ),
    );
  }

  Future<void> updateSpecializations() async {
    if (_categories.isEmpty) return;
    emit(
      LawyerSpecializationsUpdating(
        categories: _categories,
        selectedItemIds: Set.from(_selectedIds),
      ),
    );

    final result = await repository.updateSpecializations(
      _selectedIds.toList(),
    );
    result.fold(
      (failure) {
        emit(
          LawyerSpecializationsUpdateError(
            message: failure.message,
            categories: _categories,
            selectedItemIds: Set.from(_selectedIds),
          ),
        );
      },
      (message) async {
        await AppPreferences().saveLawyerSpecializationIds(
          _selectedIds.toList(),
        );
        emit(
          LawyerSpecializationsSuccess(
            message: message,
            categories: _categories,
            selectedItemIds: Set.from(_selectedIds),
          ),
        );
      },
    );
  }
}
