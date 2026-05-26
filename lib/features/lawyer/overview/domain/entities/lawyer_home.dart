import 'lawyer_booking.dart';
import 'package:hogga/features/lawyer/subscription/data/models/subscription_summary_model.dart';

class LawyerHome {
  final LawyerInfo lawyer;
  final LawyerOverview overview;
  final LawyerBooking? upcomingAppointment;
  final LawyerSettings settings;
  final SubscriptionSummary? subscriptionSummary;

  LawyerHome({
    required this.lawyer,
    required this.overview,
    this.upcomingAppointment,
    required this.settings,
    this.subscriptionSummary,
  });

  LawyerHome copyWith({
    LawyerInfo? lawyer,
    LawyerOverview? overview,
    LawyerBooking? upcomingAppointment,
    LawyerSettings? settings,
    SubscriptionSummary? subscriptionSummary,
  }) {
    return LawyerHome(
      lawyer: lawyer ?? this.lawyer,
      overview: overview ?? this.overview,
      upcomingAppointment: upcomingAppointment ?? this.upcomingAppointment,
      settings: settings ?? this.settings,
      subscriptionSummary: subscriptionSummary ?? this.subscriptionSummary,
    );
  }
}

class LawyerInfo {
  final int id;
  final String name;
  final String title;
  final String photo;

  LawyerInfo({
    required this.id,
    required this.name,
    required this.title,
    required this.photo,
  });
}

class LawyerOverview {
  final dynamic monthlyIncome;
  final int ongoingCases;
  final dynamic rating;
  final int totalBookings;

  LawyerOverview({
    required this.monthlyIncome,
    required this.ongoingCases,
    required this.rating,
    required this.totalBookings,
  });
}

class LawyerSettings {
  final bool acceptTextConsultations;
  final bool acceptInstantConsultations;
  final bool acceptServices;
  final bool isActive;

  LawyerSettings({
    required this.acceptTextConsultations,
    required this.acceptInstantConsultations,
    required this.acceptServices,
    required this.isActive,
  });

  LawyerSettings copyWith({
    bool? acceptTextConsultations,
    bool? acceptInstantConsultations,
    bool? acceptServices,
    bool? isActive,
  }) {
    return LawyerSettings(
      acceptTextConsultations: acceptTextConsultations ?? this.acceptTextConsultations,
      acceptInstantConsultations: acceptInstantConsultations ?? this.acceptInstantConsultations,
      acceptServices: acceptServices ?? this.acceptServices,
      isActive: isActive ?? this.isActive,
    );
  }
}
