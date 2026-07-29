import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/shared/call/presentation/widgets/call_summary_dialog.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../chat/data/models/call_token_model.dart';
import '../../../../chat/presentation/cubit/call_cubit.dart';
import '../cubit/lawyer_call_cubit.dart';

class LawyerAgoraCallScreen extends StatefulWidget {
  final int roomId;
  final String clientName;
  final bool isVideo;
  final bool isIncoming;

  const LawyerAgoraCallScreen({
    super.key,
    required this.roomId,
    required this.clientName,
    this.isVideo = false,
    this.isIncoming = false,
  });

  @override
  State<LawyerAgoraCallScreen> createState() => _LawyerAgoraCallScreenState();
}

class _LawyerAgoraCallScreenState extends State<LawyerAgoraCallScreen> {
  static const Duration _connectionRecoveryTimeout = Duration(seconds: 30);
  static const Duration _remoteDropGracePeriod = Duration(seconds: 20);

  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _speaker = false;
  bool _videoEnabled = true;
  Timer? _callTimer;
  Timer? _ringingTimer;
  Timer? _connectionRecoveryTimer;
  Timer? _remoteDropTimer;
  int _callDuration = 0;
  bool _isEndingCall = false;
  bool _summaryShown = false;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    context.read<LawyerCallCubit>().fetchCallToken(widget.roomId);
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _ringingTimer?.cancel();
    _connectionRecoveryTimer?.cancel();
    _remoteDropTimer?.cancel();
    _disposeAgora();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _startTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  void _startRingingTimeout(int callId) {
    if (widget.isIncoming) {
      return;
    }

    _ringingTimer?.cancel();
    _ringingTimer = Timer(IncomingCallPayload.ringingTimeout, () {
      unawaited(_markCallMissed(callId));
    });
  }

  void _startConnectionRecovery(int callId) {
    if (_isEndingCall || !mounted) {
      return;
    }

    if (!_isReconnecting) {
      setState(() => _isReconnecting = true);
    }
    _connectionRecoveryTimer?.cancel();
    _connectionRecoveryTimer = Timer(_connectionRecoveryTimeout, () {
      if (_isReconnecting && !_isEndingCall && mounted) {
        _endCall(callId);
      }
    });
  }

  void _markConnectionRecovered() {
    _connectionRecoveryTimer?.cancel();
    if (_isReconnecting && mounted) {
      setState(() => _isReconnecting = false);
    }
  }

  void _handleRemoteOffline(
    int callId,
    UserOfflineReasonType reason,
  ) {
    if (_isEndingCall || !mounted) {
      return;
    }

    setState(() => _remoteUid = null);
    if (reason != UserOfflineReasonType.userOfflineDropped) {
      _endCall(callId);
      return;
    }

    _startConnectionRecovery(callId);
    _remoteDropTimer?.cancel();
    _remoteDropTimer = Timer(_remoteDropGracePeriod, () {
      if (_remoteUid == null && !_isEndingCall && mounted) {
        _endCall(callId);
      }
    });
  }

  Future<void> _markCallMissed(int callId) async {
    if (_remoteUid != null || _isEndingCall || !mounted) {
      return;
    }

    _isEndingCall = true;
    _connectionRecoveryTimer?.cancel();
    _remoteDropTimer?.cancel();
    final callCubit = context.read<LawyerCallCubit>();
    await callCubit.updateCallStatus(callId, 'missed');
    await _disposeAgora();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _disposeAgora() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
    }
  }

  Future<void> _initAgora(CallTokenModel callToken) async {
    await [Permission.microphone].request();
    if (callToken.isVideo) {
      await [Permission.camera].request();
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: callToken.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          if (!mounted) {
            return;
          }
          setState(() => _localUserJoined = true);
          context.read<LawyerCallCubit>().connectCall(callToken);
          _startRingingTimeout(callToken.callId);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _ringingTimer?.cancel();
          _remoteDropTimer?.cancel();
          _markConnectionRecovered();
          if (!mounted) {
            return;
          }
          setState(() => _remoteUid = remoteUid);
          if (_callTimer == null || !_callTimer!.isActive) {
            _startTimer();
          }
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              _handleRemoteOffline(callToken.callId, reason);
            },
        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
            ) {
              if (state == ConnectionStateType.connectionStateReconnecting) {
                _startConnectionRecovery(callToken.callId);
              } else if (state ==
                  ConnectionStateType.connectionStateConnected) {
                _markConnectionRecovered();
              } else if (state ==
                      ConnectionStateType.connectionStateFailed &&
                  !_isEndingCall) {
                _endCall(callToken.callId);
              }
            },
        onRejoinChannelSuccess:
            (RtcConnection connection, int elapsed) {
              _markConnectionRecovered();
            },
      ),
    );

    if (callToken.isVideo) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.enableAudio();
    }

    await _engine!.joinChannel(
      token: callToken.token,
      channelId: callToken.channelName,
      uid: callToken.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishMicrophoneTrack: true,
        publishCameraTrack: true,
      ),
    );
  }

  void _endCall(int callId) {
    if (_isEndingCall) {
      return;
    }

    _isEndingCall = true;
    _callTimer?.cancel();
    _ringingTimer?.cancel();
    _connectionRecoveryTimer?.cancel();
    _remoteDropTimer?.cancel();
    context.read<LawyerCallCubit>().endCall(callId);
  }

  String _callStatusText(BuildContext context) {
    if (_isReconnecting) {
      return AppStrings.reconnectingCall.tr(context);
    }
    if (_localUserJoined && _remoteUid != null) {
      return "${AppStrings.connected.tr(context)} ${_formatDuration(_callDuration)}";
    }
    return AppStrings.calling.tr(context);
  }

  void _showCallSummaryDialog(int usedSeconds) {
    if (_summaryShown || !mounted) {
      return;
    }

    _summaryShown = true;
    final effectiveSeconds = usedSeconds > 0 ? usedSeconds : _callDuration;
    showCallSummaryDialog(
      context: context,
      usedSeconds: effectiveSeconds,
      onDone: () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  void _onToggleMute() {
    setState(() => _muted = !_muted);
    _engine?.muteLocalAudioStream(_muted);
  }

  void _onToggleSpeaker() {
    setState(() => _speaker = !_speaker);
    _engine?.setEnableSpeakerphone(_speaker);
  }

  void _onToggleVideo() {
    setState(() => _videoEnabled = !_videoEnabled);
    _engine?.muteLocalVideoStream(!_videoEnabled);
  }

  void _onSwitchCamera() => _engine?.switchCamera();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LawyerCallCubit, CallState>(
      listener: (context, state) {
        if (state is CallTokenLoaded) {
          _initAgora(state.callToken);
        } else if (state is CallEnded) {
          _showCallSummaryDialog(state.usedSeconds);
        } else if (state is CallError) {
          AppSnackbar.showError(context, message: state.message);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (state is CallLoading || state is CallInitial) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.golden),
                  const SizedBox(height: 16),
                  Text(AppStrings.calling.tr(context)),
                ],
              ),
            ),
          );
        }

        final CallTokenModel? callToken = (state is CallTokenLoaded)
            ? state.callToken
            : (state is CallConnected)
            ? state.callToken
            : null;

        if (callToken == null) return const SizedBox();

        final isVideo = callToken.isVideo;

        return Scaffold(
          backgroundColor: isVideo ? Colors.black : context.pageBg,
          body: Stack(
            children: [
              // Background
              if (isVideo) ...[
                if (_remoteUid != null)
                  AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(
                        channelId: callToken.channelName,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      AppStrings.waitingForClient.tr(context),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
              ] else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.pageBg,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.golden, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white12,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.clientName.isNotEmpty
                            ? widget.clientName
                            : AppStrings.client.tr(context),
                        style: context.text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _callStatusText(context),
                        style: const TextStyle(
                          color: AppColors.golden,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),

              // Local Video Preview
              if (isVideo && _localUserJoined && _videoEnabled)
                Positioned(
                  top: 60,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    ),
                  ),
                ),

              // Call Info Overlay (Video)
              if (isVideo)
                Positioned(
                  top: 60,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clientName,
                        style: context.text.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _callStatusText(context),
                        style: const TextStyle(color: AppColors.golden),
                      ),
                    ],
                  ),
                ),

              // Controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (isVideo)
                      _buildCallAction(
                        Icons.switch_camera,
                        AppStrings.switchCamera.tr(context),
                        onPressed: _onSwitchCamera,
                      )
                    else
                      _buildCallAction(
                        _speaker ? Icons.volume_up : Icons.volume_down,
                        AppStrings.speaker.tr(context),
                        onPressed: _onToggleSpeaker,
                      ),
                    _buildCallAction(
                      _muted ? Icons.mic_off : Icons.mic,
                      AppStrings.mute.tr(context),
                      onPressed: _onToggleMute,
                    ),
                    if (isVideo)
                      _buildCallAction(
                        _videoEnabled ? Icons.videocam : Icons.videocam_off,
                        AppStrings.video.tr(context),
                        onPressed: _onToggleVideo,
                      ),
                    _buildCallAction(
                      Icons.call_end,
                      AppStrings.end.tr(context),
                      color: Colors.red,
                      onPressed: () => _endCall(callToken.callId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallAction(
    IconData icon,
    String label, {
    Color color = Colors.white24,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
