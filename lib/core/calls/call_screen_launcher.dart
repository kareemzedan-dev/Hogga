import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/features/chat/presentation/cubit/call_cubit.dart';
import 'package:hogga/features/chat/presentation/pages/agora_call_screen.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/injection_container.dart' as di;

final Set<int> _activeIncomingCallRouteKeys = <int>{};

int _incomingCallRouteKey(IncomingCallPayload payload) {
  if (payload.callId > 0) {
    return payload.callId;
  }
  return -payload.chatRoomId;
}

bool isIncomingAgoraCallRouteActive(IncomingCallPayload payload) {
  return _activeIncomingCallRouteKeys.contains(_incomingCallRouteKey(payload));
}

Future<void> pushIncomingAgoraCall({
  required NavigatorState navigator,
  required IncomingCallPayload payload,
}) async {
  final routeKey = _incomingCallRouteKey(payload);
  if (!_activeIncomingCallRouteKeys.add(routeKey)) {
    return;
  }

  final isProvider = AppPreferences().isProvider;

  try {
    if (isProvider) {
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: payload.chatRoomId,
              clientName: payload.callerName,
              isVideo: payload.isVideo,
              isIncoming: true,
            ),
          ),
        ),
      );
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<CallCubit>(),
          child: AgoraCallScreen(
            roomId: payload.chatRoomId,
            lawyerName: payload.callerName,
            isIncoming: true,
          ),
        ),
      ),
    );
  } finally {
    _activeIncomingCallRouteKeys.remove(routeKey);
  }
}
