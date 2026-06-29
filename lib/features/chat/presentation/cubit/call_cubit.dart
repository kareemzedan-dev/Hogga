import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/call_token_model.dart';

abstract class CallState {}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallTokenLoaded extends CallState {
  final CallTokenModel callToken;
  CallTokenLoaded(this.callToken);
}

class CallConnected extends CallState {
  final CallTokenModel callToken;
  CallConnected(this.callToken);
}

class CallEnded extends CallState {
  final int usedSeconds;
  CallEnded({this.usedSeconds = 0});
}

class CallError extends CallState {
  final String message;
  CallError(this.message);
}

class CallCubit extends Cubit<CallState> {
  final ChatRepository repository;

  CallCubit({required this.repository}) : super(CallInitial());

  Future<void> fetchCallToken(int roomId) async {
    emit(CallLoading());
    try {
      final token = await repository.getCallToken(roomId);
      emit(CallTokenLoaded(token));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> connectCall(CallTokenModel callToken) async {
    try {
      await repository.connectCall(callToken.callId);
      emit(CallConnected(callToken));
    } catch (e) {
      // Non-fatal, just log or ignore
    }
  }

  Future<void> endCall(int callId) async {
    int usedSeconds = 0;
    try {
      usedSeconds = await repository.endCall(callId);
    } catch (e) {
      // Ignored
    } finally {
      emit(CallEnded(usedSeconds: usedSeconds));
    }
  }

  Future<void> updateCallStatus(int callId, String status) async {
    try {
      await repository.updateCallStatus(callId, status);
    } catch (e) {
      // Ignored
    }
  }
}
