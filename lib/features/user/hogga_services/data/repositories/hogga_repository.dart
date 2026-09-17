import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/bainah_remote_datasource.dart';
import '../models/item_category_model.dart';
import '../models/legal_case_models.dart';

abstract class HoggaRepository {
  Future<Either<Failure, ItemCategoryModel>> getItemCategories({
    required int childCategoryId,
    int? subCategoryId,
  });
  Future<Either<Failure, CouponVerificationModel>> verifyCoupon(String code);
  Future<Either<Failure, List<ConsultationLawyerModel>>> getConsultationLawyers(
    int categorySubId, {
    String? coupon,
  });
  Future<Either<Failure, List<ConsultationLawyerModel>>> getCouponLawyers(
    String code,
  );
  Future<Either<Failure, List<ConsultationPriceModel>>>
  getConsultationLawyerPrices({
    required int lawyerId,
    required int categorySubId,
  });
  Future<Either<Failure, LegalCaseResponse>> bookConsultation(
    BookConsultationRequest request,
  );
  Future<Either<Failure, LegalCaseResponse>> completeConsultation(
    int consultationId,
  );
  Future<Either<Failure, LegalCaseResponse>> createLegalCase(
    CreateLegalCaseRequest request,
  );
  Future<Either<Failure, LegalCaseResponse>> uploadLegalCaseDocuments(
    UploadLegalCaseDocumentsRequest request,
  );
  Future<Either<Failure, AcceptProposalResponse>> acceptProposal(
    int proposalId, {
    String paymentMethod = 'card',
  });
  Future<Either<Failure, LegalCaseResponse>> completeLegalCase(int caseId);
  Future<Either<Failure, LegalCaseResponse>> cancelLegalCase(int caseId);
}

class HoggaRepositoryImpl implements HoggaRepository {
  final HoggaRemoteDataSource remoteDataSource;

  HoggaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ItemCategoryModel>> getItemCategories({
    required int childCategoryId,
    int? subCategoryId,
  }) async {
    try {
      final result = await remoteDataSource.getItemCategories(
        childCategoryId: childCategoryId,
        subCategoryId: subCategoryId,
      );
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CouponVerificationModel>> verifyCoupon(
    String code,
  ) async {
    try {
      final result = await remoteDataSource.verifyCoupon(code);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConsultationLawyerModel>>> getConsultationLawyers(
    int categorySubId, {
    String? coupon,
  }) async {
    try {
      final result = await remoteDataSource.getConsultationLawyers(
        categorySubId,
        coupon: coupon,
      );
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConsultationLawyerModel>>> getCouponLawyers(
    String code,
  ) async {
    try {
      final result = await remoteDataSource.getCouponLawyers(code);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConsultationPriceModel>>>
  getConsultationLawyerPrices({
    required int lawyerId,
    required int categorySubId,
  }) async {
    try {
      final result = await remoteDataSource.getConsultationLawyerPrices(
        lawyerId: lawyerId,
        categorySubId: categorySubId,
      );
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> bookConsultation(
    BookConsultationRequest request,
  ) async {
    try {
      final result = await remoteDataSource.bookConsultation(request);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> completeConsultation(
    int consultationId,
  ) async {
    try {
      final result = await remoteDataSource.completeConsultation(
        consultationId,
      );
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> createLegalCase(
    CreateLegalCaseRequest request,
  ) async {
    try {
      final result = await remoteDataSource.createLegalCase(request);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> uploadLegalCaseDocuments(
    UploadLegalCaseDocumentsRequest request,
  ) async {
    try {
      final result = await remoteDataSource.uploadLegalCaseDocuments(request);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptProposalResponse>> acceptProposal(
    int proposalId, {
    String paymentMethod = 'card',
  }) async {
    try {
      final result = await remoteDataSource.acceptProposal(
        proposalId,
        paymentMethod: paymentMethod,
      );
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> completeLegalCase(
    int caseId,
  ) async {
    try {
      final result = await remoteDataSource.completeLegalCase(caseId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LegalCaseResponse>> cancelLegalCase(int caseId) async {
    try {
      final result = await remoteDataSource.cancelLegalCase(caseId);
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
