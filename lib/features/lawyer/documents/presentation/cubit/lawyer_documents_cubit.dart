import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/lawyer/documents/domain/repositories/documents_repository.dart';
import 'package:hogga/features/lawyer/documents/data/models/lawyer_document_model.dart';

abstract class LawyerDocumentsState {}

class LawyerDocumentsInitial extends LawyerDocumentsState {}

class LawyerDocumentsLoading extends LawyerDocumentsState {}

class LawyerDocumentsLoaded extends LawyerDocumentsState {
  final LawyerDocumentsResponseModel response;
  LawyerDocumentsLoaded({required this.response});
}

class LawyerDocumentsError extends LawyerDocumentsState {
  final String message;
  LawyerDocumentsError({required this.message});
}

class LawyerDocumentActionSuccess extends LawyerDocumentsState {}

class LawyerDocumentsCubit extends Cubit<LawyerDocumentsState> {
  final DocumentsRepository repository;
  String? currentFolder;

  LawyerDocumentsCubit({required this.repository})
    : super(LawyerDocumentsInitial());

  Future<void> fetchDocuments({String? folder}) async {
    currentFolder = folder;
    emit(LawyerDocumentsLoading());
    final result = await repository.getDocuments(folder: folder);
    result.fold(
      (failure) => emit(LawyerDocumentsError(message: failure.message)),
      (response) => emit(LawyerDocumentsLoaded(response: response)),
    );
  }

  Future<void> uploadDocument({
    required String name,
    required File file,
    String? folder,
  }) async {
    final result = await repository.uploadDocument(
      name: name,
      file: file,
      folder: folder,
    );
    result.fold(
      (failure) => emit(LawyerDocumentsError(message: failure.message)),
      (_) async {
        emit(LawyerDocumentActionSuccess());
        await fetchDocuments(folder: folder);
      },
    );
  }

  Future<void> deleteDocument(int documentId) async {
    final result = await repository.deleteDocument(documentId);
    result.fold(
      (failure) => emit(LawyerDocumentsError(message: failure.message)),
      (_) {
        emit(LawyerDocumentActionSuccess());
        fetchDocuments(folder: currentFolder);
      },
    );
  }
}
