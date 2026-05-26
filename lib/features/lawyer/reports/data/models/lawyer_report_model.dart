class LawyerReportModel {
  final String period;
  final List<IncomeChartItemModel> incomeChart;
  final ActivitySummaryModel activitySummary;
  final SatisfactionModel satisfaction;

  LawyerReportModel({
    required this.period,
    required this.incomeChart,
    required this.activitySummary,
    required this.satisfaction,
  });

  factory LawyerReportModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return LawyerReportModel(
      period: json['period']?.toString() ?? '',
      incomeChart: (data['income_chart'] as List<dynamic>? ?? [])
          .map((item) => IncomeChartItemModel.fromJson(item as Map<String, dynamic>? ?? {}))
          .toList(),
      activitySummary: ActivitySummaryModel.fromJson((data['activity_summary'] as Map<String, dynamic>?) ?? {}),
      satisfaction: SatisfactionModel.fromJson((data['satisfaction'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

class IncomeChartItemModel {
  final String label;
  final dynamic value;

  IncomeChartItemModel({
    required this.label,
    required this.value,
  });

  factory IncomeChartItemModel.fromJson(Map<String, dynamic> json) {
    dynamic val = json['value'];
    if (val is String) {
      val = double.tryParse(val) ?? 0.0;
    }
    return IncomeChartItemModel(
      label: json['label']?.toString() ?? '',
      value: val ?? 0,
    );
  }
}

class ActivitySummaryModel {
  final int totalConsultations;
  final int completedCases;

  ActivitySummaryModel({
    required this.totalConsultations,
    required this.completedCases,
  });

  factory ActivitySummaryModel.fromJson(Map<String, dynamic> json) {
    return ActivitySummaryModel(
      totalConsultations: (json['total_consultations'] as num?)?.toInt() ?? 0,
      completedCases: (json['completed_cases'] as num?)?.toInt() ?? 0,
    );
  }
}

class SatisfactionModel {
  final dynamic rating;
  final int totalReviews;
  final String formattedRating;

  SatisfactionModel({
    required this.rating,
    required this.totalReviews,
    required this.formattedRating,
  });

  factory SatisfactionModel.fromJson(Map<String, dynamic> json) {
    dynamic ratingVal = json['rating'];
    if (ratingVal is String) {
      ratingVal = double.tryParse(ratingVal) ?? 0.0;
    }
    return SatisfactionModel(
      rating: ratingVal ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      formattedRating: json['formatted_rating']?.toString() ?? '0/5.0',
    );
  }
}
