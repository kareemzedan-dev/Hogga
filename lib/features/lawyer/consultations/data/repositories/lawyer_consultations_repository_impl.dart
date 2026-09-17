import 'package:dartz/dartz.dart';
import 'package:hogga/core/errors/failures.dart';
import 'package:hogga/features/lawyer/consultations/data/datasources/lawyer_consultations_remote_data_source.dart';
import 'package:hogga/features/lawyer/consultations/data/models/lawyer_consultation_model.dart';
import 'package:hogga/features/lawyer/consultations/domain/repositories/lawyer_consultations_repository.dart';

class LawyerConsultationsRepositoryImpl
    implements LawyerConsultationsRepository {
  final LawyerConsultationsRemoteDataSource remoteDataSource;

  const LawyerConsultationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerConsultationModel>>>
  getConsultations() async {
    try {
      return Right(await remoteDataSource.getConsultations());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerConsultationModel>> getConsultationDetails(
    int id,
  ) async {
    try {
      return Right(await remoteDataSource.getConsultationDetails(id));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> completeConsultation(int id) async {
    try {
      return Right(await remoteDataSource.completeConsultation(id));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveConsultationPricing({
    required String typeKey,
    required List<Map<String, dynamic>> prices,
  }) async {
    try {
      return Right(
        await remoteDataSource.saveConsultationPricing(
          typeKey: typeKey,
          prices: prices,
        ),
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getConsultationPricing() async {
    try {
      return Right(await remoteDataSource.getConsultationPricing());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
