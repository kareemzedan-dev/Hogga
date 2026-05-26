import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/clients/data/models/lawyer_client_model.dart';

abstract class ClientsRepository {
  Future<Either<Failure, LawyerClientsResponseModel>> getClients({int page = 1});
}
