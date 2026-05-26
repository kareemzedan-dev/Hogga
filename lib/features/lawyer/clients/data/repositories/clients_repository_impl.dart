import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/clients/domain/repositories/clients_repository.dart';
import 'package:hogga/features/lawyer/clients/data/datasources/clients_remote_data_source.dart';
import 'package:hogga/features/lawyer/clients/data/models/lawyer_client_model.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  ClientsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LawyerClientsResponseModel>> getClients({int page = 1}) async {
    try {
      final remoteData = await remoteDataSource.getClients(page: page);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
