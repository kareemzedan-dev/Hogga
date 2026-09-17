import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/calls/call_screen_launcher.dart';
import 'package:hogga/core/calls/incoming_call_payload.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';

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
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timeoutTimer;
  bool _handled = false;
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(
      IncomingCallPayload.ringingTimeout,
      _markMissedAndClose,
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    unawaited(_cancelCallNotification());
    super.dispose();
  }

  Future<void> _markMissedAndClose() async {
    if (_handled || !mounted) {
      return;
    }

    _handled = true;
    unawaited(_notifyStatus('missed'));
    await _cancelCallNotification();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _cancelCallNotification() async {
    for (final id in widget.payload.notificationIds) {
      await _localNotificationsPlugin.cancel(id: id);
      for (final tag in widget.payload.notificationTags) {
        await _localNotificationsPlugin.cancel(id: id, tag: tag);
      }
    }
  }

  Future<void> _notifyStatus(String status) async {
    try {
      await widget.onStatusChanged?.call(widget.payload, status);
    } catch (e) {
      log('Incoming call status update failed ($status): $e');
    }
  }

  Future<void> _decline() async {
    if (_handled) {
      return;
    }

    _handled = true;
    if (mounted) {
      setState(() => _isDeclining = true);
    }
    _timeoutTimer?.cancel();
    unawaited(_notifyStatus('declined'));
    await _cancelCallNotification();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _accept() async {
    if (_handled) {
      return;
    }

    _handled = true;
    if (mounted) {
      setState(() => _isAccepting = true);
    }
    _timeoutTimer?.cancel();
    await _cancelCallNotification();

    if (!mounted) {
      return;
    }

    final navigator = Navigator.of(context);
    navigator.pop();
    await pushIncomingAgoraCall(navigator: navigator, payload: widget.payload);
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
                    border: Border.all(color: AppColors.golden, width: 2),
                  ),
                  child: Icon(
                    Icons.call_rounded,
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
                  AppStrings.voiceCall.tr(context),
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
                  children: [
                    Expanded(
                      child: _CallActionButton(
                        icon: Icons.call_end_rounded,
                        label: 'رفض',
                        color: AppColors.error,
                        isLoading: _isDeclining,
                        onTap: _decline,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _CallActionButton(
                        icon: Icons.call_rounded,
                        label: 'رد',
                        color: const Color(0xFF1DB954),
                        isLoading: _isAccepting,
                        onTap: _accept,
                      ),
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
  final Future<void> Function() onTap;
  final bool isLoading;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => unawaited(onTap()),
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          height: 64.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: context.text.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
