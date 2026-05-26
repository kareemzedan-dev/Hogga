import 'package:equatable/equatable.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallConnecting extends CallState {}

class CallConnected extends CallState {
  final int remoteUid;
  final bool isMuted;
  final bool isCameraOff;
  final int remainingSeconds;

  const CallConnected({
    required this.remoteUid,
    this.isMuted = false,
    this.isCameraOff = false,
    required this.remainingSeconds,
  });

  CallConnected copyWith({
    int? remoteUid,
    bool? isMuted,
    bool? isCameraOff,
    int? remainingSeconds,
  }) {
    return CallConnected(
      remoteUid: remoteUid ?? this.remoteUid,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [remoteUid, isMuted, isCameraOff, remainingSeconds];
}

class CallDisconnected extends CallState {}

class CallError extends CallState {
  final String message;
  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
