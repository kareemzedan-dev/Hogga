import 'package:equatable/equatable.dart';

class LawyerClient extends Equatable {
  final int id;
  final String name;
  final String? photo;
  final String? phone;
  final int activeCasesCount;
  final String? activeCasesText;
  final String? serviceType;
  final int? chatRoomId;
  final int? caseId;

  const LawyerClient({
    required this.id,
    required this.name,
    this.photo,
    this.phone,
    required this.activeCasesCount,
    this.activeCasesText,
    this.serviceType,
    this.chatRoomId,
    this.caseId,
  });

  bool get hasChatRoom => chatRoomId != null && chatRoomId! > 0;

  bool get canOpenChat => hasChatRoom && serviceType == 'chat';

  bool get canOpenCall =>
      hasChatRoom &&
      (serviceType == 'video' ||
          serviceType == 'audio' ||
          serviceType == 'phone');

  bool get hasCommunicationAction => canOpenChat || canOpenCall;

  @override
  List<Object?> get props => [
    id,
    name,
    photo,
    phone,
    activeCasesCount,
    activeCasesText,
    serviceType,
    chatRoomId,
    caseId,
  ];
}
