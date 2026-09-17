import 'package:equatable/equatable.dart';

class LawyerProposal extends Equatable {
  final int id;
  final String price;
  final String description;
  final String status;
  final String? createdAt;
  final LawyerProposalCase legalCase;

  const LawyerProposal({
    required this.id,
    required this.price,
    required this.description,
    required this.status,
    this.createdAt,
    required this.legalCase,
  });

  @override
  List<Object?> get props => [id, price, description, status, createdAt, legalCase];
}

class LawyerProposalCase extends Equatable {
  final int id;
  final String caseNumber;
  final String title;
  final String categoryName;
  final String? serviceType;
  final String? minPrice;
  final String? maxPrice;

  const LawyerProposalCase({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.categoryName,
    this.serviceType,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
    id,
    caseNumber,
    title,
    categoryName,
    serviceType,
    minPrice,
    maxPrice,
  ];
}
