import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/agora_service.dart';
import '../../data/models/call_model.dart';
import 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final AgoraService _agoraService;
  Timer? _timer;
  int _remainingSeconds = 0;

  CallCubit(this._agoraService) : super(CallInitial());

  Future<void> startCall(CallModel call) async {
    emit(CallConnecting());
    try {
      await _agoraService.initialize(
        onUserJoined: (uid, elapsed) {
          if (state is CallConnecting) {
             _remainingSeconds = call.durationInSeconds;
             emit(CallConnected(remoteUid: uid, remainingSeconds: _remainingSeconds));
             _startTimer();
          } else if (state is CallConnected) {
             emit((state as CallConnected).copyWith(remoteUid: uid));
          }
        },
        onUserOffline: (uid, reason) {
          endCall();
        },
      );

      await _agoraService.joinChannel(call.channelName, call.token);
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        if (state is CallConnected) {
          emit((state as CallConnected).copyWith(remainingSeconds: _remainingSeconds));
        }
      } else {
        endCall(); // Duration expired
      }
    });
  }

  void toggleMute() {
    if (state is CallConnected) {
      final currentState = state as CallConnected;
      final newMuteState = !currentState.isMuted;
      _agoraService.toggleMute(newMuteState);
      emit(currentState.copyWith(isMuted: newMuteState));
    }
  }

  void toggleCamera() {
    if (state is CallConnected) {
      final currentState = state as CallConnected;
      final newCameraState = !currentState.isCameraOff;
      _agoraService.toggleCamera(newCameraState);
      emit(currentState.copyWith(isCameraOff: newCameraState));
    }
  }

  Future<void> endCall() async {
    _timer?.cancel();
    await _agoraService.leaveChannel();
    emit(CallDisconnected());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _agoraService.leaveChannel();
    return super.close();
  }
}
