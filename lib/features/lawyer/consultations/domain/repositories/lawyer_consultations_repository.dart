import 'package:dartz/dartz.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/consultations/data/models/lawyer_consultation_model.dart';

abstract class LawyerConsultationsRepository {
  Future<Either<Failure, List<LawyerConsultationModel>>> getConsultations();
  Future<Either<Failure, LawyerConsultationModel>> getConsultationDetails(
    int id,
  );
  Future<Either<Failure, String>> completeConsultation(int id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getConsultationPricing();
  Future<Either<Failure, String>> saveConsultationPricing({
    required String typeKey,
    required List<Map<String, dynamic>> prices,
  });
}
