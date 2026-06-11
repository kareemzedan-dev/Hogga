import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/lawyer_chat_repository.dart';
import 'lawyer_chat_list_state.dart';

class LawyerChatListCubit extends Cubit<LawyerChatListState> {
  final LawyerChatRepository repository;

  LawyerChatListCubit({required this.repository}) : super(LawyerChatListInitial());

  Future<void> fetchChatRooms() async {
    emit(LawyerChatListLoading());
    try {
      final rooms = await repository.getChatRooms();
      emit(LawyerChatListLoaded(rooms));
    } catch (e) {
      emit(LawyerChatListError(e.toString()));
    }
  }
}
