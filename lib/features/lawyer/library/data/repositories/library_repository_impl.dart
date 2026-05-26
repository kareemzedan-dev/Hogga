import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/library/domain/repositories/library_repository.dart';
import 'package:hogga/features/lawyer/library/data/datasources/library_remote_data_source.dart';
import 'package:hogga/features/lawyer/library/data/models/lawyer_library_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LawyerLibraryItemModel>>> searchLibrary(String query) async {
    try {
      final remoteData = await remoteDataSource.searchLibrary(query);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LawyerLibraryArticleModel>>> getCategoryArticles(int categoryId) async {
    try {
      final remoteData = await remoteDataSource.getCategoryArticles(categoryId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LawyerLibraryArticleDetailsModel>> getArticleDetails(int articleId) async {
    try {
      final remoteData = await remoteDataSource.getArticleDetails(articleId);
      return Right(remoteData);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
