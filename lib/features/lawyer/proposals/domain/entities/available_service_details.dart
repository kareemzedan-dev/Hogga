import 'package:equatable/equatable.dart';

class AvailableServiceDetails extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? minPrice;
  final String? maxPrice;
  final String? executionDate;
  final String categoryItemName;
  final AvailableServiceUser user;
  final int proposalsCount;
  final List<dynamic> documents;
  final List<dynamic> recentProposals;

  const AvailableServiceDetails({
    required this.id,
    required this.title,
    this.description,
    this.minPrice,
    this.maxPrice,
    this.executionDate,
    required this.categoryItemName,
    required this.user,
    required this.proposalsCount,
    required this.documents,
    required this.recentProposals,
  });

  @override
  List<Object?> get props => [id, title, description, minPrice, maxPrice, executionDate, categoryItemName, user, proposalsCount];
}

class AvailableServiceUser extends Equatable {
  final String name;
  final String? photo;

  const AvailableServiceUser({required this.name, this.photo});

  @override
  List<Object?> get props => [name, photo];
}
