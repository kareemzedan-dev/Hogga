import 'banners_model.dart';
import 'categories_model.dart';

class HomeModel {
  final List<BannerModel> banners;
  final List<Category> categories;

  HomeModel({
    required this.banners,
    required this.categories,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return HomeModel(
      banners: (data['banners'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],
      categories: (data['categories'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
    );
  }
}
