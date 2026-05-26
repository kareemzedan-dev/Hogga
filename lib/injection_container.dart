import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'core/theme/theme_cubit.dart';
import 'core/localization/localization_cubit.dart';

// Auth
import 'features/shared/auth/data/datasources/auth_remote_data_source.dart';

import 'features/shared/auth/domain/repositories/auth_repository.dart';
import 'features/shared/auth/domain/repositories/auth_repository_impl.dart';
import 'features/shared/auth/presentation/shared/cubit/auth_cubit.dart';
import 'features/shared/auth/presentation/lawyer/cubit/lawyer_registration_cubit.dart';

// Favorites




// Removed Bookings

// Home
import 'features/user/home/data/datasources/home_remote_data_source.dart';
import 'features/user/home/data/repositories/home_repository.dart';
import 'features/user/home/presentation/cubit/home_cubit.dart';

// Profile
import 'features/user/my_orders/data/datasources/my_orders_remote_data_source.dart';
import 'features/user/my_orders/domin/repositories/my_orders_repository.dart';
import 'features/user/my_orders/presentation/cubit/legal_case_actions_cubit.dart';
import 'features/user/my_orders/presentation/cubit/my_orders_cubit.dart';
import 'features/user/profile/data/datasources/profile_remote_data_source.dart';
import 'features/user/profile/data/repositories/profile_repository.dart';
import 'features/user/profile/presentation/cubit/profile_cubit.dart';

// More
import 'features/user/more/data/datasources/more_remote_datasource.dart';
import 'features/user/more/data/repositories/more_repository.dart';
import 'features/user/more/presentation/contact_us/manager/contact_us_cubit.dart';
import 'features/user/more/presentation/instructions/manager/instructions_cubit.dart';
import 'features/user/more/presentation/privacy/manager/privacy_policy_cubit.dart';

// Bainah Services
import 'features/user/bainah_services/data/datasources/bainah_remote_datasource.dart';
import 'features/user/bainah_services/data/repositories/bainah_repository.dart';
import 'features/user/bainah_services/presentation/manager/item_categories_cubit.dart';
import 'features/user/bainah_services/presentation/manager/service_request_cubit.dart';
import 'features/user/notifications/data/repositories/notifications_repository.dart';
import 'features/user/notifications/presentation/cubit/notifications_cubit.dart';






// Lawyer Features
// Wallet
import 'features/lawyer/wallet/data/datasources/wallet_remote_data_source.dart';
import 'features/lawyer/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/lawyer/wallet/domain/repositories/wallet_repository.dart';
import 'features/lawyer/wallet/presentation/cubit/lawyer_wallet_cubit.dart';

// Cases
import 'features/lawyer/cases/data/datasources/cases_remote_data_source.dart';
import 'features/lawyer/cases/data/repositories/cases_repository_impl.dart';
import 'features/lawyer/cases/domain/repositories/cases_repository.dart';
import 'features/lawyer/cases/presentation/cubit/lawyer_cases_cubit.dart';

// Clients
import 'features/lawyer/clients/data/datasources/clients_remote_data_source.dart';
import 'features/lawyer/clients/data/repositories/clients_repository_impl.dart';
import 'features/lawyer/clients/domain/repositories/clients_repository.dart';
import 'features/lawyer/clients/presentation/cubit/lawyer_clients_cubit.dart';

// Overview
import 'features/lawyer/overview/data/datasources/overview_remote_data_source.dart';
import 'features/lawyer/overview/data/repositories/overview_repository_impl.dart';
import 'features/lawyer/overview/domain/repositories/overview_repository.dart';
import 'features/lawyer/overview/presentation/cubit/lawyer_overview_cubit.dart';

// Proposals
import 'features/lawyer/proposals/data/datasources/proposals_remote_data_source.dart';
import 'features/lawyer/proposals/data/repositories/proposals_repository_impl.dart';
import 'features/lawyer/proposals/domain/repositories/proposals_repository.dart';
import 'features/lawyer/proposals/presentation/cubit/lawyer_proposals_cubit.dart';

// Requests
import 'features/lawyer/requests/data/datasources/requests_remote_data_source.dart';
import 'features/lawyer/requests/data/repositories/requests_repository_impl.dart';
import 'features/lawyer/requests/domain/repositories/requests_repository.dart';
import 'features/lawyer/requests/presentation/cubit/lawyer_requests_cubit.dart';

// Library
import 'features/lawyer/library/data/datasources/library_remote_data_source.dart';
import 'features/lawyer/library/data/repositories/library_repository_impl.dart';
import 'features/lawyer/library/domain/repositories/library_repository.dart';
import 'features/lawyer/library/presentation/cubit/lawyer_library_cubit.dart';

// Tasks
import 'features/lawyer/tasks/data/datasources/tasks_remote_data_source.dart';
import 'features/lawyer/tasks/data/repositories/tasks_repository_impl.dart';
import 'features/lawyer/tasks/domain/repositories/tasks_repository.dart';
import 'features/lawyer/tasks/presentation/cubit/lawyer_tasks_cubit.dart';

// Reports
import 'features/lawyer/reports/data/datasources/reports_remote_data_source.dart';
import 'features/lawyer/reports/data/repositories/reports_repository_impl.dart';
import 'features/lawyer/reports/domain/repositories/reports_repository.dart';
import 'features/lawyer/reports/presentation/cubit/lawyer_reports_cubit.dart';

// Documents
import 'features/lawyer/documents/data/datasources/documents_remote_data_source.dart';
import 'features/lawyer/documents/data/repositories/documents_repository_impl.dart';
import 'features/lawyer/documents/domain/repositories/documents_repository.dart';
import 'features/lawyer/documents/presentation/cubit/lawyer_documents_cubit.dart';

// Bookings
import 'features/lawyer/bookings/data/datasources/bookings_remote_data_source.dart';
import 'features/lawyer/bookings/data/repositories/bookings_repository_impl.dart';
import 'features/lawyer/bookings/domain/repositories/bookings_repository.dart';
import 'features/lawyer/bookings/presentation/cubit/lawyer_bookings_cubit.dart';

// Services
import 'features/lawyer/services/data/datasources/services_remote_data_source.dart';
import 'features/lawyer/services/data/repositories/services_repository_impl.dart';
import 'features/lawyer/services/domain/repositories/services_repository.dart';
import 'features/lawyer/services/presentation/cubit/lawyer_services_cubit.dart';
import 'features/lawyer/services/presentation/cubit/lawyer_service_details_cubit.dart';
import 'features/lawyer/services/presentation/cubit/add_service_cubit.dart';
import 'features/lawyer/services/presentation/cubit/update_service_cubit.dart';
import 'features/lawyer/services/presentation/cubit/delete_service_cubit.dart';
import 'features/lawyer/services/presentation/cubit/change_service_status_cubit.dart';
import 'features/lawyer/services/presentation/cubit/lawyer_category_items_cubit.dart';

// Subscription
import 'features/lawyer/subscription/data/datasources/subscription_remote_data_source.dart';
import 'features/lawyer/subscription/data/repositories/subscription_repository.dart';
import 'features/lawyer/subscription/presentation/cubit/subscription_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio()); 
  sl.registerLazySingleton(() => ApiClient(
    dio: sl(),
    onUnauthorized: () => sl<AuthCubit>().logout(),
  ));

  // Core
  sl.registerFactory(() => ThemeCubit());
  sl.registerFactory(() => LocalizationCubit());

  // Auth
  sl.registerLazySingleton(() => AuthCubit(authRepository: sl()));
  sl.registerFactory(() => LawyerRegistrationCubit(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl())); // Inject ApiClient

  // Home
  sl.registerFactory(() => HomeCubit(repository: sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(apiClient: sl()));


  // myBookings
  sl.registerFactory(() => MyOrdersCubit(repository: sl()));
  sl.registerFactory(() => LegalCaseActionsCubit(repository: sl()));
  sl.registerLazySingleton<MyOrderRepository>(() => MyOrderRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<MyOrdersRemoteDataSource>(() => MyOrdersRemoteDataSourceImpl(apiClient: sl()));





  // Profile
  sl.registerFactory(() => ProfileCubit(repository: sl(), authCubit: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(apiClient: sl()));

  // More
  sl.registerFactory(() => ContactUsCubit(sl()));
  sl.registerFactory(() => InstructionsCubit(sl()));
  sl.registerFactory(() => PrivacyPolicyCubit(sl()));
  sl.registerFactory(() => ItemCategoriesCubit(sl()));
  sl.registerFactory(() => ServiceRequestCubit(repository: sl()));


  sl.registerLazySingleton<MoreRepository>(() => MoreRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<MoreRemoteDataSource>(() => MoreRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<BainahRepository>(() => BainahRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<BainahRemoteDataSource>(() => BainahRemoteDataSourceImpl(apiClient: sl()));

  // Notifications
  sl.registerFactory(() => NotificationsCubit(repository: sl()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(apiClient: sl()));


  // Lawyer Wallet
  sl.registerFactory(() => LawyerWalletCubit(repository: sl()));
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Cases
  sl.registerFactory(() => LawyerCasesCubit(repository: sl()));
  sl.registerLazySingleton<CasesRepository>(() => CasesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<CasesRemoteDataSource>(() => CasesRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Clients
  sl.registerFactory(() => LawyerClientsCubit(repository: sl()));
  sl.registerLazySingleton<ClientsRepository>(() => ClientsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ClientsRemoteDataSource>(() => ClientsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Overview
  sl.registerFactory(() => LawyerOverviewCubit(repository: sl(), subscriptionRepository: sl()));
  sl.registerLazySingleton<OverviewRepository>(() => OverviewRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<OverviewRemoteDataSource>(() => OverviewRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Bookings
  sl.registerFactory(() => LawyerBookingsCubit(repository: sl()));
  sl.registerLazySingleton<BookingsRepository>(() => BookingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<BookingsRemoteDataSource>(() => BookingsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Services
  sl.registerFactory(() => LawyerServicesCubit(repository: sl()));
  sl.registerFactory(() => LawyerServiceDetailsCubit(repository: sl()));
  sl.registerFactory(() => AddServiceCubit(repository: sl()));
  sl.registerFactory(() => UpdateServiceCubit(repository: sl()));
  sl.registerFactory(() => DeleteServiceCubit(repository: sl()));
  sl.registerFactory(() => ChangeServiceStatusCubit(repository: sl()));
  sl.registerFactory(() => LawyerCategoryItemsCubit(repository: sl()));
  sl.registerLazySingleton<ServicesRepository>(() => ServicesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ServicesRemoteDataSource>(() => ServicesRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Proposals
  sl.registerFactory(() => LawyerProposalsCubit(repository: sl()));
  sl.registerLazySingleton<ProposalsRepository>(() => ProposalsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProposalsRemoteDataSource>(() => ProposalsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Requests
  sl.registerFactory(() => LawyerRequestsCubit(repository: sl()));
  sl.registerLazySingleton<RequestsRepository>(() => RequestsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RequestsRemoteDataSource>(() => RequestsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Library
  sl.registerFactory(() => LawyerLibraryCubit(repository: sl()));
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LibraryRemoteDataSource>(() => LibraryRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Tasks
  sl.registerFactory(() => LawyerTasksCubit(repository: sl()));
  sl.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TasksRemoteDataSource>(() => TasksRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Reports
  sl.registerFactory(() => LawyerReportsCubit(repository: sl()));
  sl.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReportsRemoteDataSource>(() => ReportsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Documents
  sl.registerFactory(() => LawyerDocumentsCubit(repository: sl()));
  sl.registerLazySingleton<DocumentsRepository>(() => DocumentsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<DocumentsRemoteDataSource>(() => DocumentsRemoteDataSourceImpl(apiClient: sl()));

  // Lawyer Subscription
  sl.registerFactory(() => SubscriptionCubit(repository: sl()));
  sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepository(remoteDataSource: sl()));
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(apiClient: sl()));
}

