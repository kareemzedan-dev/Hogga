class LawyerDocumentsResponseModel {
  final List<String> folders;
  final LawyerFilesPaginatedModel files;

  LawyerDocumentsResponseModel({
    required this.folders,
    required this.files,
  });

  factory LawyerDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    return LawyerDocumentsResponseModel(
      folders: List<String>.from(json['folders'] ?? []),
      files: LawyerFilesPaginatedModel.fromJson(json['files'] ?? {}),
    );
  }
}

class LawyerFilesPaginatedModel {
  final int currentPage;
  final List<LawyerFileModel> data;
  final int lastPage;
  final int total;

  LawyerFilesPaginatedModel({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory LawyerFilesPaginatedModel.fromJson(Map<String, dynamic> json) {
    return LawyerFilesPaginatedModel(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => LawyerFileModel.fromJson(item))
          .toList(),
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class LawyerFileModel {
  final int id;
  final String name;
  final String? folder;
  final String filePath;
  final String fileType;

  LawyerFileModel({
    required this.id,
    required this.name,
    this.folder,
    required this.filePath,
    required this.fileType,
  });

  factory LawyerFileModel.fromJson(Map<String, dynamic> json) {
    return LawyerFileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      folder: json['folder'],
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? '',
    );
  }
}
