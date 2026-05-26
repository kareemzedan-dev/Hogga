import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/documents/domain/repositories/documents_repository.dart';
import 'package:hogga/features/lawyer/documents/data/datasources/documents_remote_data_source.dart';
import 'package:hogga/features/lawyer/documents/data/models/lawyer_document_model.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDataSource remoteDataSource;

  DocumentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LawyerDocumentsResponseModel>> getDocuments({String? folder}) async {
    try {
      final remoteData = await remoteDataSource.getDocuments(folder: folder);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadDocument({
    required String name,
    required File file,
    String? folder,
  }) async {
    try {
      await remoteDataSource.uploadDocument(name: name, file: file, folder: folder);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(int documentId) async {
    try {
      await remoteDataSource.deleteDocument(documentId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
