import 'package:dartz/dartz.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/specializations/data/datasources/lawyer_specializations_remote_data_source.dart';
import 'package:hogga/features/lawyer/specializations/data/models/lawyer_specialization_model.dart';
import 'package:hogga/features/lawyer/specializations/domain/repositories/lawyer_specializations_repository.dart';

class LawyerSpecializationsRepositoryImpl implements LawyerSpecializationsRepository {
  final LawyerSpecializationsRemoteDataSource remoteDataSource;

  const LawyerSpecializationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerSpecializationCategoryModel>>> getSpecializations() async {
    try {
      final result = await remoteDataSource.getSpecializations();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateSpecializations(List<int> specializationIds) async {
    try {
      final result = await remoteDataSource.updateSpecializations(specializationIds);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
