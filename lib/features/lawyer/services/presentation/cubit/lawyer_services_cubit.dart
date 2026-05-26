import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class LawyerServicesState {}

class LawyerServicesInitial extends LawyerServicesState {}

class LawyerServicesLoading extends LawyerServicesState {}

class LawyerServicesLoaded extends LawyerServicesState {
  final List<LawyerService> services;
  LawyerServicesLoaded({required this.services});
}

class LawyerServicesError extends LawyerServicesState {
  final String message;
  LawyerServicesError({required this.message});
}

class LawyerServicesCubit extends Cubit<LawyerServicesState> {
  final ServicesRepository repository;
  late final StreamSubscription _refreshSubscription;

  LawyerServicesCubit({required this.repository}) : super(LawyerServicesInitial()) {
    _refreshSubscription = repository.refreshStream.listen((event) {
      if (event is ServiceListUpdated) {
        fetchServices();
      }
    });
  }

  Future<void> fetchServices() async {
    // Only show loading if we don't have data yet to avoid flickering
    if (state is! LawyerServicesLoaded) {
      emit(LawyerServicesLoading());
    }
    
    final result = await repository.getServices();
    result.fold(
      (failure) => emit(LawyerServicesError(message: failure.message)),
      (services) => emit(LawyerServicesLoaded(services: services)),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }
}
