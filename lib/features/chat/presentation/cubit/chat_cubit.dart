import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/message_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SocketService _socketService;
  final String currentUserId;
  final String receiverId;

  ChatCubit({
    required SocketService socketService,
    required this.currentUserId,
    required this.receiverId,
  })  : _socketService = socketService,
        super(ChatInitial());

  void initConnection(String url) {
    emit(ChatLoading());
    try {
      _socketService.onMessageReceived = (data) {
        final newMessage = MessageModel.fromJson(data, currentUserId);
        _addMessageToState(newMessage);
      };
      
      _socketService.connect(url, currentUserId);

      // Here you would typically fetch previous messages via API if pagination was requested
      // For now, we emit an empty loaded state ready to receive/send real-time messages.
      emit(const ChatLoaded([]));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _addMessageToState(MessageModel message) {
    if (state is ChatLoaded) {
      final currentMessages = List<MessageModel>.from((state as ChatLoaded).messages);
      currentMessages.insert(0, message); // Insert at 0 for reversed ListView
      emit(ChatLoaded(currentMessages));
    }
  }

  void sendMessage(String text, {String? attachmentUrl, AttachmentType attachmentType = AttachmentType.none}) {
    if (text.trim().isEmpty && attachmentUrl == null) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID until backend confirms
      text: text,
      isMe: true,
      createdAt: DateTime.now(),
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
    );

    // Optimistically add to UI
    _addMessageToState(message);

    // Send to backend via Socket
    _socketService.sendMessage(message.toJson(currentUserId, receiverId));
  }

  @override
  Future<void> close() {
    _socketService.disconnect();
    return super.close();
  }
}
