import 'package:equatable/equatable.dart';
import 'package:hogga/features/lawyer/services/domain/entities/lawyer_service.dart';

class LawyerServiceDetails extends Equatable {
  final LawyerService service;
  final LawyerServiceStatistics statistics;
  final List<dynamic> purchases; // Can be modeled later if needed

  const LawyerServiceDetails({
    required this.service,
    required this.statistics,
    required this.purchases,
  });

  @override
  List<Object?> get props => [service, statistics, purchases];
}

class LawyerServiceStatistics extends Equatable {
  final int totalPurchases;
  final int pendingPurchases;
  final int completedPurchases;
  final double totalIncome;

  const LawyerServiceStatistics({
    required this.totalPurchases,
    required this.pendingPurchases,
    required this.completedPurchases,
    required this.totalIncome,
  });

  @override
  List<Object?> get props => [totalPurchases, pendingPurchases, completedPurchases, totalIncome];
}
