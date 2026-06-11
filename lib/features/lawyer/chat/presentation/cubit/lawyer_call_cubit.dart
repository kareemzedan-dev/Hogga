import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/lawyer_chat_repository.dart';
import '../../../../chat/data/models/call_token_model.dart';
import '../../../../chat/presentation/cubit/call_cubit.dart';

class LawyerCallCubit extends Cubit<CallState> {
  final LawyerChatRepository repository;

  LawyerCallCubit({required this.repository}) : super(CallInitial());

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
      // Non-fatal
    }
  }

  Future<void> endCall(int callId) async {
    try {
      await repository.endCall(callId);
    } catch (e) {
      // Ignored
    } finally {
      emit(CallEnded());
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
