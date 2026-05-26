import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';

class VideoCallScreen extends StatelessWidget {
  final String callerName;
  const VideoCallScreen({super.key, this.callerName = "د. خالد حسن"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Main Video (Mockup) ─────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.person, size: 200, color: Colors.white),
              ),
            ),
          ),
          
          // ── User Preview (Mockup) ───────────────────────────────
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
              child: const Icon(Icons.person, color: Colors.white10),
            ),
          ),
          
          // ── Info Overlay ────────────────────────────────────────
          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                ),
                const Text(
                  "12:45",
                  style: TextStyle(color: AppColors.golden),
                ),
              ],
            ),
          ),
          
          // ── Bottom Controls ─────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVideoControl(Icons.videocam_off),
                const SizedBox(width: 20),
                _buildVideoControl(Icons.mic_off),
                const SizedBox(width: 20),
                _buildVideoControl(
                  Icons.call_end,
                  color: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 20),
                _buildVideoControl(Icons.switch_video),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControl(IconData icon,
      {Color color = Colors.white24, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
