import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_assets.dart';
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
      illustration: _LawyerCardsIllustration(),
    ),
    _OnBoardingPage(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      illustration: _ConsultationIllustration(),
    ),
    _OnBoardingPage(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      illustration: _CaseIllustration(),
    ),
  ];

  void _next() {
    if (_currentIndex == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: context.isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1B0F08),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background with Scale of Justice Watermark ───────────
            Image.asset(
              AppAssets.authBackground,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            // Subtle dark tint to ensure text clarity
            Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),

            // ── Foreground Content ──────────────────────────────────
            SafeArea(
              child: Stack(
                children: [
                  // ── Main Content ──────────────────────────────────────
                  Column(
                    children: [
                      SizedBox(height: 52.h),
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
                                  style: TextStyle(
                                    color: const Color(0xFFF5E8D0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    height: 1.35,
                                    fontFamily: 'Rubik',
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _pages[_currentIndex].subtitle.tr(context),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFDEC396),
                                    fontSize: 12.sp,
                                    height: 1.45,
                                    fontFamily: 'Rubik',
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
                              color: isActive
                                  ? const Color(0xFFDFBF7A)
                                  : const Color(0xFFDFBF7A).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 24.h),

                      // Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDFBF7A),
                              foregroundColor: const Color(0xFF1B0F08),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              _currentIndex == _pages.length - 1
                                  ? AppStrings.startNow.tr(context)
                                  : AppStrings.nextStep.tr(context),
                              style: TextStyle(
                                color: const Color(0xFF23150C),
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Rubik',
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),

                  // ── Skip Button ───────────────────────────────────────
                  PositionedDirectional(
                    top: 12.h,
                    start: 16.w,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, AppRoutes.login),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.skip.tr(context),
                            style: TextStyle(
                              color: const Color(0xFFDEC396),
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Rubik',
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.r,
                            color: const Color(0xFFDEC396),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Center(
      child: SizedBox(
        width: 310.w,
        height: 185.h,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Back card (tilted symmetrically based on direction)
            Positioned(
              top: 6.h,
              child: Transform.rotate(
                angle: isRtl ? 0.06 : -0.06,
                child: _LawyerCard(
                  name: AppStrings.onboardingLawyer1.tr(context),
                  specialty: AppStrings.onboardingSpec1.tr(context),
                  rating: 4.8,
                  price: AppStrings.onboardingPrice1.tr(context),
                  status: AppStrings.onboardingStatusAvailable.tr(context),
                  opacity: 0.75,
                ),
              ),
            ),
            // Front card (consistently overlapping the back card in both languages)
            Positioned(
              top: 60.h,
              child: _LawyerCard(
                name: AppStrings.onboardingLawyer2.tr(context),
                specialty: AppStrings.onboardingSpec2.tr(context),
                rating: 4.5,
                price: AppStrings.onboardingPrice2.tr(context),
                status: AppStrings.onboardingStatusRunning.tr(context),
                opacity: 1,
              ),
            ),
            // Badge positioned directionally at the top corner of the back card
            PositionedDirectional(
              top: 0,
              start: 8.w,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        width: 295.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: context.pageBg,
          border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      fontSize: 10.5.sp,
                      color: context.textSecondary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: status == AppStrings.onboardingStatusAvailable.tr(context)
                              ? Colors.green.withValues(alpha: 0.25)
                              : context.accentGolden.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          status,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: context.accentGolden.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$rating',
                              style: context.text.labelSmall?.copyWith(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Icon(Icons.star, color: const Color(0xFFFFB800), size: 11.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: context.accentGolden.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    AppStrings.onboardingDetails.tr(context),
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 9.5.sp,
                      color: context.accentGolden,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            // Avatar
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: context.accentGolden.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person, size: 26.sp, color: Colors.white),
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
          border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.8), width: 2),
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
        border: Border.all(color: context.colors.onSurface.withValues(alpha: 0.8)),
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
