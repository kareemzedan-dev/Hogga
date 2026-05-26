import 'package:hogga/features/lawyer/proposals/domain/entities/lawyer_proposal.dart';

class LawyerProposalModel extends LawyerProposal {
  const LawyerProposalModel({
    required super.id,
    required super.price,
    required super.description,
    required super.status,
    super.createdAt,
    required super.legalCase,
  });

  factory LawyerProposalModel.fromJson(Map<String, dynamic> json) {
    return LawyerProposalModel(
      id: json['id'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'],
      legalCase: LawyerProposalCaseModel.fromJson(json['legal_case'] ?? {}),
    );
  }
}

class LawyerProposalCaseModel extends LawyerProposalCase {
  const LawyerProposalCaseModel({
    required super.id,
    required super.caseNumber,
    required super.title,
    required super.categoryName,
    super.minPrice,
    super.maxPrice,
  });

  factory LawyerProposalCaseModel.fromJson(Map<String, dynamic> json) {
    return LawyerProposalCaseModel(
      id: json['id'] ?? 0,
      caseNumber: json['case_number'] ?? '',
      title: json['title'] ?? '',
      categoryName: json['category_name'] ?? '',
      minPrice: json['min_price']?.toString(),
      maxPrice: json['max_price']?.toString(),
    );
  }
}
