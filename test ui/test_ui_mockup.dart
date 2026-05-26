import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../lib/core/theme/app_theme.dart';
import '../lib/core/utils/app_colors.dart';
import '../lib/core/utils/app_sizes.dart';

class TestUiMockup extends StatefulWidget {
  const TestUiMockup({super.key});

  @override
  State<TestUiMockup> createState() => _TestUiMockupState();
}

class _TestUiMockupState extends State<TestUiMockup> {
  int _currentPage = 0;

  void _navigateTo(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: _buildPage(),
            ),
          ),
        );
      },
    );
  }


  Widget _buildPage() {
    switch (_currentPage) {
      case 0:
        return _ServicesMainPage(onNavigate: () => _navigateTo(1));
      case 1:
        return _ReservedConsultationsPage(
          onBack: () => _navigateTo(0),
          onSelect: (idx) => _navigateTo(idx + 2),
        );
      case 2:
        return _MockupChatPage(onBack: () => _navigateTo(1));
      case 3:
        return _MockupVoiceCallPage(onBack: () => _navigateTo(1));
      case 4:
        return _MockupVideoCallPage(onBack: () => _navigateTo(1));
      default:
        return _ServicesMainPage(onNavigate: () => _navigateTo(1));
    }
  }
}

// --- 1. MAIN SERVICES PAGE (Omitted for brevity, kept as is) ---
class _ServicesMainPage extends StatelessWidget {
  final VoidCallback onNavigate;
  const _ServicesMainPage({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: onNavigate,
        ),
        centerTitle: true,
        title: Text(
          "خدمات بينه",
          style: context.text.titleMedium?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTab(context, "الاستشارات القانونية", true),
                _buildTab(context, "القضاء والتنفيذ", false),
                _buildTab(context, "خدمات", false),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildServiceCard(
                  context,
                  title: "استشارة فورية",
                  description: "تواصل فوراً مع محامٍ عبر مكالمة صوتية أو مرئية، دون الحاجة لحجز موعد مسبق.",
                  icon: Icons.flash_on,
                ),
                const SizedBox(height: 12),
                _buildServiceCard(
                  context,
                  title: "استشارة كتابية",
                  description: "تواصل كتابياً مع محامٍ لطرح استفساراتك وإرسال مستنداتك عبر دردشة نصية، بدون مكالمات.",
                  icon: Icons.chat_bubble_outline,
                ),
                const SizedBox(height: 12),
                _buildServiceCard(
                  context,
                  title: "استشارة مجدولة",
                  description: "احجز استشارة مع محامٍ من اختيارك في الوقت الذي يناسبك، عبر مكالمة صوتية أو مرئية.",
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isSelected) {
    return Column(
      children: [
        Text(
          label,
          style: context.text.titleSmall?.copyWith(
            color: isSelected ? Theme.of(context).primaryColor : context.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 2,
            width: 80,
            color: Theme.of(context).primaryColor,
          ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required String description, required IconData icon}) {
    return GestureDetector(
      onTap: onNavigate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}

// --- 2. RESERVED CONSULTATIONS PAGE ---
class _ReservedConsultationsPage extends StatelessWidget {
  final VoidCallback onBack;
  final Function(int) onSelect;
  const _ReservedConsultationsPage({required this.onBack, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: onBack,
        ),
        centerTitle: true,
        title: Text(
          "استشاراتي المحجوزة",
          style: context.text.titleMedium?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildConsultationCard(context, "استشارة كتابية", "د. أحمد علي", "اليوم، 04:00 م", Icons.chat, 0),
          const SizedBox(height: 12),
          _buildConsultationCard(context, "استشارة صوتية", "أ. سارة محمد", "غداً، 10:30 ص", Icons.phone, 1),
          const SizedBox(height: 12),
          _buildConsultationCard(context, "استشارة فيديو", "د. خالد حسن", "15 مايو، 08:00 م", Icons.videocam, 2),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, String title, String lawyer, String time, IconData icon, int index) {
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.divColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary),
                  ),
                  Text("المحامي: $lawyer", style: context.text.labelSmall?.copyWith(color: context.textSecondary)),
                  Text("الموعد: $time", style: context.text.labelSmall?.copyWith(color: context.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "دخول",
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. MOCKUP CHAT PAGE ---
class _MockupChatPage extends StatelessWidget {
  final VoidCallback onBack;
  const _MockupChatPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 1,
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.person, color: Colors.white70)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("د. أحمد علي", style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text("نشط الآن", style: context.text.labelSmall?.copyWith(color: Colors.green, fontSize: 10)),
              ],
            ),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        actions: [
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildChatBubble(context, "أهلاً بك يا أستاذ، كيف يمكنني مساعدتك اليوم بخصوص استشارتك؟", false),
                _buildChatBubble(context, "أهلاً دكتور، عندي استفسار بخصوص عقد العمل الجديد، هل يمكنني إرسال نسخة منه؟", true),
                _buildChatBubble(context, "بالطبع، يمكنك إرسال الملف وسأقوم بمراجعته فوراً.", false),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24.h),
            decoration: BoxDecoration(
              color: context.cardBg,
              border: Border(top: BorderSide(color: context.divColor, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.cream), onPressed: () {}),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 45.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.divColor),
                    ),
                    child: const TextField(
                      style: TextStyle(color: AppColors.cream),
                      decoration: InputDecoration(
                        hintText: "اكتب رسالتك...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.golden, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.surfaceDark : const Color(0xFF331D11),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? Border.all(color: AppColors.cream.withOpacity(0.1)) : null,
        ),
        child: Text(
          text,
          style: context.text.bodySmall?.copyWith(
            color: AppColors.cream,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}


// --- 4. MOCKUP VOICE CALL PAGE ---
class _MockupVoiceCallPage extends StatelessWidget {
  final VoidCallback onBack;
  const _MockupVoiceCallPage({required this.onBack});

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
            colors: [context.pageBg, AppColors.primary.withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.golden, width: 2)),
              child: const CircleAvatar(radius: 60, backgroundColor: Colors.white12, child: Icon(Icons.person, size: 60, color: Colors.white24)),
            ),
            const SizedBox(height: 24),
            Text("أ. سارة محمد", style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("جاري الاتصال...", style: TextStyle(color: AppColors.golden, letterSpacing: 1.2)),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCallAction(Icons.mic_off, "كتم"),
                  _buildCallAction(Icons.call_end, "إنهاء", color: Colors.red, onPressed: onBack),
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

  Widget _buildCallAction(IconData icon, String label, {Color color = Colors.white12, VoidCallback? onPressed}) {
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

// --- 5. MOCKUP VIDEO CALL PAGE ---
class _MockupVideoCallPage extends StatelessWidget {
  final VoidCallback onBack;
  const _MockupVideoCallPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Video
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
          // User Preview
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
          // Info Overlay
          Positioned(
            top: 60,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("د. خالد حسن", style: context.text.titleLarge?.copyWith(color: Colors.white)),
                const Text("12:45", style: TextStyle(color: AppColors.golden)),
              ],
            ),
          ),
          // Bottom Controls
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
                _buildVideoControl(Icons.call_end, color: Colors.red, onPressed: onBack),
                const SizedBox(width: 20),
                _buildVideoControl(Icons.switch_video),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControl(IconData icon, {Color color = Colors.white24, VoidCallback? onPressed}) {
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

