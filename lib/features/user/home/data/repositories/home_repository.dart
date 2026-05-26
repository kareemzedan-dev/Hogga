import 'package:dartz/dartz.dart';
import 'package:hogga/features/user/home/data/models/banners_model.dart';
import 'package:hogga/features/user/home/data/models/home_model.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/categories_model.dart';
import '../models/lawyer_service_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, BannerResponseModel>> getBanners();
  Future<Either<Failure, HomeModel>> getHomeData();
  Future<Either<Failure, List<SubCategory>>> getSubCategories(int categoryId);
  Future<Either<Failure, List<SubCategory>>> getChildCategories(int subCategoryId);
  Future<Either<Failure, LawyerServiceResponse>> getServices(int childCategoryId, {int page = 1});
  Future<Either<Failure, ServiceDetailsModel>> getServiceDetails(int serviceId);
  Future<Either<Failure, ProviderProfileModel>> getProviderDetails(int providerId);
  Future<Either<Failure, List<ProviderProfileModel>>> searchProviders({Map<String, dynamic>? filters});
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BannerResponseModel>> getBanners() async {
    try {
      final banners = await remoteDataSource.getBanners();
      return Right(banners);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HomeModel>> getHomeData() async {
    try {
      final homeData = await remoteDataSource.getHomeData();
      return Right(homeData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubCategory>>> getSubCategories(int categoryId) async {
    try {
      final subCategories = await remoteDataSource.getSubCategories(categoryId);
      return Right(subCategories);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubCategory>>> getChildCategories(int subCategoryId) async {
    try {
      final childCategories = await remoteDataSource.getChildCategories(subCategoryId);
      return Right(childCategories);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerServiceResponse>> getServices(int childCategoryId, {int page = 1}) async {
    try {
      final response = await remoteDataSource.getServices(childCategoryId, page: page);
      return Right(response);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceDetailsModel>> getServiceDetails(int serviceId) async {
    try {
      final response = await remoteDataSource.getServiceDetails(serviceId);
      return Right(response);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderProfileModel>> getProviderDetails(int providerId) async {
    try {
      final response = await remoteDataSource.getProviderDetails(providerId);
      return Right(response);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProviderProfileModel>>> searchProviders({Map<String, dynamic>? filters}) async {
    try {
      final providers = await remoteDataSource.getProviders(filters: filters);
      return Right(providers);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
