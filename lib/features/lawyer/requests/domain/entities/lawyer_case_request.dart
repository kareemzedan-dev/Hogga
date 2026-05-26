import 'package:equatable/equatable.dart';

class LawyerCaseRequest extends Equatable {
  final int id;
  final String title;
  final String statusKey;
  final String statusText;
  final String date;
  final String time;

  const LawyerCaseRequest({
    required this.id,
    required this.title,
    required this.statusKey,
    required this.statusText,
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [id, title, statusKey, statusText, date, time];
}
