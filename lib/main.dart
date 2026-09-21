import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/routes/app_routes.dart';
import 'config/shared_preference/shared_preference.dart';
import 'core/calls/call_coordinator.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_cubit.dart';
import 'core/navigation/app_navigator.dart';
import 'core/network/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'features/shared/auth/presentation/shared/cubit/auth_state.dart';
import 'features/user/home/presentation/cubit/home_cubit.dart';
import 'features/user/my_orders/presentation/cubit/my_orders_cubit.dart';
import 'features/user/notifications/presentation/cubit/notifications_cubit.dart';
import 'injection_container.dart' as di;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installGlobalErrorHandlers();

      final bootstrapOk = await _initializeCriticalServices();
      runApp(bootstrapOk ? const MyApp() : const BootstrapErrorApp());

      if (bootstrapOk) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_initializePostFrameServices());
        });
      }
    },
    (error, stackTrace) {
      log('Uncaught zone error', error: error, stackTrace: stackTrace);
    },
  );
}

void _installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    log(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    log('PlatformDispatcher error', error: error, stackTrace: stackTrace);
    // Return true so the error is treated as handled and does not kill the isolate.
    return true;
  };

  ErrorWidget.builder = (details) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong.\nحدث خطأ غير متوقع.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  };
}

/// Returns `false` only when dependency injection failed (app cannot render).
Future<bool> _initializeCriticalServices() async {
  await _safeInitialize('SharedPreferences', () => AppPreferences.init());
  await _safeInitialize(
    'DateFormatting',
    () => initializeDateFormatting('ar', null),
  );

  final firebaseOk = await _safeInitialize('Firebase', () async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  });

  if (firebaseOk) {
    await _safeInitialize(
      'FCM background handler',
      () async => FcmService.registerBackgroundHandler(),
    );
  }

  final diOk = await _safeInitialize('DependencyInjection', () => di.init());
  return diOk;
}

Future<void> _initializePostFrameServices() async {
  await _safeInitialize('FCM', () => FcmService.instance.initialize());
  await _safeInitialize(
    'CallCoordinator',
    () => CallCoordinator.instance.initialize(),
  );
  await _safeInitialize(
    'Pending call navigation',
    () => CallCoordinator.instance.processPendingNavigation(),
  );
}

Future<bool> _safeInitialize(
  String name,
  Future<void> Function() initializer,
) async {
  try {
    await initializer();
    return true;
  } catch (error, stackTrace) {
    log('$name initialization failed', error: error, stackTrace: stackTrace);
    return false;
  }
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
        BlocProvider(
          create: (_) => di.sl<NotificationsCubit>()..getNotifications(),
        ),
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
                        AppNavigator.navigatorKey.currentState
                            ?.pushNamedAndRemoveUntil(
                              AppRoutes.login,
                              (route) => false,
                            );
                      }
                    },
                    child: MaterialApp(
                      title: locale.languageCode == 'ar' ? 'حُجّة' : 'Hogga',
                      debugShowCheckedModeBanner: false,
                      navigatorKey: AppNavigator.navigatorKey,
                      scaffoldMessengerKey: AppNavigator.messengerKey,
                      themeMode: themeMode,
                      locale: locale,
                      supportedLocales: const [
                        Locale('en', ''),
                        Locale('ar', ''),
                      ],
                      localizationsDelegates: const [
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

/// Shown only if DI bootstrap fails so the process never exits blank.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذر تشغيل التطبيق.\nPlease reopen the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Bootstrap failed. Check device logs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
