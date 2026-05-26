import 'package:equatable/equatable.dart';

class LawyerClient extends Equatable {
  final int id;
  final String name;
  final String? photo;
  final String? phone;
  final int activeCasesCount;
  final String? activeCasesText;

  const LawyerClient({
    required this.id,
    required this.name,
    this.photo,
    this.phone,
    required this.activeCasesCount,
    this.activeCasesText,
  });

  @override
  List<Object?> get props => [id, name, photo, phone, activeCasesCount, activeCasesText];
}
