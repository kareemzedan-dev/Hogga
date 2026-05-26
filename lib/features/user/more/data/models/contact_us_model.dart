class ContactUsModel {
  final bool status;
  final ContactData? data;

  ContactUsModel({required this.status, this.data});

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      status: json['status'] ?? false,
      data: json['data'] != null ? ContactData.fromJson(json['data']) : null,
    );
  }
}

class ContactData {
  final String phone;
  final String email;
  final String workingHours;
  final Map<String, String> socialMedia;

  ContactData({
    required this.phone,
    required this.email,
    required this.workingHours,
    required this.socialMedia,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    Map<String, String> social = {};
    if (json['social_media'] != null) {
      (json['social_media'] as Map<String, dynamic>).forEach((key, value) {
        social[key] = value.toString();
      });
    }
    return ContactData(
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      workingHours: json['working_hours']?.toString() ?? '',
      socialMedia: social,
    );
  }
}
