import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository repository;

  ChatListCubit({required this.repository}) : super(ChatListInitial());

  Future<void> fetchChatRooms() async {
    emit(ChatListLoading());
    try {
      final rooms = await repository.getChatRooms();
      emit(ChatListLoaded(rooms));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
