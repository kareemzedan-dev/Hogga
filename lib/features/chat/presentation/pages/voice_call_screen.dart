import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class VoiceCallScreen extends StatelessWidget {
  final String callerName;
  const VoiceCallScreen({super.key, this.callerName = "أ. سارة محمد"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: Container(
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
                child: Icon(Icons.person, size: 60, color: Colors.white24),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              callerName,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "جاري الاتصال...",
              style: TextStyle(color: AppColors.golden, letterSpacing: 1.2),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCallAction(Icons.mic_off, "كتم"),
                  _buildCallAction(
                    Icons.call_end,
                    "إنهاء",
                    color: Colors.red,
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildCallAction(Icons.volume_up, "مكبر"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallAction(IconData icon, String label,
      {Color color = Colors.white12, VoidCallback? onPressed}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
