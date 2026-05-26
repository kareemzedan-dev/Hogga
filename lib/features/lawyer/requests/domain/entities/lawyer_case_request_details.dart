import 'package:equatable/equatable.dart';

class LawyerCaseRequestDetails extends Equatable {
  final int id;
  final String serviceName;
  final String price;
  final String statusText;
  final String? description;
  final LawyerRequestClient client;
  final LawyerRequestAppointment appointment;

  const LawyerCaseRequestDetails({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.statusText,
    this.description,
    required this.client,
    required this.appointment,
  });

  @override
  List<Object?> get props => [id, serviceName, price, statusText, description, client, appointment];
}

class LawyerRequestClient extends Equatable {
  final String name;
  final String status;
  final String? photo;

  const LawyerRequestClient({
    required this.name,
    required this.status,
    this.photo,
  });

  @override
  List<Object?> get props => [name, status, photo];
}

class LawyerRequestAppointment extends Equatable {
  final String date;
  final String time;

  const LawyerRequestAppointment({
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [date, time];
}
