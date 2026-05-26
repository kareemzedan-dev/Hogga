import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service_details.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';

abstract class LawyerServiceDetailsState {}

class LawyerServiceDetailsInitial extends LawyerServiceDetailsState {}

class LawyerServiceDetailsLoading extends LawyerServiceDetailsState {}

class LawyerServiceDetailsLoaded extends LawyerServiceDetailsState {
  final LawyerServiceDetails details;
  LawyerServiceDetailsLoaded({required this.details});
}

class LawyerServiceDetailsError extends LawyerServiceDetailsState {
  final String message;
  LawyerServiceDetailsError({required this.message});
}

class LawyerServiceDetailsCubit extends Cubit<LawyerServiceDetailsState> {
  final ServicesRepository repository;
  late final StreamSubscription _refreshSubscription;
  int? _currentId;

  LawyerServiceDetailsCubit({required this.repository}) : super(LawyerServiceDetailsInitial()) {
    _refreshSubscription = repository.refreshStream.listen((event) {
      if (event is ServiceDetailsUpdated && event.id == _currentId) {
        fetchServiceDetails(_currentId!, isRefresh: true);
      }
    });
  }

  Future<void> fetchServiceDetails(int id, {bool isRefresh = false}) async {
    _currentId = id;
    if (!isRefresh) {
      emit(LawyerServiceDetailsLoading());
    }
    
    final result = await repository.getServiceDetails(id);
    result.fold(
      (failure) => emit(LawyerServiceDetailsError(message: failure.message)),
      (details) => emit(LawyerServiceDetailsLoaded(details: details)),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }
}
