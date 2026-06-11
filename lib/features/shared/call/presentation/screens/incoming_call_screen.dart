import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/features/chat/presentation/cubit/call_cubit.dart';
import 'package:hogga/features/chat/presentation/pages/agora_call_screen.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomingCallScreen extends StatefulWidget {
  final IncomingCallPayload payload;
  final Future<void> Function(IncomingCallPayload payload, String status)?
      onStatusChanged;

  const IncomingCallScreen({
    super.key,
    required this.payload,
    this.onStatusChanged,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  Timer? _timeoutTimer;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(seconds: 30), _markMissedAndClose);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _markMissedAndClose() async {
    if (_handled || !mounted) {
      return;
    }

    _handled = true;
    await widget.onStatusChanged?.call(widget.payload, 'missed');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _decline() async {
    if (_handled) {
      return;
    }

    _handled = true;
    _timeoutTimer?.cancel();
    await widget.onStatusChanged?.call(widget.payload, 'declined');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _accept() async {
    if (_handled) {
      return;
    }

    _handled = true;
    _timeoutTimer?.cancel();

    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    navigator.pop();

    final isProvider = AppPreferences().isProvider;
    if (isProvider) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: widget.payload.chatRoomId,
              clientName: widget.payload.callerName,
              isVideo: widget.payload.isVideo,
            ),
          ),
        ),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<CallCubit>(),
          child: AgoraCallScreen(
            roomId: widget.payload.chatRoomId,
            lawyerName: widget.payload.callerName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.golden,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.payload.isVideo
                        ? Icons.videocam_rounded
                        : Icons.call_rounded,
                    color: Colors.white,
                    size: 52.sp,
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  widget.payload.callerName,
                  textAlign: TextAlign.center,
                  style: context.text.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  widget.payload.isVideo
                      ? AppStrings.videoCall.tr(context)
                      : AppStrings.voiceCall.tr(context),
                  style: context.text.titleMedium?.copyWith(
                    color: AppColors.golden,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'مكالمة واردة...',
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallActionButton(
                      icon: Icons.call_end_rounded,
                      label: AppStrings.end.tr(context),
                      color: AppColors.error,
                      onTap: _decline,
                    ),
                    _CallActionButton(
                      icon: widget.payload.isVideo
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                      label: 'رد',
                      color: Colors.green,
                      onTap: _accept,
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40.r),
          child: Container(
            width: 74.w,
            height: 74.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32.sp),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
