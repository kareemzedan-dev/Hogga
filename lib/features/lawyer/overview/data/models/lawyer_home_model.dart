import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_home.dart';
import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';
import 'package:hogga/features/lawyer/subscription/data/models/subscription_summary_model.dart';
import 'lawyer_booking_model.dart';

class LawyerHomeModel extends LawyerHome {
  LawyerHomeModel({
    required LawyerInfoModel super.lawyer,
    required LawyerOverviewModel super.overview,
    LawyerBookingModel? super.upcomingAppointment,
    required LawyerSettingsModel super.settings,
    super.subscriptionSummary,
    super.referralCampaign,
    super.freeConsultations,
  });

  factory LawyerHomeModel.fromJson(Map<String, dynamic> json) {
    return LawyerHomeModel(
      lawyer: LawyerInfoModel.fromJson(json['lawyer'] ?? {}),
      overview: LawyerOverviewModel.fromJson(json['overview'] ?? {}),
      upcomingAppointment: json['upcoming_appointment'] != null
          ? LawyerBookingModel.fromJson(json['upcoming_appointment'])
          : null,
      settings: LawyerSettingsModel.fromJson(json['settings'] ?? {}),
      subscriptionSummary:
          (json['subscription'] ?? json['subscription_summary']) != null
          ? SubscriptionSummary.fromJson(
              json['subscription'] ?? json['subscription_summary'],
            )
          : null,
      referralCampaign: json['referral_campaign'] != null
          ? ReferralCampaignModel.fromJson(json['referral_campaign'])
          : null,
      freeConsultations: json['free_consultations'] != null
          ? FreeConsultationsModel.fromJson(json['free_consultations'])
          : null,
    );
  }

  @override
  LawyerHomeModel copyWith({
    LawyerInfo? lawyer,
    LawyerOverview? overview,
    LawyerBooking? upcomingAppointment,
    LawyerSettings? settings,
    SubscriptionSummary? subscriptionSummary,
    ReferralCampaign? referralCampaign,
    FreeConsultations? freeConsultations,
  }) {
    return LawyerHomeModel(
      lawyer: (lawyer as LawyerInfoModel?) ?? (this.lawyer as LawyerInfoModel),
      overview:
          (overview as LawyerOverviewModel?) ??
          (this.overview as LawyerOverviewModel),
      upcomingAppointment:
          (upcomingAppointment as LawyerBookingModel?) ??
          (this.upcomingAppointment as LawyerBookingModel?),
      settings:
          (settings as LawyerSettingsModel?) ??
          (this.settings as LawyerSettingsModel),
      subscriptionSummary: subscriptionSummary ?? this.subscriptionSummary,
      referralCampaign:
          (referralCampaign as ReferralCampaignModel?) ??
          (this.referralCampaign as ReferralCampaignModel?),
      freeConsultations:
          (freeConsultations as FreeConsultationsModel?) ??
          (this.freeConsultations as FreeConsultationsModel?),
    );
  }
}

class ReferralCampaignModel extends ReferralCampaign {
  ReferralCampaignModel({
    required super.status,
    required super.bonusAmount,
    required super.referralCode,
  });

  factory ReferralCampaignModel.fromJson(Map<String, dynamic> json) {
    return ReferralCampaignModel(
      status: json['status']?.toString() ?? 'off',
      bonusAmount: (json['bonus_amount'] is num)
          ? (json['bonus_amount'] as num).toDouble()
          : (double.tryParse(json['bonus_amount']?.toString() ?? '0') ?? 0.0),
      referralCode: json['referral_code']?.toString() ?? '',
    );
  }
}

class LawyerInfoModel extends LawyerInfo {
  LawyerInfoModel({
    required super.id,
    required super.name,
    required super.title,
    required super.photo,
  });

  factory LawyerInfoModel.fromJson(Map<String, dynamic> json) {
    return LawyerInfoModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class LawyerOverviewModel extends LawyerOverview {
  LawyerOverviewModel({
    required super.monthlyIncome,
    required super.ongoingCases,
    required super.rating,
    required super.totalBookings,
  });

  factory LawyerOverviewModel.fromJson(Map<String, dynamic> json) {
    return LawyerOverviewModel(
      monthlyIncome: json['monthly_income'] ?? 0,
      ongoingCases: json['ongoing_cases'] ?? 0,
      rating: json['rating'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
    );
  }
}

class LawyerSettingsModel extends LawyerSettings {
  LawyerSettingsModel({
    required super.acceptTextConsultations,
    required super.acceptInstantConsultations,
    super.acceptScheduledConsultations,
    required super.acceptServices,
    required super.isActive,
  });

  factory LawyerSettingsModel.fromJson(Map<String, dynamic> json) {
    return LawyerSettingsModel(
      acceptTextConsultations: json['accept_text_consultations'] == true,
      acceptInstantConsultations: json['accept_instant_consultations'] == true,
      acceptScheduledConsultations:
          json['accept_scheduled_consultations'] == true ||
          json['accept_scheduled_consultations'] == 1,
      acceptServices: json['accept_services'] == true,
      isActive: json['is_active'] == true,
    );
  }

  @override
  LawyerSettingsModel copyWith({
    bool? acceptTextConsultations,
    bool? acceptInstantConsultations,
    bool? acceptScheduledConsultations,
    bool? acceptServices,
    bool? isActive,
  }) {
    return LawyerSettingsModel(
      acceptTextConsultations:
          acceptTextConsultations ?? this.acceptTextConsultations,
      acceptInstantConsultations:
          acceptInstantConsultations ?? this.acceptInstantConsultations,
      acceptScheduledConsultations:
          acceptScheduledConsultations ?? this.acceptScheduledConsultations,
      acceptServices: acceptServices ?? this.acceptServices,
      isActive: isActive ?? this.isActive,
    );
  }
}

class FreeConsultationsModel extends FreeConsultations {
  FreeConsultationsModel({
    required super.lawyerPercentage,
    required super.limit,
    required super.used,
    required super.remaining,
  });

  factory FreeConsultationsModel.fromJson(Map<String, dynamic> json) {
    return FreeConsultationsModel(
      lawyerPercentage: (json['lawyer_percentage'] ?? 0).toDouble(),
      limit: json['free_consultations_limit'] ?? 0,
      used: json['free_consultations_used'] ?? 0,
      remaining: json['free_consultations_remaining'] ?? 0,
    );
  }
}
