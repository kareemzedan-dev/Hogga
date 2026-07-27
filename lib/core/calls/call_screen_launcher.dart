import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/features/chat/presentation/cubit/call_cubit.dart';
import 'package:hogga/features/chat/presentation/pages/agora_call_screen.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/injection_container.dart' as di;

Future<void> pushIncomingAgoraCall({
  required NavigatorState navigator,
  required IncomingCallPayload payload,
}) {
  final isProvider = AppPreferences().isProvider;

  if (isProvider) {
    return navigator.push(
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
  }

  return navigator.push(
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
}
