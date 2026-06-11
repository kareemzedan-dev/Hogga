import '../../data/models/chat_message_model.dart';

abstract class ChatMessagesState {}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<ChatMessageModel> messages;
  final bool hasMore;
  final bool isSending;
  final bool isLoadingMore;
  final CounterpartyModel? counterparty;

  ChatMessagesLoaded({
    required this.messages,
    this.hasMore = false,
    this.isSending = false,
    this.isLoadingMore = false,
    this.counterparty,
  });

  ChatMessagesLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? hasMore,
    bool? isSending,
    bool? isLoadingMore,
    CounterpartyModel? counterparty,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      counterparty: counterparty ?? this.counterparty,
    );
  }
}

class ChatMessagesError extends ChatMessagesState {
  final String message;
  ChatMessagesError(this.message);
}
