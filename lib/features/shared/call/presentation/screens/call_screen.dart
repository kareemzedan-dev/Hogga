import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:hogga/core/services/agora_service.dart';
import 'package:hogga/core/theme/app_theme.dart';
import '../../data/models/call_model.dart';
import '../bloc/call_cubit.dart';
import '../bloc/call_state.dart';

class CallScreen extends StatelessWidget {
  final CallModel callModel;

  const CallScreen({Key? key, required this.callModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CallCubit(AgoraService())..startCall(callModel),
      child: const _CallScreenContent(),
    );
  }
}

class _CallScreenContent extends StatelessWidget {
  const _CallScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<CallCubit, CallState>(
          listener: (context, state) {
            if (state is CallDisconnected) {
              Navigator.of(context).pop();
            } else if (state is CallConnected) {
              if (state.remainingSeconds == 60) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Warning: 1 minute remaining in the call!'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } else if (state is CallError) {
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
               Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is CallConnecting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (state is CallConnected) {
              final cubit = context.read<CallCubit>();
              return Stack(
                children: [
                  // Remote Video
                  _buildRemoteVideo(state.remoteUid, context),
                  // Local Video (floating)
                  if (!state.isCameraOff)
                    Positioned(
                      top: 20,
                      right: 20,
                      width: 100,
                      height: 150,
                      child: _buildLocalVideo(),
                    ),
                  // Call Info & Timer
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.cardBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.divColor),
                      ),
                      child: Text(
                        _formatDuration(state.remainingSeconds),
                        style: TextStyle(
                          color: context.textPrimary, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Control Panel
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          heroTag: 'camera',
                          onPressed: () => cubit.toggleCamera(),
                          backgroundColor: state.isCameraOff ? context.colors.error : context.colors.surface,
                          child: Icon(state.isCameraOff ? Icons.videocam_off : Icons.videocam, color: state.isCameraOff ? context.colors.onError : context.iconColor),
                        ),
                        FloatingActionButton(
                          heroTag: 'end',
                          onPressed: () => cubit.endCall(),
                          backgroundColor: context.colors.error,
                          child: Icon(Icons.call_end, color: context.colors.onError),
                        ),
                        FloatingActionButton(
                          heroTag: 'mic',
                          onPressed: () => cubit.toggleMute(),
                          backgroundColor: state.isMuted ? context.colors.error : context.colors.surface,
                          child: Icon(state.isMuted ? Icons.mic_off : Icons.mic, color: state.isMuted ? context.colors.onError : context.iconColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(int uid, BuildContext context) {
    if (uid == 0) {
      return const Center(
        child: Text(
          'Waiting for user to join...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: createAgoraRtcEngine(),
          canvas: VideoCanvas(uid: uid),
          connection: const RtcConnection(channelId: ''), // Needs to match joined channel if using multiple channels
        ),
      );
    }
  }

  Widget _buildLocalVideo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: createAgoraRtcEngine(),
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
