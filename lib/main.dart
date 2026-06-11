
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/shared_preference/shared_preference.dart';
import 'features/user/my_orders/presentation/cubit/my_orders_cubit.dart';
import 'features/user/notifications/presentation/cubit/notifications_cubit.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'features/user/home/presentation/cubit/home_cubit.dart';
import 'injection_container.dart' as di;
import 'config/routes/app_routes.dart';
import 'core/calls/call_coordinator.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/network/fcm_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hogga/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Parallelize independent initialization tasks
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    AppPreferences.init(),
    initializeDateFormatting('ar', null),
  ]);

  // DI and FCM depend on previous initializations
  await di.init();
  
  final fcmService = FcmService.instance;
  await fcmService.initialize();
  await CallCoordinator.instance.initialize();
  
  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    CallCoordinator.instance.processPendingNavigation();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<LocalizationCubit>()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<HomeCubit>()),
        BlocProvider(create: (_) => di.sl<MyOrdersCubit>()),
        BlocProvider(create: (_) => di.sl<NotificationsCubit>()..getNotifications()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocalizationCubit, Locale>(
                builder: (context, locale) {
                  return BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is Unauthenticated) {
                        AppNavigator.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    },
                    child: MaterialApp(
                      title: 'حُجّة ',
                      debugShowCheckedModeBanner: false,
                      navigatorKey: AppNavigator.navigatorKey,
                      scaffoldMessengerKey: AppNavigator.messengerKey,
                      themeMode: themeMode,
                      locale: locale,
                      supportedLocales: const [
                        Locale('en', ''),
                        Locale('ar', ''),
                      ],
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      onGenerateRoute: AppRoutes.onGenerateRoute,
                      initialRoute: AppRoutes.initial,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

