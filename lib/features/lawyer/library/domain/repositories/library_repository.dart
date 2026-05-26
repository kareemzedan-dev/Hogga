import 'package:dartz/dartz.dart';
import '../../../../../../core/errors/failures.dart';
import 'package:hogga/features/lawyer/library/data/models/lawyer_library_model.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<LawyerLibraryItemModel>>> searchLibrary(String query);
  Future<Either<Failure, List<LawyerLibraryArticleModel>>> getCategoryArticles(int categoryId);
  Future<Either<Failure, LawyerLibraryArticleDetailsModel>> getArticleDetails(int articleId);
}
