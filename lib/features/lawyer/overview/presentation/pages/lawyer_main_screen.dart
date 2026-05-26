import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/features/lawyer/overview/presentation/pages/lawyer_overview_screen.dart';
import 'package:hogga/features/lawyer/wallet/presentation/pages/lawyer_wallet_screen.dart';
import 'package:hogga/features/lawyer/cases/presentation/pages/lawyer_cases_screen.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_bottom_nav_bar.dart';
import 'package:hogga/features/lawyer/overview/presentation/pages/lawyer_more_screen.dart';
import 'package:hogga/features/lawyer/proposals/presentation/pages/lawyer_opportunities_screen.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/localization/localization_cubit.dart';
import 'package:hogga/core/widgets/custom_button.dart';
import 'package:hogga/config/shared_preference/shared_preference.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/injection_container.dart';
import 'package:hogga/features/lawyer/overview/presentation/cubit/lawyer_overview_cubit.dart';
import 'package:hogga/features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';
import 'package:hogga/features/lawyer/wallet/presentation/cubit/lawyer_wallet_cubit.dart';
import 'package:hogga/features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';
import 'package:hogga/features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';

import '../../../../../config/routes/app_routes.dart';
import '../../../../../core/utils/app_colors.dart';
class LawyerMainScreen extends StatefulWidget {
  const LawyerMainScreen({super.key});

  @override
  State<LawyerMainScreen> createState() => _LawyerMainScreenState();
}

class _LawyerMainScreenState extends State<LawyerMainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  DateTime? _lastBackPressTime;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      LawyerOverviewScreen(onNavigate: _onItemTapped),
      const LawyerOpportunitiesScreen(isBottomNav: true),
      const LawyerCasesScreen(isBottomNav: true),
      const LawyerWalletScreen(isBottomNav: true),
      const LawyerMoreScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    if (index >= _screens.length) index = 0;
    
    setState(() {
      _selectedIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LawyerOverviewCubit>()..getOverviewData()),
        BlocProvider(create: (_) => sl<LawyerRequestsCubit>()..getRequests()),
        BlocProvider(create: (_) => sl<LawyerProposalsCubit>()..getProposalsData()),
        BlocProvider(create: (_) => sl<LawyerCasesCubit>()..getCases()),
        BlocProvider(create: (_) => sl<LawyerWalletCubit>()..getWalletData()),
      ],
      child: BlocBuilder<LawyerOverviewCubit, LawyerOverviewState>(
        builder: (context, state) {
          final isPending = state is LawyerOverviewError && (state.message.contains('المراجعة') || state.message.contains('pending'));

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final now = DateTime.now();
              if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
                _lastBackPressTime = now;
                if (context.mounted) {
                  AppSnackbar.showInfo(context, message: AppStrings.pressBackAgainToExit.tr(context));
                }
                return;
              }
              SystemNavigator.pop();
            },
            child: MultiBlocListener(
              listeners: [
                BlocListener<LocalizationCubit, Locale>(
                  listener: (context, locale) {
                    // Refresh all lawyer data when language changes
                    context.read<LawyerOverviewCubit>().getOverviewData();
                    context.read<LawyerRequestsCubit>().getRequests();
                    context.read<LawyerProposalsCubit>().getProposalsData();
                    context.read<LawyerCasesCubit>().getCases();
                    context.read<LawyerWalletCubit>().getWalletData();
                  },
                ),
                BlocListener<LawyerRequestsCubit, LawyerRequestsState>(
                  listener: (context, state) {
                    if (state is LawyerRequestActionSuccess) {
                      // Rule: When a lead is accepted/processed, refresh both leads and cases
                      context.read<LawyerRequestsCubit>().getRequests();
                      context.read<LawyerCasesCubit>().getCases();
                    }
                  },
                ),
                BlocListener<LawyerCasesCubit, LawyerCasesState>(
                  listener: (context, state) {
                    if (state is LawyerCaseActionSuccess) {
                      // Financial Consistency Rule: When a case action happens (e.g. session added/case completed),
                      // refresh wallet data to reflect any changes in balance or pending funds.
                      context.read<LawyerWalletCubit>().getWalletData();
                    }
                  },
                ),
              ],
              child: Scaffold(
                body: isPending && _selectedIndex != 4
                    ? _PendingReviewView(message: state.message)
                    : PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _screens,
                      ),
                bottomNavigationBar: LawyerBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PendingReviewView extends StatelessWidget {
  final String message;
  const _PendingReviewView({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حُجَّة',
          style: context.theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await AppPreferences().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.onBoarding, (route) => false);
              }
            },
            icon: Icon(Icons.logout_rounded, color: context.colors.error),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                size: 100.sp,
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              AppStrings.pendingReview.tr(context),
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              message, // Already localized from API or tr called in cubit/repo
              style: context.text.bodyLarge?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60.h),
            CustomButton(
              onPressed: () => context.read<LawyerOverviewCubit>().getOverviewData(),
              text: AppStrings.refresh.tr(context),
              icon: Icons.refresh_rounded,
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.willNotifyYou.tr(context),
              style: context.text.labelMedium?.copyWith(
                color: context.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
