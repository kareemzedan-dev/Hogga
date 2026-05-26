import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/home/data/repositories/home_repository.dart';
import 'package:hogga/features/user/home/data/models/lawyer_service_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  HomeCubit({required this.repository}) : super(HomeState.initial());

  Future<void> loadHomeData() async {
    emit(state.copyWith(isLoadingCategories: true));
    final result = await repository.getHomeData();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingCategories: false));
      },
      (homeData) {
        emit(state.copyWith(
          categories: homeData.categories,
          banners: homeData.banners,
          isLoadingCategories: false,
        ));
      },
    );
  }

  Future<void> loadSubCategories(int categoryId) async {
    emit(state.copyWith(isLoadingSubCategories: true, subCategories: []));
    final result = await repository.getSubCategories(categoryId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingSubCategories: false));
      },
      (subCategories) {
        emit(state.copyWith(
          subCategories: subCategories,
          isLoadingSubCategories: false,
        ));
      },
    );
  }

  Future<void> loadChildCategories(int subCategoryId) async {
    emit(state.copyWith(isLoadingChildCategories: true, childCategories: []));
    final result = await repository.getChildCategories(subCategoryId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingChildCategories: false));
      },
      (childCategories) {
        emit(state.copyWith(
          childCategories: childCategories,
          isLoadingChildCategories: false,
        ));
      },
    );
  }

  Future<void> loadServices(int childCategoryId, {int page = 1}) async {
    emit(state.copyWith(isLoadingServices: true, services: page == 1 ? [] : state.services));
    final result = await repository.getServices(childCategoryId, page: page);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingServices: false));
      },
      (response) {
        final newServices = page == 1 ? response.data.services : [...state.services, ...response.data.services];
        emit(state.copyWith(
          services: newServices,
          isLoadingServices: false,
        ));
      },
    );
  }

  Future<void> loadServiceDetails(int serviceId) async {
    emit(state.copyWith(isLoadingServiceDetails: true, selectedServiceDetails: null));
    final result = await repository.getServiceDetails(serviceId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingServiceDetails: false));
      },
      (serviceDetails) {
        emit(state.copyWith(
          selectedServiceDetails: serviceDetails,
          isLoadingServiceDetails: false,
        ));
      },
    );
  }

  Future<void> loadProviderDetails(int providerId) async {
    emit(state.copyWith(isLoadingProviderDetails: true, selectedProviderDetails: null));
    final result = await repository.getProviderDetails(providerId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingProviderDetails: false));
      },
      (providerDetails) {
        emit(state.copyWith(
          selectedProviderDetails: providerDetails,
          isLoadingProviderDetails: false,
        ));
      },
    );
  }

  // Deprecated: keeping for compatibility during transition if needed
  Future<void> loadCategories() async => loadHomeData();
  Future<void> loadBanners() async => loadHomeData();

  Future<void> searchProviders({Map<String, dynamic>? filters}) async {
    emit(state.copyWith(isLoadingFilteredProviders: true, filteredProviders: []));
    final result = await repository.searchProviders(filters: filters);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingFilteredProviders: false));
      },
      (providers) {
        emit(state.copyWith(
          filteredProviders: providers,
          isLoadingFilteredProviders: false,
        ));
      },
    );
  }

  void selectCategory(int index) {
    if (index == state.selectedCategoryIndex) return;
    emit(state.copyWith(selectedCategoryIndex: index));
  }
}
