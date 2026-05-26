import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/reports/domain/repositories/reports_repository.dart';
import 'package:hogga/features/lawyer/reports/data/models/lawyer_report_model.dart';

abstract class LawyerReportsState {}

class LawyerReportsInitial extends LawyerReportsState {}

class LawyerReportsLoading extends LawyerReportsState {}

class LawyerReportsLoaded extends LawyerReportsState {
  final LawyerReportModel report;
  LawyerReportsLoaded({required this.report});
}

class LawyerReportsError extends LawyerReportsState {
  final String message;
  LawyerReportsError({required this.message});
}

class LawyerReportsCubit extends Cubit<LawyerReportsState> {
  final ReportsRepository repository;

  LawyerReportsCubit({required this.repository}) : super(LawyerReportsInitial());

  Future<void> fetchReports({required String period}) async {
    emit(LawyerReportsLoading());
    final result = await repository.getReports(period);
    result.fold(
      (failure) => emit(LawyerReportsError(message: failure.message)),
      (report) => emit(LawyerReportsLoaded(report: report)),
    );
  }
}
