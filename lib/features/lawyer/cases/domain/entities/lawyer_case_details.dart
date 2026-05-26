import 'package:equatable/equatable.dart';

class LawyerCaseDetails extends Equatable {
  final int id;
  final String title;
  final String caseNumber;
  final String statusKey;
  final String statusText;
  final LawyerCaseClient client;
  final LawyerCaseSessions sessions;
  final List<LawyerCaseDocument> documents;

  const LawyerCaseDetails({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.statusKey,
    required this.statusText,
    required this.client,
    required this.sessions,
    required this.documents,
  });

  @override
  List<Object?> get props => [id, title, caseNumber, statusKey, statusText, client, sessions, documents];
}

class LawyerCaseClient extends Equatable {
  final String name;
  final String? phone;
  final String? photo;

  const LawyerCaseClient({
    required this.name,
    this.phone,
    this.photo,
  });

  @override
  List<Object?> get props => [name, phone, photo];
}

class LawyerCaseSessions extends Equatable {
  final List<LawyerCaseSession> upcoming;
  final List<LawyerCaseSession> previous;

  const LawyerCaseSessions({
    required this.upcoming,
    required this.previous,
  });

  @override
  List<Object?> get props => [upcoming, previous];
}

class LawyerCaseSession extends Equatable {
  final int id;
  final String title;
  final String date;
  final String details;
  final bool isUpcoming;

  const LawyerCaseSession({
    required this.id,
    required this.title,
    required this.date,
    required this.details,
    required this.isUpcoming,
  });

  @override
  List<Object?> get props => [id, title, date, details, isUpcoming];
}

class LawyerCaseDocument extends Equatable {
  final int id;
  final String name;
  final String url;
  final String type;
  final String addedBy;

  const LawyerCaseDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [id, name, url, type, addedBy];
}
