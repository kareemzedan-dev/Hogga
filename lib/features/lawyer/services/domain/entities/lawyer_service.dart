import 'package:equatable/equatable.dart';

class LawyerService extends Equatable {
  final int id;
  final String name;
  final String description;
  final String price;
  final String priceStatus;
  final String status;
  final int categoriesItemId;
  final String categoriesItemName;
  final String createdAt;

  const LawyerService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceStatus,
    required this.status,
    required this.categoriesItemId,
    required this.categoriesItemName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, price, priceStatus, status, categoriesItemId, categoriesItemName, createdAt
  ];
}
