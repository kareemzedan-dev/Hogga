import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import '../entities/lawyer_service.dart';
import '../entities/lawyer_service_details.dart';
import '../entities/lawyer_category_item.dart';

sealed class ServiceEvent {
  final int? id;
  const ServiceEvent([this.id]);
}

class ServiceListUpdated extends ServiceEvent {
  const ServiceListUpdated() : super();
}

class ServiceDetailsUpdated extends ServiceEvent {
  const ServiceDetailsUpdated(int id) : super(id);
}

class ServiceDeletedEvent extends ServiceEvent {
  const ServiceDeletedEvent(int id) : super(id);
}

abstract class ServicesRepository {
  Stream<ServiceEvent> get refreshStream;
  Future<Either<Failure, List<LawyerService>>> getServices();
  Future<Either<Failure, LawyerServiceDetails>> getServiceDetails(int id);
  Future<Either<Failure, String>> addService({
    required String name,
    required String details,
    required double price,
    required int categoryId,
  });
  Future<Either<Failure, String>> updateService({
    required int id,
    required String name,
    required String details,
    required double price,
    required int categoryId,
  });
  Future<Either<Failure, String>> deleteService(int id);
  Future<Either<Failure, String>> changeServiceStatus(int id);
  Future<Either<Failure, List<LawyerCategoryItem>>> getCategoryItems();
}
