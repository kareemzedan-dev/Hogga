import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/features/lawyer/clients/presentation/cubit/lawyer_clients_cubit.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/features/lawyer/clients/domain/entities/lawyer_client.dart';
import 'package:hogga/injection_container.dart';

class LawyerClientsScreen extends StatefulWidget {
  const LawyerClientsScreen({super.key});

  @override
  State<LawyerClientsScreen> createState() => _LawyerClientsScreenState();
}

class _LawyerClientsScreenState extends State<LawyerClientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.pageBg,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: context.divColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        title: Text(
          AppStrings.clients.tr(context),
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => sl<LawyerClientsCubit>()..getClients(),
        child: SafeArea(
          child: BlocBuilder<LawyerClientsCubit, LawyerClientsState>(
            builder: (context, state) {
              if (state is LawyerClientsLoading) {
                return const LawyerShimmerLoading();
              } else if (state is LawyerClientsError) {
                return CustomErrorState(
                  message: state.message,
                  onRetry: () =>
                      context.read<LawyerClientsCubit>().getClients(),
                );
              } else if (state is LawyerClientsLoaded) {
                final filteredClients = state.clients
                    .where((c) => c.name.contains(_searchQuery))
                    .toList();

                if (state.clients.isEmpty) {
                  return CustomEmptyState(
                    title: AppStrings.noClients.tr(context),
                    subtitle: AppStrings.noClientsSubtitle.tr(context),
                    icon: Icons.people_outline,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<LawyerClientsCubit>().getClients(),
                  child: Column(
                    children: [
                      _buildSearchBar(context),
                      Expanded(
                        child: filteredClients.isEmpty
                            ? CustomEmptyState(
                                title: AppStrings.noResults.tr(context),
                                subtitle: AppStrings.noResultsSubtitle.tr(
                                  context,
                                ),
                                icon: Icons.search_off_rounded,
                              )
                            : ListView.separated(
                                padding: EdgeInsets.all(20.w),
                                itemCount: filteredClients.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 16.h),
                                itemBuilder: (context, index) {
                                  return _buildClientCard(
                                    context,
                                    filteredClients[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: AppStrings.searchByClientName.tr(context),
          prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary),
          filled: true,
          fillColor: context.pageBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, LawyerClient client) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.accentGolden.withValues(alpha: 0.1),
            backgroundImage: client.photo != null && client.photo!.isNotEmpty
                ? CachedNetworkImageProvider(client.photo!) as ImageProvider
                : const AssetImage(AppAssets.userPlaceholder) as ImageProvider,
            child: client.photo == null
                ? Icon(Icons.person, color: context.accentGolden)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  client.activeCasesText ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (client.hasCommunicationAction)
            IconButton(
              tooltip: client.canOpenChat
                  ? AppStrings.chat.tr(context)
                  : client.serviceType == 'video'
                  ? AppStrings.videoCall.tr(context)
                  : AppStrings.voiceCall.tr(context),
              onPressed: () => _openClientService(context, client),
              icon: Icon(
                client.canOpenChat
                    ? Icons.chat_bubble_outline
                    : client.serviceType == 'video'
                    ? Icons.videocam_outlined
                    : Icons.call_outlined,
                color: client.canOpenChat
                    ? const Color(0xFF2D9CDB)
                    : const Color(0xFF27AE60),
              ),
            ),
        ],
      ),
    );
  }

  void _openClientService(BuildContext context, LawyerClient client) {
    final roomId = client.chatRoomId;
    if (roomId == null || roomId <= 0) return;

    if (client.canOpenCall) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<LawyerCallCubit>(),
            child: LawyerAgoraCallScreen(
              roomId: roomId,
              clientName: client.name,
              isVideo: client.serviceType == 'video',
            ),
          ),
        ),
      );
      return;
    }

    if (client.canOpenChat) {
      Navigator.pushNamed(
        context,
        AppRoutes.lawyerChat,
        arguments: {
          'chatRoomId': roomId,
          'clientName': client.name,
          'caseTitle': client.activeCasesText,
        },
      );
    }
  }
}
