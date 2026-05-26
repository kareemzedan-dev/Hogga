import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/documents/data/models/lawyer_document_model.dart';

abstract class DocumentsRepository {
  Future<Either<Failure, LawyerDocumentsResponseModel>> getDocuments({String? folder});
  Future<Either<Failure, void>> uploadDocument({
    required String name,
    required File file,
    String? folder,
  });
  Future<Either<Failure, void>> deleteDocument(int documentId);
}
