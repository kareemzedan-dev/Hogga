import '../../data/models/chat_room_model.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatRoomModel> rooms;
  ChatListLoaded(this.rooms);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}
