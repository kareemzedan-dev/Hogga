import 'package:equatable/equatable.dart';
import 'package:hogga/features/user/home/data/models/banners_model.dart';
import '../../data/models/categories_model.dart';
import '../../data/models/lawyer_service_model.dart';

class HomeState extends Equatable {
  final List<Category> categories;
  final int selectedCategoryIndex;
  final List<BannerModel> banners;
  final List<SubCategory> subCategories;
  final List<SubCategory> childCategories;
  final List<LawyerService> services;
  final List<ProviderProfileModel> filteredProviders;
  final ServiceDetailsModel? selectedServiceDetails;
  final ProviderProfileModel? selectedProviderDetails;
  final bool isLoadingCategories;
  final bool isLoadingSubCategories;
  final bool isLoadingChildCategories;
  final bool isLoadingServices;
  final bool isLoadingFilteredProviders;
  final bool isLoadingServiceDetails;
  final bool isLoadingProviderDetails;
  final bool isLoading;
  final DateTime? timestamp;

  const HomeState({
    required this.categories,
    required this.selectedCategoryIndex,
    required this.isLoadingCategories,
    required this.banners,
    required this.subCategories,
    required this.childCategories,
    required this.services,
    required this.filteredProviders,
    this.selectedServiceDetails,
    this.selectedProviderDetails,
    required this.isLoadingSubCategories,
    required this.isLoadingChildCategories,
    required this.isLoadingServices,
    required this.isLoadingFilteredProviders,
    required this.isLoadingServiceDetails,
    required this.isLoadingProviderDetails,
    required this.isLoading,
    this.timestamp,
  });

  factory HomeState.initial() {
    return const HomeState(
      categories: [],
      selectedCategoryIndex: 0,
      banners: [],
      subCategories: [],
      childCategories: [],
      services: [],
      filteredProviders: [],
      selectedServiceDetails: null,
      selectedProviderDetails: null,
      isLoadingSubCategories: false,
      isLoadingChildCategories: false,
      isLoadingServices: false,
      isLoadingFilteredProviders: false,
      isLoadingServiceDetails: false,
      isLoadingProviderDetails: false,
      isLoadingCategories: false,
      isLoading: false,
      timestamp: null,
    );
  }

  HomeState copyWith({
    List<Category>? categories,
    int? selectedCategoryIndex,
    bool? isLoadingCategories,
    List<BannerModel>? banners,
    List<SubCategory>? subCategories,
    List<SubCategory>? childCategories,
    List<LawyerService>? services,
    List<ProviderProfileModel>? filteredProviders,
    ServiceDetailsModel? selectedServiceDetails,
    ProviderProfileModel? selectedProviderDetails,
    bool? isLoadingSubCategories,
    bool? isLoadingChildCategories,
    bool? isLoadingServices,
    bool? isLoadingFilteredProviders,
    bool? isLoadingServiceDetails,
    bool? isLoadingProviderDetails,
    bool? isLoading,
    DateTime? timestamp,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      banners: banners ?? this.banners,
      subCategories: subCategories ?? this.subCategories,
      childCategories: childCategories ?? this.childCategories,
      services: services ?? this.services,
      filteredProviders: filteredProviders ?? this.filteredProviders,
      selectedServiceDetails: selectedServiceDetails ?? this.selectedServiceDetails,
      selectedProviderDetails: selectedProviderDetails ?? this.selectedProviderDetails,
      isLoadingSubCategories: isLoadingSubCategories ?? this.isLoadingSubCategories,
      isLoadingChildCategories: isLoadingChildCategories ?? this.isLoadingChildCategories,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isLoadingFilteredProviders: isLoadingFilteredProviders ?? this.isLoadingFilteredProviders,
      isLoadingServiceDetails: isLoadingServiceDetails ?? this.isLoadingServiceDetails,
      isLoadingProviderDetails: isLoadingProviderDetails ?? this.isLoadingProviderDetails,
      isLoading: isLoading ?? this.isLoading,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object> get props => [
        categories,
        selectedCategoryIndex,
        isLoadingCategories,
        banners,
        subCategories,
        childCategories,
        services,
        filteredProviders,
        selectedServiceDetails ?? '',
        selectedProviderDetails ?? '',
        isLoadingSubCategories,
        isLoadingChildCategories,
        isLoadingServices,
        isLoadingFilteredProviders,
        isLoadingServiceDetails,
        isLoadingProviderDetails,
        isLoading,
        timestamp ?? '',
      ];
}

class Filters {
  final String search;
  final String category;
  final String sort;
  final String? lat;
  final String? lng;

  const Filters({
    this.search = '',
    this.category = '',
    this.sort = '',
    this.lat,
    this.lng,
  });

  Filters copyWith({
    String? search,
    String? category,
    String? sort,
    String? lat,
    String? lng,
  }) {
    return Filters(
      search: search ?? this.search,
      category: category ?? this.category,
      sort: sort ?? this.sort,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
