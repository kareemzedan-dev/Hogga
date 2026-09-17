import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/widgets/app_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hogga/features/user/my_orders/presentation/pages/my_order_details.dart';
import 'package:hogga/features/user/my_orders/presentation/widgets/order_card.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/widgets/main_appbar.dart';
import '../../../../../core/widgets/custom_empty_state.dart';
import '../../../../../core/widgets/custom_error_state.dart';
import '../cubit/my_orders_cubit.dart';
import '../cubit/my_orders_states.dart';
import '../cubit/legal_case_actions_cubit.dart';
import '../widgets/order_shimmer_list.dart';
import '../../../../../injection_container.dart' as di;

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({super.key});

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView>
    with AutomaticKeepAliveClientMixin {
  int _activeTab = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MyOrdersCubit>();
      final state = cubit.state;
      if (state is! MyOrdersLoaded && state is! MyOrdersLoading) {
        cubit.getMyOrders(type: 'ongoing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: MainAppbar(
        title: AppStrings.myOrders.tr(context),
        backBtn: false,
        backgroundColor: context.pageBg,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderTab(
                      context: context,
                      title: AppStrings.ongoingConsultations.tr(context),
                      isSelected: _activeTab == 0,
                      onTap: () {
                        setState(() => _activeTab = 0);
                        context.read<MyOrdersCubit>().getMyOrders(
                          type: 'ongoing',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHeaderTab(
                      context: context,
                      title: AppStrings.consultationHistory.tr(context),
                      isSelected: _activeTab == 1,
                      onTap: () {
                        setState(() => _activeTab = 1);
                        context.read<MyOrdersCubit>().getMyOrders(
                          type: 'finished',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: BlocConsumer<MyOrdersCubit, MyOrdersState>(
                listener: (context, state) {
                  if (state is MyOrderPaymentError) {
                    AppSnackbar.showError(context, message: state.message);
                  } else if (state is MyOrderPaymentSuccess) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.paymentWebView,
                      arguments: {
                        'paymentUrl': state.paymentUrl,
                        'caseNumber': state.caseNumber,
                        'caseId': state.caseId,
                        'recordType': state.recordType,
                      },
                    );
                  }
                },
                builder: (context, state) {
                  if (state is MyOrdersLoading ||
                      state is MyOrderPaymentLoading) {
                    return const OrderShimmerList();
                  }

                  if (state is MyOrdersError) {
                    return CustomErrorState(
                      message: state.message,
                      onRetry: () => context.read<MyOrdersCubit>().getMyOrders(
                        type: _activeTab == 0 ? 'ongoing' : 'finished',
                        forceRefresh: true,
                      ),
                    );
                  }

                  if (state is MyOrdersLoaded) {
                    final filteredOrders = state.orders;

                    if (filteredOrders.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async =>
                            context.read<MyOrdersCubit>().getMyOrders(
                              type: _activeTab == 0 ? 'ongoing' : 'finished',
                              forceRefresh: true,
                            ),
                        color: AppColors.golden,
                        child: CustomEmptyState(
                          title: AppStrings.noOrdersInSection.tr(context),
                          subtitle:
                              (_activeTab == 0
                                      ? AppStrings.noActiveOrdersSubtitle
                                      : AppStrings.emptyOrderHistory)
                                  .tr(context),
                          icon: _activeTab == 0
                              ? Icons.assignment_outlined
                              : Icons.assignment_turned_in_outlined,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async =>
                          context.read<MyOrdersCubit>().getMyOrders(
                            type: _activeTab == 0 ? 'ongoing' : 'finished',
                            forceRefresh: true,
                          ),
                      color: AppColors.golden,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.horizontalPadding,
                          vertical: 8,
                        ),
                        itemCount: filteredOrders.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return OrderCard(
                            key: ValueKey(
                              'order_${order.recordType}_${order.id}',
                            ),
                            order: order,
                            isPrevious: _activeTab == 1,
                            onTap: () async {
                              final cubit = context.read<MyOrdersCubit>();
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (_) => di.sl<MyOrdersCubit>(),
                                      ),
                                      BlocProvider(
                                        create: (_) =>
                                            di.sl<LegalCaseActionsCubit>(),
                                      ),
                                    ],
                                    child: OrderDetailsView(
                                      orderId: order.id,
                                      recordType: order.recordType,
                                    ),
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                if (result is Map &&
                                    result['cancelled'] == true) {
                                  // Remove the cancelled order immediately from the list without a network call
                                  final cancelledId = result['orderId'] as int?;
                                  if (cancelledId != null) {
                                    cubit.removeOrderById(cancelledId);
                                  }
                                  // Force refresh from server in the background to update all lists/status
                                  cubit.getMyOrders(
                                    type: _activeTab == 0
                                        ? 'ongoing'
                                        : 'finished',
                                    forceRefresh: true,
                                  );
                                } else {
                                  cubit.restoreOrdersList();
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTab({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Selected = golden button; unselected = card background from theme
          color: isSelected ? AppColors.golden : context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.golden : context.divColor,
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.golden.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          title,
          style: context.text.titleMedium?.copyWith(
            color: isSelected ? context.textPrimary : context.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
