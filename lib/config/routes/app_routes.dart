import 'package:flutter/material.dart';
import '../../features/shared/auth/presentation/shared/screens/welcome/welcom_page.dart';
import '../../features/shared/onBoarding/on_boarding.dart';
import '../../features/user/hogga_services/presentation/pages/hub/service_subtypes_screen.dart';
import '../../features/user/main_screen/pages/main_screen.dart';
import '../../features/shared/auth/presentation/shared/screens/login/login_screen.dart';
import '../../features/shared/auth/presentation/lawyer/screens/onboarding/lawyer_onboarding_screen.dart';
import '../../features/shared/auth/presentation/shared/screens/password/forgot_password_screen.dart';
import '../../features/shared/auth/presentation/shared/screens/password/reset_password_screen.dart';

import '../../core/utils/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/main_appbar.dart';
import '../../features/shared/onBoarding/splash.dart';
import '../../features/user/more/terms_of_use/terms_of_use_screen.dart';
import '../../features/lawyer/overview/presentation/pages/lawyer_main_screen.dart';
import 'package:hogga/features/user/wallet/presentation/pages/payment_webview_screen.dart';
import '../../features/lawyer/bookings/presentation/pages/lawyer_order_details_screen.dart';
import '../../features/lawyer/cases/presentation/pages/lawyer_case_details_screen.dart';
import '../../features/lawyer/consultations/presentation/pages/lawyer_consultations_screen.dart';
import '../../features/lawyer/specializations/presentation/pages/lawyer_specializations_screen.dart';
import '../../features/user/hogga_services/presentation/pages/lawyer/lawyer_profile_screen.dart';

import '../../features/lawyer/documents/presentation/pages/lawyer_documents_screen.dart';
import '../../features/lawyer/library/presentation/pages/lawyer_legal_library_screen.dart';
import '../../features/lawyer/tasks/presentation/pages/lawyer_tasks_screen.dart';
import '../../features/lawyer/reports/presentation/pages/lawyer_reports_screen.dart';
import '../../features/lawyer/proposals/presentation/pages/lawyer_opportunities_screen.dart';
import '../../features/lawyer/services/presentation/pages/lawyer_services_screen.dart';
import '../../features/lawyer/services/presentation/pages/lawyer_service_details_screen.dart';
import '../../features/lawyer/services/presentation/pages/lawyer_add_service_screen.dart';
import '../../features/lawyer/services/presentation/pages/lawyer_update_service_screen.dart';
import '../../features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';
import '../../features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';
import '../../features/lawyer/clients/presentation/pages/lawyer_clients_screen.dart';
import '../../features/lawyer/bookings/presentation/pages/lawyer_bookings_screen.dart';
import '../../features/lawyer/services/domain/entities/lawyer_service.dart';
import '../../features/shared/auth/presentation/shared/screens/login/phone_login_screen.dart';
import '../../features/shared/auth/presentation/shared/screens/otp/otp_verification_screen.dart';
import '../../features/shared/auth/presentation/shared/screens/password/create_password_screen.dart';
import '../../features/shared/auth/presentation/user/screens/register/register_details_screen.dart';
import '../../features/shared/auth/presentation/user/screens/register/verify_email_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/lawyer/chat/presentation/pages/lawyer_chat_screen.dart';
import '../../features/lawyer/chat/presentation/pages/lawyer_chat_list_screen.dart';
import '../../features/lawyer/chat/presentation/cubit/lawyer_chat_messages_cubit.dart';
import '../../features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import '../../features/chat/presentation/pages/chat_list_screen.dart';
import '../../features/chat/presentation/pages/agora_call_screen.dart';
import '../../features/chat/presentation/cubit/chat_messages_cubit.dart';
import '../../features/chat/presentation/cubit/call_cubit.dart';
import '../../injection_container.dart' as di;
import '../../features/user/more/about_app/about_app_screen.dart';
import '../../features/user/more/about_us/about_us_screen.dart';
import '../../features/user/more/contact_us/contact_us_screen.dart';
import '../../features/user/more/privacy/privacy_screen.dart';
import '../../features/user/more/presentation/instructions/instructions_screen.dart';
import '../../features/user/profile/presentation/pages/profile_screen.dart';
import '../../features/user/wallet/presentation/pages/user_wallet_screen.dart';
import '../../features/user/wallet/presentation/pages/payment_details_screen.dart';
import '../../features/user/hogga_services/presentation/pages/hub/services_hub_screen.dart';
import '../../features/user/hogga_services/presentation/pages/hub/choose_specialization_screen.dart';
import '../../features/user/hogga_services/domain/models/booking_flow_args.dart';
import '../../features/user/hogga_services/domain/models/service_required_input.dart';
import '../../features/user/hogga_services/presentation/pages/booking/consultation_booking_flow_screen.dart';
import '../../features/user/hogga_services/presentation/pages/booking/booking_flow_screen.dart';
import '../../features/user/hogga_services/presentation/pages/lawyer/lawyer_browser_screen.dart';
import '../../features/user/hogga_services/presentation/pages/lawyer/service_details_screen.dart';
import '../../features/user/hogga_services/presentation/pages/lawyer/lawyer_search_screen.dart';
import '../../features/user/hogga_services/presentation/pages/booking/order_confirmed_screen.dart';
import '../../features/user/home/data/models/categories_model.dart';
import '../../features/user/notifications/presentation/pages/notifications_screen.dart';
import '../../features/user/my_orders/presentation/cubit/legal_case_actions_cubit.dart';
import '../../features/user/my_orders/presentation/cubit/my_orders_cubit.dart';
import '../../features/user/my_orders/presentation/pages/my_order_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/lawyer/subscription/presentation/pages/lawyer_subscription_screen.dart';
import '../../features/lawyer/wallet/presentation/pages/lawyer_wallet_screen.dart';
import '../../features/lawyer/wallet/presentation/cubit/lawyer_wallet_cubit.dart';
import '../../features/lawyer/referral/presentation/pages/lawyer_referral_screen.dart';
import '../../features/lawyer/referral/presentation/pages/lawyer_referral_history_screen.dart';
import '../../features/lawyer/referral/presentation/cubit/referral_cubit.dart';
import '../../features/lawyer/referral/presentation/cubit/referral_history_cubit.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String splash = '/splash';
  static const String onBoarding = '/onBoarding';
  static const String welcome = '/welcome';
  static const String register = '/register';
  static const String main = '/main';
  static const String admin = '/admin';
  static const String lawyerDashboard = '/lawyer_dashboard';
  static const String forgotPassword = '/forgot_password';
  static const String myOrders = '/my_orders';
  static const String myOrderDetails = '/my_order_details';
  static const String profile = '/profile';
  static const String privacyPolicy = '/privacy_policy';
  static const String aboutUs = '/about_us';
  static const String aboutApp = '/about_app';
  static const String wallet = '/wallet';
  static const String paymentDetails = '/payment_details';
  static const String notifications = '/notifications';

  static const String splashScreen = '/splashScreen';
  static const String phoneLogin = '/phone_login';
  static const String otpVerification = '/otp_verification';
  static const String createPassword = '/create_password';
  static const String registerDetails = '/register_details';
  static const String verifyEmail = '/verify_email';
  static const String resetPassword = '/reset-password';
  static const String contactUs = '/contact_us';
  static const String termsOfUse = '/terms_of_use';
  static const String instructions = '/instructions';

  static const String servicesHub = '/services_hub';
  static const String chooseSpecialization = '/choose_specialization';
  static const String serviceSubtypes = '/service_subtypes';
  static const String bookingFlow = '/booking_flow';
  static const String consultationBooking = '/consultation_booking';
  static const String lawyerBrowser = '/lawyer_browser';
  static const String serviceDetails = '/service_details';
  static const String orderConfirmed = '/order_confirmed';
  static const String lawyerOnboarding = '/lawyer_onboarding';
  static const String lawyerMain = '/lawyer_main';
  static const String lawyerOrderDetails = '/lawyer_order_details';
  static const String lawyerProfile = '/lawyer_profile';
  static const String lawyerSettings = '/lawyer_settings';
  static const String lawyerCaseDetails = '/lawyer_case_details';
  static const String lawyerConsultations = '/lawyer_consultations';
  static const String lawyerConsultationDetails =
      '/lawyer_consultation_details';
  static const String lawyerDocuments = '/lawyer_documents';
  static const String lawyerLibrary = '/lawyer_library';
  static const String lawyerChatList = '/lawyer_chat_list';
  static const String lawyerChat = '/lawyer_chat';
  static const String lawyerCall = '/lawyer_call';
  static const String paymentWebView = '/payment_webview';
  static const String lawyerTasks = '/lawyer_tasks';
  static const String lawyerReports = '/lawyer_reports';
  static const String lawyerSearch = '/lawyer_search';
  static const String lawyerOpportunities = '/lawyer_opportunities';
  static const String lawyerSpecializations = '/lawyer_specializations';
  static const String lawyerServices = '/lawyer_services';
  static const String lawyerProposals = '/lawyer_proposals';
  static const String lawyerClients = '/lawyer_clients';
  static const String lawyerServiceDetails = '/lawyer_service_details';
  static const String lawyerAddService = '/lawyer_add_service';
  static const String lawyerUpdateService = '/lawyer_update_service';
  static const String lawyerBookings = '/lawyer_bookings';
  static const String lawyerSubscription = '/lawyer_subscription';
  static const String lawyerWallet = '/lawyer_wallet';
  static const String lawyerReferral = '/lawyer_referral';
  static const String lawyerReferralHistory = '/lawyer_referral_history';
  static const String chat = '/chat';
  static const String chatList = '/chat_list';
  static const String call = '/call';
  static const String voiceCall = '/voice_call';
  static const String videoCall = '/video_call';

  static bool _isCallServiceType(String? type) {
    final normalized = type?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('audio') ||
        normalized.contains('video') ||
        normalized.contains('phone') ||
        normalized.contains('voice') ||
        normalized.contains('call');
  }

  static bool _isVideoServiceType(String? type) {
    final normalized = type?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) return false;
    return normalized.contains('video');
  }

  static int _routeInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Route<dynamic> _unsupportedCommunicationRoute() {
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text(AppStrings.noRouteFound))),
    );
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings setting) {
    switch (setting.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onBoarding:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case register:
        final role = (setting.arguments as String?) ?? 'user';
        if (role == 'lawyer') {
          return MaterialPageRoute(
            builder: (_) => const LawyerOnboardingScreen(),
          );
        }
        return MaterialPageRoute(builder: (_) => const PhoneLoginScreen());
      case phoneLogin:
        return MaterialPageRoute(builder: (_) => const PhoneLoginScreen());
      case otpVerification:
        final args = setting.arguments;
        String phone = '';
        bool isForReset = false;
        if (args is Map) {
          phone = args['phone'] as String;
          isForReset = args['isForReset'] as bool? ?? false;
        } else {
          phone = args as String;
        }
        return MaterialPageRoute(
          builder: (_) => OTPScreen(phone: phone, isForReset: isForReset),
        );
      case createPassword:
        final phone = setting.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CreatePasswordScreen(phone: phone),
        );
      case registerDetails:
        final args = setting.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => RegisterDetailsScreen(
            phone: args['phone'] ?? '',
            password: args['password'] ?? '',
          ),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case lawyerDashboard:
        return MaterialPageRoute(builder: (_) => const LawyerMainScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case wallet:
        return MaterialPageRoute(builder: (_) => const UserWalletScreen());
      case paymentDetails:
        final id = setting.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PaymentDetailsScreen(paymentId: id),
        );
      case myOrders:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(initialIndex: 1),
        );
      case myOrderDetails:
        final args = setting.arguments;
        final orderId = args is int
            ? args
            : args is Map
            ? _routeInt(args['orderId'] ?? args['id'])
            : 0;
        final recordType = args is Map
            ? (args['recordType'] ?? args['type'])?.toString()
            : null;
        if (orderId <= 0) {
          return MaterialPageRoute(
            builder: (_) => const MainScreen(initialIndex: 1),
          );
        }
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<MyOrdersCubit>()),
              BlocProvider(create: (_) => di.sl<LegalCaseActionsCubit>()),
            ],
            child: OrderDetailsView(orderId: orderId, recordType: recordType),
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case aboutApp:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());
      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      case aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsScreen());
      case contactUs:
        return MaterialPageRoute(builder: (_) => const ContactUsScreen());
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case termsOfUse:
        return MaterialPageRoute(builder: (_) => const TermsOfUseScreen());
      case instructions:
        return MaterialPageRoute(builder: (_) => const InstructionsScreen());
      case verifyEmail:
        final email = setting.arguments as String;
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: email),
        );
      case resetPassword:
        final phone = setting.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(phone: phone),
        );
      case call:
      case voiceCall:
      case videoCall:
        final args = setting.arguments as Map<String, dynamic>? ?? {};
        final serviceType = args['serviceType'] as String?;
        if ((setting.name == call || setting.name == voiceCall) &&
            serviceType != null &&
            !_isCallServiceType(serviceType)) {
          return _unsupportedCommunicationRoute();
        }
        if (setting.name == videoCall &&
            serviceType != null &&
            !_isVideoServiceType(serviceType)) {
          return _unsupportedCommunicationRoute();
        }
        final roomId = args['chatRoomId'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<CallCubit>(),
            child: AgoraCallScreen(
              roomId: roomId,
              lawyerName: args['lawyerName'] as String? ?? 'المحامي',
              lawyerPhoto: args['lawyerPhoto'] as String?,
            ),
          ),
        );

      case servicesHub:
        final initialIndex = (setting.arguments as int?) ?? 0;
        return MaterialPageRoute(
          builder: (_) => ServicesHubScreen(initialIndex: initialIndex),
        );
      case chooseSpecialization:
        final args = setting.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChooseSpecializationScreen(
            category: args['category'] as Category,
            subCategory: args['subCategory'] as SubCategory,
          ),
        );
      case serviceSubtypes:
        final args = setting.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ServiceSubtypesScreen(
            childCategoryId: args['childCategoryId'] as int,
            subCategoryId: args['subCategoryId'] as int?,
            sectionName: args['sectionName'] as String,
            subCategoryName: args['subCategoryName'] as String,
            childCategoryName: args['childCategoryName'] as String,
            parentServiceType: args['parentServiceType'] as String?,
            parentConsultationType: args['parentConsultationType'] as String?,
            parentIsConsultation: args['parentIsConsultation'] == true,
            subCategoryPrice: args['subCategoryPrice'] as double,
            parentRequiredInputs:
                args['requiredInputs'] as List<ServiceRequiredInput>? ??
                const [],
          ),
        );
      case bookingFlow:
        final bfArgs = setting.arguments as BookingFlowArgs;
        return MaterialPageRoute(
          builder: (_) => BookingFlowScreen(args: bfArgs, typeOfBookingFlow: 0),
        );
      case consultationBooking:
        final bfArgs = setting.arguments as BookingFlowArgs;
        return MaterialPageRoute(
          builder: (_) => ConsultationBookingFlowScreen(args: bfArgs),
        );
      case lawyerBrowser:
        final args = setting.arguments;
        int? categoriesItemId;
        int typeOfBookingFlow = 0;
        String? coupon;
        if (args is Map) {
          categoriesItemId = args['categories_item_id'] as int?;
          typeOfBookingFlow = args['typeOfBookingFlow'] as int? ?? 0;
          coupon = args['coupon']?.toString();
        } else if (args is int) {
          categoriesItemId = args;
        }
        return MaterialPageRoute(
          builder: (_) => LawyerBrowserScreen(
            categoriesItemId: categoriesItemId,
            typeOfBookingFlow: typeOfBookingFlow,
            initialCoupon: coupon,
          ),
        );
      case paymentWebView:
        final args = setting.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: args?['paymentUrl'] ?? '',
            caseNumber: args?['caseNumber'] ?? '',
            caseId: _routeInt(args?['caseId']),
            recordType: args?['recordType']?.toString(),
          ),
        );
      case serviceDetails:
        final serviceId = setting.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailsScreen(serviceId: serviceId),
        );
      case orderConfirmed:
        final args = setting.arguments as Map<String, dynamic>? ?? {};
        final caseNumber = args['caseNumber'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OrderConfirmedScreen(
            caseNumber: caseNumber,
            caseId: _routeInt(args['caseId']),
            recordType: args['recordType']?.toString(),
          ),
        );
      case AppRoutes.lawyerOnboarding:
        return MaterialPageRoute(
          builder: (_) => const LawyerOnboardingScreen(),
        );
      case AppRoutes.lawyerMain:
        final initialIndex = setting.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => LawyerMainScreen(initialIndex: initialIndex),
        );
      case AppRoutes.lawyerOrderDetails:
        return MaterialPageRoute(
          builder: (_) => const LawyerOrderDetailsScreen(),
          settings: setting,
        );
      case AppRoutes.lawyerProfile:
        final providerId = setting.arguments as int;
        return MaterialPageRoute(
          builder: (_) => LawyerProfileScreen(providerId: providerId),
        );

      case AppRoutes.lawyerCaseDetails:
        return MaterialPageRoute(
          builder: (_) => const LawyerCaseDetailsScreen(),
          settings: setting,
        );
      case AppRoutes.lawyerConsultations:
        return MaterialPageRoute(
          builder: (_) => const LawyerConsultationsScreen(),
        );
      case AppRoutes.lawyerConsultationDetails:
        final id = _routeInt(setting.arguments);
        if (id <= 0) {
          return MaterialPageRoute(
            builder: (_) => const LawyerConsultationsScreen(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => LawyerConsultationDetailsScreen(consultationId: id),
        );
      case AppRoutes.lawyerDocuments:
        return MaterialPageRoute(builder: (_) => const LawyerDocumentsScreen());
      case AppRoutes.lawyerLibrary:
        return MaterialPageRoute(
          builder: (_) => const LawyerLegalLibraryScreen(),
        );
      case AppRoutes.lawyerTasks:
        return MaterialPageRoute(builder: (_) => const LawyerTasksScreen());
      case AppRoutes.lawyerReports:
        return MaterialPageRoute(builder: (_) => const LawyerReportsScreen());
      case AppRoutes.lawyerSearch:
        return MaterialPageRoute(builder: (_) => const LawyerSearchScreen());
      case AppRoutes.lawyerOpportunities:
        final initialTab = (setting.arguments as int?) ?? 0;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => di.sl<LawyerRequestsCubit>()..getRequests(),
              ),
              BlocProvider(
                create: (_) => di.sl<LawyerProposalsCubit>()..getProposalsData(),
              ),
            ],
            child: LawyerOpportunitiesScreen(initialTabIndex: initialTab),
          ),
        );
      case AppRoutes.lawyerSpecializations:
        return MaterialPageRoute(
          builder: (_) => const LawyerSpecializationsScreen(),
        );
      case AppRoutes.lawyerServices:
        return MaterialPageRoute(builder: (_) => const LawyerServicesScreen());
      case AppRoutes.lawyerServiceDetails:
        final args = setting.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LawyerServiceDetailsScreen(
            serviceId: args['id'] as int,
            title: args['title'] as String,
          ),
        );
      case AppRoutes.lawyerAddService:
        return MaterialPageRoute(
          builder: (_) => const LawyerAddServiceScreen(),
        );
      case AppRoutes.lawyerUpdateService:
        final service = setting.arguments as LawyerService;
        return MaterialPageRoute(
          builder: (_) => LawyerUpdateServiceScreen(service: service),
        );
      case AppRoutes.lawyerProposals:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => di.sl<LawyerRequestsCubit>()..getRequests(),
              ),
              BlocProvider(
                create: (_) => di.sl<LawyerProposalsCubit>()..getProposalsData(),
              ),
            ],
            child: const LawyerOpportunitiesScreen(initialTabIndex: 2),
          ),
        );
      case AppRoutes.lawyerClients:
        return MaterialPageRoute(builder: (_) => const LawyerClientsScreen());
      case AppRoutes.lawyerBookings:
        return MaterialPageRoute(builder: (_) => const LawyerBookingsScreen());
      case AppRoutes.lawyerSubscription:
        return MaterialPageRoute(
          builder: (_) => const LawyerSubscriptionScreen(),
        );
      case AppRoutes.lawyerWallet:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<LawyerWalletCubit>()..getWalletData(),
            child: const LawyerWalletScreen(),
          ),
        );
      case AppRoutes.lawyerReferral:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<ReferralCubit>()),
              BlocProvider(create: (_) => di.sl<ReferralHistoryCubit>()),
            ],
            child: const LawyerReferralScreen(),
          ),
        );
      case AppRoutes.lawyerReferralHistory:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<ReferralHistoryCubit>(),
            child: const LawyerReferralHistoryScreen(),
          ),
        );
      case chat:
        final args = setting.arguments as Map<String, dynamic>? ?? {};
        final roomId = args['chatRoomId'] as int? ?? 0;
        final isCall = args['isCall'] as bool? ??
            args['isCallType'] as bool? ??
            (args['serviceType'] != null &&
                _isCallServiceType(args['serviceType'].toString()));
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                di.sl<ChatMessagesCubit>(param1: roomId)..loadMessages(),
            child: ChatScreen(
              chatRoomId: roomId,
              lawyerName: args['lawyerName'] as String? ?? '',
              lawyerPhoto: args['lawyerPhoto'] as String?,
              caseTitle: args['caseTitle'] as String?,
              isCall: isCall,
            ),
          ),
        );
      case lawyerChat:
        final args = setting.arguments as Map<String, dynamic>? ?? {};
        final roomId = args['chatRoomId'] as int? ?? 0;
        final isCall = args['isCall'] as bool? ??
            args['isCallType'] as bool? ??
            (args['serviceType'] != null &&
                _isCallServiceType(args['serviceType'].toString()));
        final isVideo = args['isVideo'] == true;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    di.sl<LawyerChatMessagesCubit>(param1: roomId)
                      ..loadMessages(),
              ),
              BlocProvider(create: (_) => di.sl<LawyerCallCubit>()),
            ],
            child: LawyerChatScreen(
              chatRoomId: roomId,
              clientName: args['clientName'] as String? ?? '',
              clientPhoto: args['clientPhoto'] as String?,
              caseTitle: args['caseTitle'] as String?,
              isCall: isCall,
              isVideo: isVideo,
            ),
          ),
        );
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case lawyerChatList:
        return MaterialPageRoute(builder: (_) => const LawyerChatListScreen());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: MainAppbar(
              title: AppStrings.noRouteFound.tr(context),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noRouteFound.tr(context),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
