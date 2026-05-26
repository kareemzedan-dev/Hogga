class BannerResponseModel {
  final List<BannerModel> data;

  const BannerResponseModel({
    required this.data,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      data: (json['banners'] as List? ?? json['data'] as List? ?? [])
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


class BannerModel {
  final String? titleAr;
  final String? titleEn;
  final String imageUrl;

  const BannerModel({
    this.titleAr,
    this.titleEn,
    required this.imageUrl,
  });

  String? localizedTitle(String languageCode) {
    if (languageCode == 'ar') return titleAr;
    return titleEn;
  }

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final titleRaw = json['title'];
    String? titleAr;
    String? titleEn;
    if (titleRaw is Map) {
      titleAr = titleRaw['ar'] as String?;
      titleEn = titleRaw['en'] as String?;
    } else if (titleRaw is String) {
      titleAr = titleRaw;
      titleEn = titleRaw;
    }
    return BannerModel(
      titleAr: titleAr,
      titleEn: titleEn,
      imageUrl: (json['image_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': {'ar': titleAr, 'en': titleEn},
      'image_url': imageUrl,
    };
  }
}
