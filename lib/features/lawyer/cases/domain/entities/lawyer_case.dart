import 'package:equatable/equatable.dart';

class LawyerCase extends Equatable {
  final int id;
  final int caseNumber;
  final String realCaseNumber;
  final String title;
  final String statusKey;
  final String statusText;
  final String date;
  final String? court;
  final String? descriptionSnippet;
  final String clientName;

  const LawyerCase({
    required this.id,
    required this.caseNumber,
    required this.realCaseNumber,
    required this.title,
    required this.statusKey,
    required this.statusText,
    required this.date,
    this.court,
    this.descriptionSnippet,
    required this.clientName,
  });

  @override
  List<Object?> get props => [
        id,
        caseNumber,
        realCaseNumber,
        title,
        statusKey,
        statusText,
        date,
        court,
        descriptionSnippet,
        clientName,
      ];
}
