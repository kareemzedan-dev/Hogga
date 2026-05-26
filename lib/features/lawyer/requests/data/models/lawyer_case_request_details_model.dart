import 'package:hogga/features/lawyer/requests/domain/entities/lawyer_case_request_details.dart';

class LawyerCaseRequestDetailsModel extends LawyerCaseRequestDetails {
  const LawyerCaseRequestDetailsModel({
    required super.id,
    required super.serviceName,
    required super.price,
    required super.statusText,
    super.description,
    required super.client,
    required super.appointment,
  });

  factory LawyerCaseRequestDetailsModel.fromJson(Map<String, dynamic> json) {
    return LawyerCaseRequestDetailsModel(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      price: json['price'] ?? '',
      statusText: json['status_text'] ?? '',
      description: json['description'],
      client: LawyerRequestClientModel.fromJson(json['client'] ?? {}),
      appointment: LawyerRequestAppointmentModel.fromJson(json['appointment'] ?? {}),
    );
  }
}

class LawyerRequestClientModel extends LawyerRequestClient {
  const LawyerRequestClientModel({
    required super.name,
    required super.status,
    super.photo,
  });

  factory LawyerRequestClientModel.fromJson(Map<String, dynamic> json) {
    return LawyerRequestClientModel(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      photo: json['photo'],
    );
  }
}

class LawyerRequestAppointmentModel extends LawyerRequestAppointment {
  const LawyerRequestAppointmentModel({
    required super.date,
    required super.time,
  });

  factory LawyerRequestAppointmentModel.fromJson(Map<String, dynamic> json) {
    return LawyerRequestAppointmentModel(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
