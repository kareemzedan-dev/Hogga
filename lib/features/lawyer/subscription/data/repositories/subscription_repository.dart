import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/subscription_remote_data_source.dart';
import '../models/package_model.dart';
import '../models/subscription_model.dart';
import '../models/subscription_progress_model.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  // Scoped Reactivity for Home/Dashboard
  final _changeController = StreamController<void>.broadcast();
  Stream<void> get changeStream => _changeController.stream;

  SubscriptionRepository({required this.remoteDataSource});

  Future<Either<Failure, List<PackageModel>>> getPackages() async {
    try {
      final result = await remoteDataSource.getPackages();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SubscriptionModel?>> getCurrentSubscription() async {
    try {
      final result = await remoteDataSource.getCurrentSubscription();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, SubscriptionProgress>> getSubscriptionProgress() async {
    try {
      final result = await remoteDataSource.getSubscriptionProgress();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> subscribe(int packageId) async {
    try {
      final message = await remoteDataSource.subscribe(packageId);
      _changeController.add(null); // Notify Home/Dashboard
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
