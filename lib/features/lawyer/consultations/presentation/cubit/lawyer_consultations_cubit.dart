import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/consultations/data/models/lawyer_consultation_model.dart';
import 'package:hogga/features/lawyer/consultations/domain/repositories/lawyer_consultations_repository.dart';

abstract class LawyerConsultationsState {}

class LawyerConsultationsInitial extends LawyerConsultationsState {}

class LawyerConsultationsLoading extends LawyerConsultationsState {}

class LawyerConsultationsLoaded extends LawyerConsultationsState {
  final List<LawyerConsultationModel> consultations;

  LawyerConsultationsLoaded({required this.consultations});
}

class LawyerConsultationDetailsLoading extends LawyerConsultationsState {}

class LawyerConsultationDetailsLoaded extends LawyerConsultationsState {
  final LawyerConsultationModel consultation;

  LawyerConsultationDetailsLoaded({required this.consultation});
}

class LawyerConsultationActionLoading extends LawyerConsultationsState {}

class LawyerConsultationActionSuccess extends LawyerConsultationsState {
  final String message;

  LawyerConsultationActionSuccess({required this.message});
}

class LawyerConsultationsError extends LawyerConsultationsState {
  final String message;

  LawyerConsultationsError({required this.message});
}

class LawyerConsultationsCubit extends Cubit<LawyerConsultationsState> {
  final LawyerConsultationsRepository repository;
  LawyerConsultationModel? currentConsultation;

  LawyerConsultationsCubit({required this.repository})
    : super(LawyerConsultationsInitial());

  Future<void> getConsultations() async {
    emit(LawyerConsultationsLoading());
    final result = await repository.getConsultations();
    result.fold(
      (failure) => emit(LawyerConsultationsError(message: failure.message)),
      (consultations) =>
          emit(LawyerConsultationsLoaded(consultations: consultations)),
    );
  }

  Future<void> getConsultationDetails(int id) async {
    emit(LawyerConsultationDetailsLoading());
    final result = await repository.getConsultationDetails(id);
    result.fold(
      (failure) {
        emit(LawyerConsultationsError(message: failure.message));
      },
      (consultation) {
        currentConsultation = consultation;
        emit(LawyerConsultationDetailsLoaded(consultation: consultation));
      },
    );
  }

  Future<void> completeConsultation(int id) async {
    emit(LawyerConsultationActionLoading());
    final result = await repository.completeConsultation(id);
    result.fold(
      (failure) => emit(LawyerConsultationsError(message: failure.message)),
      (message) {
        emit(LawyerConsultationActionSuccess(message: message));
        getConsultationDetails(id);
      },
    );
  }
}
