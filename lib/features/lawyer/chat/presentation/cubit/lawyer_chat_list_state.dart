import '../../../../chat/data/models/chat_room_model.dart';

abstract class LawyerChatListState {}

class LawyerChatListInitial extends LawyerChatListState {}

class LawyerChatListLoading extends LawyerChatListState {}

class LawyerChatListLoaded extends LawyerChatListState {
  final List<ChatRoomModel> rooms;
  LawyerChatListLoaded(this.rooms);
}

class LawyerChatListError extends LawyerChatListState {
  final String message;
  LawyerChatListError(this.message);
}
