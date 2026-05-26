import 'package:equatable/equatable.dart';

class LawyerCategoryItem extends Equatable {
  final int id;
  final String name;
  final String description;
  final double? suggestedPrice;
  final int? categoriesChildId;

  const LawyerCategoryItem({
    required this.id,
    required this.name,
    required this.description,
    this.suggestedPrice,
    this.categoriesChildId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        suggestedPrice,
        categoriesChildId,
      ];
}
