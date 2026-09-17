import 'package:dartz/dartz.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/specializations/data/models/lawyer_specialization_model.dart';

abstract class LawyerSpecializationsRepository {
  Future<Either<Failure, List<LawyerSpecializationCategoryModel>>> getSpecializations();
  Future<Either<Failure, String>> updateSpecializations(List<int> specializationIds);
}
