import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/my_orders/presentation/pages/my_orders.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:hogga/features/user/home/presentation/cubit/home_cubit.dart';
import 'package:hogga/features/user/home/presentation/pages/home_screen.dart';
import 'package:hogga/features/user/more/more_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/localization_cubit.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  int _selectedIndex = 0;
  late PageController _pageController;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {

    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }


  Future<void> _onRefresh() async {
    await _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    await context.read<HomeCubit>().loadCategories();
    await context.read<HomeCubit>().loadBanners();
  }

  @override
  Widget build(BuildContext context) {
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
      child: BlocListener<LocalizationCubit, Locale>(
        listener: (context, locale) {
          // Refresh all data immediately on language change, regardless of current tab
          _refreshAllData();
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _selectedIndex == 0 ? null : null,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to change tab
                children: [
                  // 0: Home
                  HomeScreen(),
                  // 1: My Orders
                  const MyOrdersView(),
                  // 2: Account/Profile
                  MoreScreen(),
                ],
              ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}



