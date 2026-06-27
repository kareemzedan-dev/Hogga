import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper to check and guide users to enable heads-up (pop-up) notifications.
/// Especially useful for Xiaomi/MIUI/HyperOS devices that block them by default.
class NotificationPermissionHelper {
  NotificationPermissionHelper._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Call this after FCM is initialized (e.g. in splash or home screen).
  /// Shows a dialog if heads-up notifications appear to be blocked.
  static Future<void> checkAndPromptIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Check basic notification permission (Android 13+)
    final notifEnabled = await androidPlugin.areNotificationsEnabled();
    if (notifEnabled == false) {
      // Notifications completely disabled — request permission
      await Permission.notification.request();
      return;
    }

    // Check if the high-importance channel allows heads-up
    final channels = await androidPlugin.getNotificationChannels();
    final channel = channels?.firstWhere(
      (c) => c.id == 'high_importance_channel_v3',
      orElse: () => AndroidNotificationChannel(
        'high_importance_channel_v3',
        'Notifications',
        importance: Importance.min,
      ),
    );

    // If the channel importance was downgraded by user below "high", heads-up won't show
    final channelImportance = channel?.importance ?? Importance.min;
    final isHeadsUpBlocked =
        channelImportance.value < Importance.high.value;

    if (!context.mounted) return;

    if (isHeadsUpBlocked) {
      _showSettingsDialog(
        context,
        title: 'تفعيل الإشعارات الفورية',
        message:
            'يبدو أن الإشعارات الفورية (Pop-up) مُعطَّلة.\n\n'
            'لتفعيلها:\n'
            '١. اضغط "إعدادات الإشعارات"\n'
            '٢. اختر "حجة" أو اسم التطبيق\n'
            '٣. فعِّل "الإشعارات المنبثقة" أو "Floating Notifications"\n'
            '٤. فعِّل "عرض على شاشة القفل"',
        settingsType: _SettingsType.channel,
      );
      return;
    }

    // Xiaomi-specific: check if MIUI/HyperOS is detected
    if (_isMiui()) {
      // We can't programmatically check MIUI popup setting,
      // so we show a one-time guidance dialog
      final shown = _miuiDialogShown;
      if (!shown) {
        _miuiDialogShown = true;
        _showSettingsDialog(
          context,
          title: 'تنبيه لأجهزة شاومي',
          message:
              'إذا لم تظهر الإشعارات فوق الشاشة، يرجى:\n\n'
              '١. اضغط "إعدادات التطبيق"\n'
              '٢. ابحث عن "الإشعارات" ← "حجة"\n'
              '٣. فعِّل "إشعارات منبثقة" (Pop-up notifications)\n'
              '٤. فعِّل "إشعارات عائمة" (Floating notifications)\n'
              '٥. فعِّل "التشغيل التلقائي" (Autostart)',
          settingsType: _SettingsType.app,
        );
      }
    }
  }

  static bool _miuiDialogShown = false;

  static bool _isMiui() {
    // Detect Xiaomi/MIUI/HyperOS by manufacturer
    try {
      // We can't use device_info_plus without adding it,
      // so we use a safer approach via Platform
      return Platform.isAndroid &&
          (Platform.operatingSystemVersion
                  .toLowerCase()
                  .contains('xiaomi') ||
              Platform.localHostname.toLowerCase().contains('xiaomi'));
    } catch (_) {
      return false;
    }
  }

  static void _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required _SettingsType settingsType,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_outlined,
                color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقاً',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('إعدادات الإشعارات'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openSettings(settingsType);
            },
          ),
        ],
      ),
    );
  }

  /// Opens the appropriate Android settings page
  static Future<void> openSettings(_SettingsType type) async {
    switch (type) {
      case _SettingsType.app:
        await openAppSettings();
        break;
      case _SettingsType.channel:
        // Opens notification settings for the app (channel list)
        await openAppSettings();
        break;
    }
  }
}

enum _SettingsType { app, channel }
