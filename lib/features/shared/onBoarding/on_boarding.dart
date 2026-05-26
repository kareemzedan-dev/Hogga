import 'package:flutter/material.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnBoardingPage> _pages = const [
    _OnBoardingPage(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      illustration: const _LawyerCardsIllustration(),
    ),
    _OnBoardingPage(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      illustration: const _ConsultationIllustration(),
    ),
    _OnBoardingPage(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      illustration: const _CaseIllustration(),
    ),
  ];

  void _next() {
    if (_currentIndex == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: context.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Main Content ──────────────────────────────────────
              Column(
                children: [
                  SizedBox(height: 56.h),
                  // Illustration area
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (_, i) => _pages[i].illustration,
                    ),
                  ),

                  // Text area
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(_currentIndex),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _pages[_currentIndex].title.tr(context),
                              textAlign: TextAlign.center,
                              style: context.text.headlineMedium?.copyWith(
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                                fontSize: 24.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              _pages[_currentIndex].subtitle.tr(context),
                              textAlign: TextAlign.center,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = _currentIndex == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 6.h,
                        width: isActive ? 24.w : 6.w,
                        decoration: BoxDecoration(
                          color: isActive ? context.colors.primary.withValues(alpha: 0.8) : context.colors.primary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 28.h),

                  // Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _currentIndex == _pages.length - 1 ? AppStrings.startNow.tr(context) : AppStrings.nextStep.tr(context),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),

              // ── Skip Button ───────────────────────────────────────
              Positioned(
                top: 12.h,
                left: 16.w,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.welcome),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.skip.tr(context),
                        style: context.text.labelMedium?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: context.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page Data Model ───────────────────────────────────────────────────────────
class _OnBoardingPage {
  final String title;
  final String subtitle;
  final Widget illustration;
  const _OnBoardingPage({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}

// ── Illustration 1: Lawyer Cards ──────────────────────────────────────────────
class _LawyerCardsIllustration extends StatelessWidget {
  const _LawyerCardsIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300.w,
        height: 220.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Back card
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: -0.08,
                child: _LawyerCard(
                  name: AppStrings.onboardingLawyer1.tr(context),
                  specialty: AppStrings.onboardingSpec1.tr(context),
                  rating: 4.8,
                  price: AppStrings.onboardingPrice1.tr(context),
                  status: AppStrings.onboardingStatusAvailable.tr(context),
                  opacity: 0.8,
                ),
              ),
            ),
            // Front card
            Positioned(
              bottom: 0,
              child: _LawyerCard(
                name: AppStrings.onboardingLawyer2.tr(context),
                specialty: AppStrings.onboardingSpec2.tr(context),
                rating: 4.5,
                price: AppStrings.onboardingPrice2.tr(context),
                status: AppStrings.onboardingStatusRunning.tr(context),
                opacity: 1,
              ),
            ),
            // Badge
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('3',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String price;
  final String status;
  final double opacity;

  const _LawyerCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.price,
    required this.status,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.pageBg,
          border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    specialty,
                    style: context.text.labelSmall?.copyWith(
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: status == AppStrings.onboardingStatusAvailable.tr(context) ? Colors.green.withValues(alpha: 0.3) : context.accentGolden.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          status,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: context.accentGolden.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$rating',
                              style: context.text.labelSmall?.copyWith(
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(Icons.star, color: const Color(0xFFFFB800), size: 12.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    AppStrings.onboardingDetails.tr(context),
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            // Avatar at the end (left)
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: context.accentGolden,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person, size: 28.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Illustration 2: Consultation ──────────────────────────────────────────────
class _ConsultationIllustration extends StatelessWidget {
  const _ConsultationIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(

          shape: BoxShape.circle,
          border: Border.all(color:  context.colors.onSurface.withOpacity(0.8), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call_rounded, color: context.colors.onSurface, size: 64.sp),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniChip(icon: Icons.phone, label: AppStrings.onboardingCall.tr(context)),
                SizedBox(width: 8.w),
                _MiniChip(icon: Icons.people, label: AppStrings.onboardingInPerson.tr(context)),
                SizedBox(width: 8.w),
                _MiniChip(icon: Icons.laptop, label: AppStrings.onboardingOnline.tr(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.onSurface.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          Icon(icon,  size: 16,color:context.colors.onSurface),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Illustration 3: Case Tracking ─────────────────────────────────────────────
class _CaseIllustration extends StatelessWidget {
  const _CaseIllustration();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (AppStrings.onboardingStepNew, Icons.add_box_outlined, true),
      (AppStrings.onboardingStepReview, Icons.rate_review_outlined, true),
      (AppStrings.onboardingStepRunning, Icons.gavel, true),
      (AppStrings.onboardingStepCompleted, Icons.check_circle_outline, false),
    ];
    return Center(
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(20),
          border: Border.all(color:context.colors.onSurface),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: context.colors.onSurface, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  AppStrings.onboardingCaseNo.tr(context),
                  style: context.text.titleMedium?.copyWith(

                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...steps.map((s) => _StepRow(
                  label: s.$1.tr(context),
                  icon: s.$2,
                  isDone: s.$3,
                )),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  const _StepRow({required this.label, required this.icon, required this.isDone});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : icon,
            color: isDone ? context.accentGolden : context.colors.onPrimary,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: context.text.titleSmall?.copyWith(),
          ),
        ],
      ),
    );
  }
}
