class AppEndPoints {
  static const String baseUrl = "https://hogga.wingital.com/api/";
  static const String loginEndPoint = "auth/login";
  static const String logoutEndPoint = "/logout";
  static const String registerEndPoint = "auth/register";
  static const String resetPasswordEndPoint = "auth/password/reset";

  static const String otpEndPoint = "/reset-password";
  static const String verifyOtpEndPoint = "auth/otp/verify";
  static const String resendOtpEndPoint = "auth/otp/send";
  static const String lawyerLoginEndPoint = "lawyer/auth/login";
  static const String lawyerVerifyOtpEndPoint = "lawyer/auth/verify";
  static const String lawyerSendOtpEndPoint = "lawyer/auth/send-otp";
  static const String lawyerProviderTypesEndPoint =
      "lawyer/auth/provider-types";
  static const String lawyerSpecializationsEndPoint =
      "lawyer/auth/specializations";
  static const String lawyerRegisterEndPoint = "lawyer/auth/register";
  static const String lawyerCompleteProfileEndPoint =
      "lawyer/auth/complete-profile";
  static const String lawyerHomeEndPoint = "lawyer/home";
  static const String lawyerReportsEndPoint = "lawyer/home/reports";
  static const String lawyerToggleActiveEndPoint = "lawyer/home/toggle-active";
  static const String lawyerUpdateSettingsEndPoint =
      "lawyer/home/update-settings";
  static const String lawyerDocumentsEndPoint = "lawyer/documents";
  static const String lawyerLibrarySearchEndPoint = "lawyer/library/search";
  static const String lawyerLibraryCategoryEndPoint = "lawyer/library/category";
  static const String lawyerLibraryDetailsEndPoint = "lawyer/library";
  static const String lawyerTasksEndPoint = "lawyer/tasks";
  static const String lawyerRequestsEndPoint = "lawyer/requests";
  static const String lawyerProposalsEndPoint = "lawyer/proposals";
  static const String lawyerAvailableServicesEndPoint =
      "lawyer/proposals/available-services";
  static const String lawyerSubmitProposalEndPoint = "lawyer/proposals/submit";
  static const String lawyerUpdateProposalEndPoint = "lawyer/proposals/update";
  static const String lawyerDeleteProposalEndPoint = "lawyer/proposals/delete";
  static const String lawyerBookingsEndPoint = "lawyer/bookings";
  static const String lawyerMyProposalsEndPoint =
      "lawyer/proposals/my-proposals";
  static String getLawyerProposalServiceDetailsEndPoint(int id) =>
      "lawyer/proposals/details/$id";
  static const String lawyerCasesEndPoint = "lawyer/cases";
  static const String lawyerClientsEndPoint = "lawyer/clients";
  static const String lawyerStatsEndPoint = "lawyer/stats";
  static const String lawyerWalletEndPoint = "lawyer/wallet";
  static const String lawyerWalletTransactionsEndPoint =
      "lawyer/wallet/transactions";
  static const String lawyerWithdrawEndPoint = "lawyer/wallet/withdraw";
  static const String lawyerOnlineStatusEndPoint = "lawyer/home/toggle-active";
  static const String lawyerAvailabilityEndPoint = "lawyer/availability";
  static const String getProfileEndPoint = "user/profile";
  static const String updateProfileEndPoint = "user/profile";
  static const String updateAvatarEndPoint = "user/update-avatar";
  static const String updatePasswordEndPoint = "user/change-password";
  static const String getCategoriesEndPoint = "categories";
  static const String getBanners = "banners";
  static const String getHomeEndPoint = "app/home";
  static const String getSubCategoriesEndPoint = "app/sub-categories";
  static const String getChildCategoriesEndPoint = "app/child-categories";
  static const String getServicesEndPoint = "app/services";
  static String getServiceDetailsEndPoint(int id) => "app/services/$id";
  static String getProviderDetailsEndPoint(int id) => "app/providers/$id";
  static const String getProvidersEndPoint = "app/providers";
  static const String getFavoritesEndPoint = "favorites";
  static const String toggleFavoriteEndPoint = "favorites/";
  static const String updateLocationEndPoint = "update-location";
  static const String userPaymentsEndPoint = "user/payments";
  static String getUserPaymentDetailsEndPoint(int id) => "user/payments/$id";
  static const String myOrders = "my-bookings";
  static const String myOrdersDetails = "my-bookings-details/";
  // Chat
  static const String chats = "chats";
  static String chatMessages(int roomId) => "chats/$roomId/messages";
  static String sendChatMessage(int roomId) => "chats/$roomId/messages";
  static String callToken(int roomId) => "chats/$roomId/call-token";
  static String connectCall(int callId) => "chats/calls/$callId/connect";
  static String endCall(int callId) => "chats/calls/$callId/end";
  static String callStatus(int callId) => "chats/calls/$callId/status";
  // Lawyer Chat
  static const String lawyerChats = "lawyer/chats";
  static String lawyerChatMessages(int roomId) =>
      "lawyer/chats/$roomId/messages";
  static String lawyerSendChatMessage(int roomId) =>
      "lawyer/chats/$roomId/messages";
  static String lawyerCallToken(int roomId) =>
      "lawyer/chats/$roomId/call-token";
  static String lawyerConnectCall(int callId) =>
      "lawyer/chats/calls/$callId/connect";
  static String lawyerEndCall(int callId) => "lawyer/chats/calls/$callId/end";
  static String lawyerCallStatus(int callId) =>
      "lawyer/chats/calls/$callId/status";
  static const String createOrder = "bookings";
  // ================= Store =================
  static const String getStoreDetailsEndPoint = "store/";
  static const String addStore = "provider/add-Store";
  static const String addProduct = "provider/add-service";
  static const String deleteProduct = "provider/services-delete/"; // + id
  static const String uploadMedia = "provider/upload-media";
  static const String deleteMedia = "provider/delete-media/"; // + id
  static const String home = "provider/home";
  static const String order = "provider/booking";
  static const String stop = "provider/stop";
  static const String data = "provider/data";
  static const String validateCoupon = "coupons/validate";
  static const String updateToken = "user/token";
  static const String updateProduct = "provider/services-update";
  static const String contactUsEndPoint = "public/contact-us";
  static const String instructionsEndPoint = "public/instructions";
  static const String privacyEndPoint = "public/privacy";
  static const String appConfigEndPoint = "app/config";
  static const String itemCategoriesEndPoint = "app/item-categories";
  static const String storeServiceEndPoint = "services/store-service";
  static const String verifyServiceCouponEndPoint = "services/coupons/verify";
  static const String uploadLegalCaseFilesEndPoint =
      "services/legal-cases/upload";
  static const String acceptLegalCaseProposalEndPoint =
      "services/legal-cases/accept-proposal";
  static const String cancelLegalCaseEndPoint = "services/legal-cases/cancel";
  static String payLegalCaseEndPoint(int id) => "services/legal-cases/$id/pay";
  static String rateProviderEndPoint(int providerId) =>
      "providers/$providerId/rate";
  static const String notificationsEndPoint = "user/notifications";
  static const String markAsReadEndPoint = "user/notifications/read";

  // ================= Availability =================
  static const String postAvailability = "provider/availability"; // POST
  static const String getAvailability = "provider/availability"; // GET
  static const String updateWorkHours = "provider/update-work-hours";
  static const String availabilityDelete =
      "provider/availability-delete/"; // + id

  // ================= Payment =================
  static const String payStore = "pay/store";

  // ================= Discounts =================
  static const String discounts = "provider/discounts"; // GET/POST
  static const String discountById = "provider/discounts/";

  static const String lawyerUpdateTokenEndPoint = "user/token";
  static const String lawyerServicesEndPoint = "lawyer/services";
  static const String lawyerCategoryItemsEndPoint =
      "lawyer/services/categores-items";
  static const String lawyerAddServiceEndPoint = "lawyer/services/store";
  static String getLawyerUpdateServiceEndPoint(int id) =>
      "lawyer/services/update/$id";
  static String getLawyerDeleteServiceEndPoint(int id) =>
      "lawyer/services/delete/$id";
  static String getLawyerChangeServiceStatusEndPoint(int id) =>
      "lawyer/services/execute/$id";
  static String getLawyerServiceDetailsEndPoint(int id) =>
      "lawyer/services/details/$id";
  static const String lawyerNotificationsEndPoint = "lawyer/notifications";
  static const String lawyerMarkAsReadEndPoint = "lawyer/notifications/read";

  // ================= Subscription =================
  static const String subscriptionPackagesEndPoint =
      "lawyer/subscription/packages";
  static const String currentSubscriptionEndPoint =
      "lawyer/subscription/current";
  static const String subscriptionProgressEndPoint =
      "lawyer/subscription/progress";
  static const String subscribeEndPoint = "lawyer/subscription/subscribe";
}
