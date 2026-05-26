import 'package:hogga/features/lawyer/overview/domain/entities/lawyer_booking.dart';

class LawyerBookingModel extends LawyerBooking {
  LawyerBookingModel({
    required super.id,
    required super.clientName,
    required super.date,
    required super.time,
    required super.status,
    required super.serviceName,
    required super.price,
  });

  factory LawyerBookingModel.fromJson(Map<String, dynamic> json) {
    return LawyerBookingModel(
      id: (json['id'] ?? '').toString(),
      clientName: json['client_name'] ?? json['clientName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      serviceName: json['service_name'] ?? json['serviceName'] ?? '',
      price: (json['price'] ?? '').toString(),
    );
  }
}
