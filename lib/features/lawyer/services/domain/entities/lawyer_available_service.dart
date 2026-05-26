import 'package:equatable/equatable.dart';

class LawyerAvailableService extends Equatable {
  final int id;
  final String title;
  final String? minPrice;
  final String? maxPrice;
  final String categoryItemName;
  final int proposalsCount;
  final String createdAt;

  const LawyerAvailableService({
    required this.id,
    required this.title,
    this.minPrice,
    this.maxPrice,
    required this.categoryItemName,
    required this.proposalsCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, minPrice, maxPrice, categoryItemName, proposalsCount, createdAt];
}
