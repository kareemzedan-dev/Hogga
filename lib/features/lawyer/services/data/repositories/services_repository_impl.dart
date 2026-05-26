import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service_details.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_category_item.dart';
import 'package:hogga/features/lawyer/services/domain/repositories/services_repository.dart';
import 'package:hogga/features/lawyer/services/data/datasources/services_remote_data_source.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;
  
  // Reactive Refresh Stream with Typed Events
  final _refreshController = StreamController<ServiceEvent>.broadcast();
  @override
  Stream<ServiceEvent> get refreshStream => _refreshController.stream;

  // Cache with Timestamp for TTL
  final Map<int, (LawyerServiceDetails, DateTime)> _detailsCache = {};
  static const _cacheTTL = Duration(minutes: 5);

  ServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerService>>> getServices() async {
    try {
      final remoteData = await remoteDataSource.getServices();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerServiceDetails>> getServiceDetails(int id) async {
    // Return from cache if fresh
    if (_detailsCache.containsKey(id)) {
      final (details, timestamp) = _detailsCache[id]!;
      if (DateTime.now().difference(timestamp) < _cacheTTL) {
        return Right(details);
      }
    }

    try {
      final remoteData = await remoteDataSource.getServiceDetails(id);
      _detailsCache[id] = (remoteData, DateTime.now()); 
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addService({
    required String name,
    required String details,
    required double price,
    required int categoryId,
  }) async {
    try {
      final message = await remoteDataSource.addService({
        'name': name,
        'details': details,
        'price': price,
        'categories_item_id': categoryId,
      });
      _refreshController.add(const ServiceListUpdated());
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateService({
    required int id,
    required String name,
    required String details,
    required double price,
    required int categoryId,
  }) async {
    try {
      final message = await remoteDataSource.updateService(id, {
        'name': name,
        'details': details,
        'price': price,
        'categories_item_id': categoryId,
      });
      _detailsCache.remove(id); 
      _refreshController.add(ServiceDetailsUpdated(id));
      _refreshController.add(const ServiceListUpdated());
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteService(int id) async {
    try {
      final message = await remoteDataSource.deleteService(id);
      _detailsCache.remove(id);
      _refreshController.add(ServiceDeletedEvent(id));
      _refreshController.add(const ServiceListUpdated());
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> changeServiceStatus(int id) async {
    try {
      final message = await remoteDataSource.changeServiceStatus(id);
      _detailsCache.remove(id);
      _refreshController.add(ServiceDetailsUpdated(id));
      _refreshController.add(const ServiceListUpdated());
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LawyerCategoryItem>>> getCategoryItems() async {
    try {
      final remoteData = await remoteDataSource.getCategoryItems();
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
