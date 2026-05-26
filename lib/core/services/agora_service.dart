import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  late RtcEngine _engine;
  final String appId = 'YOUR_AGORA_APP_ID'; // Placeholder

  Future<void> initialize(
      {required void Function(int uid, int elapsed) onUserJoined,
      required void Function(int uid, UserOfflineReasonType reason) onUserOffline}) async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid:${connection.localUid} joined the channel");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          onUserJoined(remoteUid, elapsed);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user uid:$remoteUid left the channel");
          onUserOffline(remoteUid, reason);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
  }

  Future<void> joinChannel(String channelName, String? token) async {
    await _engine.joinChannel(
      token: token ?? '',
      channelId: channelName,
      uid: 0, // 0 allows Agora to assign an ID automatically
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> toggleMute(bool isMuted) async {
    await _engine.muteLocalAudioStream(isMuted);
  }

  Future<void> toggleCamera(bool isCameraOff) async {
    await _engine.muteLocalVideoStream(isCameraOff);
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
    await _engine.release();
  }
}
