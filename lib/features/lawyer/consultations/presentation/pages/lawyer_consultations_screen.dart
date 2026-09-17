import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/config/routes/app_routes.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/app_snakbar.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:hogga/core/widgets/custom_empty_state.dart';
import 'package:hogga/core/widgets/custom_error_state.dart';
import 'package:hogga/core/widgets/custom_network_image.dart';
import 'package:hogga/core/widgets/hogga_card.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_call_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/cubit/lawyer_chat_messages_cubit.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_agora_call_screen.dart';
import 'package:hogga/features/lawyer/chat/presentation/pages/lawyer_chat_screen.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_card.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_shimmer_loading.dart';
import 'package:hogga/features/lawyer/common/presentation/widgets/lawyer_status_badge.dart';
import 'package:hogga/features/lawyer/consultations/data/models/lawyer_consultation_model.dart';
import 'package:hogga/features/lawyer/consultations/domain/repositories/lawyer_consultations_repository.dart';
import 'package:hogga/features/lawyer/consultations/presentation/cubit/lawyer_consultations_cubit.dart';
import 'package:hogga/injection_container.dart';

class LawyerConsultationsScreen extends StatefulWidget {
  final bool isBottomNav;

  const LawyerConsultationsScreen({super.key, this.isBottomNav = false});

  @override
  State<LawyerConsultationsScreen> createState() =>
      _LawyerConsultationsScreenState();
}

class _LawyerConsultationsScreenState extends State<LawyerConsultationsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LawyerConsultationsCubit>()..getConsultations(),
      child: Scaffold(
        backgroundColor: context.pageBg,
        appBar: MainAppbar(
          title: AppStrings.consultationsTab.tr(context),
          backBtn: !widget.isBottomNav,
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: TextButton.icon(
                onPressed: () => _showPricingSheet(context),
                icon: Icon(
                  Icons.tune_rounded,
                  size: 16.sp,
                  color: context.accentGolden,
                ),
                label: Text(
                  AppStrings.edit.tr(context),
                  style: TextStyle(
                    color: context.accentGolden,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: context.accentGolden.withValues(alpha: 0.12),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: context.accentGolden.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<LawyerConsultationsCubit, LawyerConsultationsState>(
          builder: (context, state) {
            if (state is LawyerConsultationsLoading) {
              return const LawyerShimmerLoading();
            }

            if (state is LawyerConsultationsError) {
              return CustomErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<LawyerConsultationsCubit>().getConsultations(),
              );
            }

            final consultations = state is LawyerConsultationsLoaded
                ? state.consultations
                : <LawyerConsultationModel>[];

            final filtered = consultations.where((c) {
              final query = _searchQuery.trim().toLowerCase();
              final matchesSearch =
                  query.isEmpty ||
                  c.title.toLowerCase().contains(query) ||
                  c.consultationNumber.toLowerCase().contains(query) ||
                  c.client.name.toLowerCase().contains(query) ||
                  c.id.toString().contains(query);
              final matchesStatus = _matchesFilter(c);
              return matchesSearch && matchesStatus;
            }).toList();

            return RefreshIndicator(
              color: context.accentGolden,
              onRefresh: () =>
                  context.read<LawyerConsultationsCubit>().getConsultations(),
              child: Column(
                children: [
                  _buildSearchAndFilter(context),
                  Expanded(
                    child: SafeArea(
                      child: filtered.isEmpty
                          ? LayoutBuilder(
                              builder: (context, constraints) =>
                                  SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 36.h,
                                            bottom: 48.h,
                                          ),
                                          child: CustomEmptyState(
                                            title: _searchQuery.isEmpty
                                                ? AppStrings.noDataFound.tr(
                                                    context,
                                                  )
                                                : AppStrings.noResults.tr(
                                                    context,
                                                  ),
                                            subtitle: _searchQuery.isEmpty
                                                ? AppStrings.noDataFound.tr(
                                                    context,
                                                  )
                                                : AppStrings
                                                      .noSearchResultsSubtitle
                                                      .tr(context),
                                            icon: _searchQuery.isEmpty
                                                ? Icons.support_agent_rounded
                                                : Icons.search_off_rounded,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(12.w),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 0.h),
                              itemBuilder: (context, index) =>
                                  _ConsultationCard(
                                    consultation: filtered[index],
                                  ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final filters = [
      _ConsultationFilterItem('all', AppStrings.all.tr(context)),
      _ConsultationFilterItem(
        'ongoing',
        AppStrings.ongoingConsultations.tr(context),
      ),
      _ConsultationFilterItem('completed', AppStrings.completed.tr(context)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'البحث برقم الاستشارة أو العنوان أو العميل...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textSecondary,
              ),
              filled: true,
              fillColor: context.cardBg,
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
          SizedBox(height: 12.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 8.w,
              children: filters.map((filter) {
                final isSelected = _selectedFilter == filter.type;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: isSelected,
                  onSelected: (v) {
                    if (v) setState(() => _selectedFilter = filter.type);
                  },
                  selectedColor: context.accentGolden,
                  labelStyle: context.text.labelSmall?.copyWith(
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: context.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: isSelected
                          ? context.accentGolden
                          : context.divColor,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  bool _matchesFilter(LawyerConsultationModel consultation) {
    if (_selectedFilter == 'all') return true;
    final status = consultation.status.toLowerCase();
    if (_selectedFilter == 'completed') {
      return status == 'completed' || consultation.isCompletedByProvider;
    }
    return status != 'completed' && !consultation.isCompletedByProvider;
  }

  void _showPricingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConsultationPricingSheet(
        repository: sl<LawyerConsultationsRepository>(),
      ),
    );
  }
}

class _ConsultationPricingSheet extends StatefulWidget {
  final LawyerConsultationsRepository repository;

  const _ConsultationPricingSheet({required this.repository});

  @override
  State<_ConsultationPricingSheet> createState() =>
      _ConsultationPricingSheetState();
}

class _ConsultationPricingSheetState extends State<_ConsultationPricingSheet> {
  static const _types = [
    _PricingType(
      key: 'audio_video_immediate',
      labelKey: AppStrings.immediateConsultation,
      requiresDuration: true,
      defaultDurations: [15, 30],
    ),
    _PricingType(
      key: 'audio_video_scheduled',
      labelKey: AppStrings.scheduledConsultation,
      requiresDuration: true,
      defaultDurations: [30, 45, 60],
    ),
    _PricingType(
      key: 'article',
      labelKey: AppStrings.writtenConsultation,
      requiresDuration: false,
      defaultDurations: [0],
    ),
  ];

  final Map<String, List<_PriceRowControllers>> _controllers = {};
  var _selectedType = _types.first;
  var _isSaving = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

  Future<void> _loadPricing() async {
    final result = await widget.repository.getConsultationPricing();
    if (!mounted) return;

    result.fold(
      (failure) {
        _populateDefaults();
        setState(() => _isLoading = false);
      },
      (data) {
        for (final type in _types) {
          final typeData = data.firstWhere(
            (e) => e['type_key'] == type.key,
            orElse: () => <String, dynamic>{},
          );
          final prices = typeData['prices'] as List<dynamic>? ?? [];
          if (prices.isNotEmpty) {
            _controllers[type.key] = prices.map((p) {
              final dur = p['duration']?.toString() ?? '';
              final prc = p['price']?.toString() ?? '';
              return _PriceRowControllers(duration: dur, price: prc);
            }).toList();
          } else {
            _controllers[type.key] = type.defaultDurations
                .map(
                  (duration) => _PriceRowControllers(
                    duration: type.requiresDuration ? duration.toString() : '',
                  ),
                )
                .toList();
          }
        }
        setState(() => _isLoading = false);
      },
    );
  }

  void _populateDefaults() {
    for (final type in _types) {
      _controllers[type.key] = type.defaultDurations
          .map(
            (duration) => _PriceRowControllers(
              duration: type.requiresDuration ? duration.toString() : '',
            ),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    for (final rows in _controllers.values) {
      for (final row in rows) {
        row.dispose();
      }
    }
    super.dispose();
  }

  List<_PriceRowControllers> get _rows => _controllers[_selectedType.key]!;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 24.h),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h + bottomInset),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: context.divColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: context.accentGolden,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppStrings.manageConsultationPrices.tr(context),
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      AppStrings.consultationType.tr(context),
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: context.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 8.h,
                      children: _types.map((type) {
                        final selected = type.key == _selectedType.key;
                        return ChoiceChip(
                          label: Text(
                            type.labelKey.tr(context),
                            style: TextStyle(
                              color: selected
                                  ? (context.isDark
                                        ? AppColors.cream
                                        : Colors.white)
                                  : (context.isDark
                                        ? AppColors.cream
                                        : AppColors.primary),
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 11.5.sp,
                            ),
                          ),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.golden,
                          backgroundColor: context.pageBg,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.golden
                                  : context.divColor,
                            ),
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedType = type),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: context.pageBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: context.divColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Table column headers ──
                          if (_selectedType.requiresDuration)
                            Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 4.w,
                                  ), // align with delete icon space
                                  Expanded(
                                    child: Text(
                                      AppStrings.durationMinutes.tr(context),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '${AppStrings.priceAmount.tr(context)} (${AppStrings.currencyRial.tr(context)})',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30.w,
                                  ), // space for delete icon
                                ],
                              ),
                            ),
                          ...List.generate(_rows.length, (index) {
                            return _PriceRow(
                              row: _rows[index],
                              requiresDuration: _selectedType.requiresDuration,
                              canDelete: _rows.length > 1,
                              onDelete: () => _removeRow(index),
                            );
                          }),
                          SizedBox(height: 6.h),
                          TextButton.icon(
                            onPressed: _addRow,
                            style: TextButton.styleFrom(
                              foregroundColor: context.accentGolden,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              size: 16.sp,
                            ),
                            label: Text(
                              AppStrings.addPriceOption.tr(context),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // ── Compact Save Button ──
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: SizedBox(
                        height: 38.h,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                          label: Text(
                            AppStrings.savePrices.tr(context),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.accentGolden,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _addRow() {
    setState(() => _rows.add(_PriceRowControllers()));
  }

  void _removeRow(int index) {
    final row = _rows.removeAt(index);
    row.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    final prices = <Map<String, dynamic>>[];

    for (final row in _rows) {
      final price = double.tryParse(row.price.text.trim());
      final duration = int.tryParse(row.duration.text.trim());
      if (price == null || price <= 0) {
        AppSnackbar.showError(
          context,
          messageKey: AppStrings.pleaseCompleteAllFields,
        );
        return;
      }
      if (_selectedType.requiresDuration &&
          (duration == null || duration <= 0)) {
        AppSnackbar.showError(
          context,
          messageKey: AppStrings.pleaseCompleteAllFields,
        );
        return;
      }

      prices.add({
        if (_selectedType.requiresDuration) 'duration': duration,
        'price': price,
      });
    }

    setState(() => _isSaving = true);
    final result = await widget.repository.saveConsultationPricing(
      typeKey: _selectedType.key,
      prices: prices,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        AppSnackbar.showError(context, message: failure.message);
      },
      (message) {
        setState(() => _isSaving = false);
        AppSnackbar.showSuccess(context, message: message);
        Navigator.pop(context);
      },
    );
  }
}

class _PriceRow extends StatelessWidget {
  final _PriceRowControllers row;
  final bool requiresDuration;
  final bool canDelete;
  final VoidCallback onDelete;

  const _PriceRow({
    required this.row,
    required this.requiresDuration,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          if (requiresDuration) ...[
            Expanded(
              child: TextFormField(
                controller: row.duration,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.durationMinutes.tr(context),
                  hintStyle: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: context.cardBg,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: context.divColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: context.divColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: context.accentGolden,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: TextFormField(
              controller: row.price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.priceAmount.tr(context),
                hintStyle: TextStyle(
                  fontSize: 11.sp,
                  color: context.textSecondary,
                ),
                isDense: true,
                filled: true,
                fillColor: context.cardBg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 8.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: context.divColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: context.divColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: context.accentGolden,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: canDelete ? onDelete : null,
            padding: EdgeInsets.all(6.w),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18.sp,
              color: canDelete
                  ? AppColors.error
                  : context.textSecondary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRowControllers {
  final TextEditingController duration;
  final TextEditingController price;

  _PriceRowControllers({String duration = '', String price = ''})
    : duration = TextEditingController(text: duration),
      price = TextEditingController(text: price);

  void dispose() {
    duration.dispose();
    price.dispose();
  }
}

class _PricingType {
  final String key;
  final String labelKey;
  final bool requiresDuration;
  final List<int> defaultDurations;

  const _PricingType({
    required this.key,
    required this.labelKey,
    required this.requiresDuration,
    required this.defaultDurations,
  });
}

class LawyerConsultationDetailsScreen extends StatefulWidget {
  final int consultationId;

  const LawyerConsultationDetailsScreen({
    super.key,
    required this.consultationId,
  });

  @override
  State<LawyerConsultationDetailsScreen> createState() =>
      _LawyerConsultationDetailsScreenState();
}

class _LawyerConsultationDetailsScreenState
    extends State<LawyerConsultationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<LawyerConsultationsCubit>()
            ..getConsultationDetails(widget.consultationId),
      child: BlocConsumer<LawyerConsultationsCubit, LawyerConsultationsState>(
        listener: (context, state) {
          if (state is LawyerConsultationActionSuccess) {
            AppSnackbar.showSuccess(context, message: state.message);
          } else if (state is LawyerConsultationsError) {
            AppSnackbar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<LawyerConsultationsCubit>();
          final consultation = state is LawyerConsultationDetailsLoaded
              ? state.consultation
              : cubit.currentConsultation;

          if (state is LawyerConsultationDetailsLoading ||
              state is LawyerConsultationsInitial) {
            return Scaffold(
              backgroundColor: context.pageBg,
              body: const LawyerShimmerLoading(),
            );
          }

          if (consultation == null) {
            return Scaffold(
              backgroundColor: context.pageBg,
              appBar: AppBar(backgroundColor: context.cardBg),
              body: CustomErrorState(
                message: state is LawyerConsultationsError
                    ? state.message
                    : AppStrings.noDataFound,
                onRetry: () =>
                    cubit.getConsultationDetails(widget.consultationId),
              ),
            );
          }

          return Scaffold(
            backgroundColor: context.pageBg,
            appBar: MainAppbar(
              title: AppStrings.consultationDetails.tr(context),
            ),
            body: RefreshIndicator(
              color: AppColors.golden,
              onRefresh: () =>
                  cubit.getConsultationDetails(widget.consultationId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _ConsultationHeader(consultation: consultation),
                    SizedBox(height: 12.h),
                    _ClientCard(client: consultation.client),
                    if (consultation.isCallType &&
                        consultation.callDuration != null) ...[
                      SizedBox(height: 12.h),
                      _CallDurationBanner(
                        callDuration: consultation.callDuration,
                        isCallType: consultation.isCallType,
                        color: const Color(0xFF27AE60),
                      ),
                    ],
                    if (consultation.description.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _InfoCard(
                        title: AppStrings.description.tr(context),
                        value: consultation.description,
                        icon: Icons.notes_rounded,
                      ),
                    ],
                    if (consultation.hasChatRoom) ...[
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          if (consultation.hasChatRoom &&
                              consultation.isCallType) ...[
                            Expanded(
                              child: SizedBox(
                                height: 42.h,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _openCall(context, consultation),
                                  icon: Icon(
                                    Icons.phone_in_talk_rounded,
                                    size: 18.sp,
                                    color: const Color(0xFF27AE60),
                                  ),
                                  label: Text(
                                    AppStrings.makeVoiceCall.tr(context),
                                    style: TextStyle(
                                      color: const Color(0xFF27AE60),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF27AE60),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                          ],
                          Expanded(
                            child: SizedBox(
                              height: 42.h,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _openChat(context, consultation),
                                icon: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18.sp,
                                  color: AppColors.golden,
                                ),
                                label: Text(
                                  AppStrings.enterChat.tr(context),
                                  style: TextStyle(
                                    color: AppColors.golden,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.golden,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, LawyerConsultationModel consultation) {
    openLawyerConsultationChat(context, consultation);
  }

  void _openCall(
    BuildContext context,
    LawyerConsultationModel consultation, {
    bool isVideo = false,
  }) {
    openLawyerConsultationCall(context, consultation, isVideo: isVideo);
  }
}

void openLawyerConsultationChat(
  BuildContext context,
  LawyerConsultationModel consultation,
) {
  if (consultation.chatInfo == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                sl<LawyerChatMessagesCubit>(param1: consultation.chatInfo!.id)
                  ..loadMessages(),
          ),
          BlocProvider(create: (_) => sl<LawyerCallCubit>()),
        ],
        child: LawyerChatScreen(
          chatRoomId: consultation.chatInfo!.id,
          clientName: consultation.client.name,
          caseTitle: consultation.title,
          isCall: consultation.isCallType,
          isVideo: consultation.isVideoCall,
        ),
      ),
    ),
  );
}

void openLawyerConsultationCall(
  BuildContext context,
  LawyerConsultationModel consultation, {
  bool isVideo = false,
}) {
  if (consultation.chatInfo == null) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<LawyerCallCubit>(),
        child: LawyerAgoraCallScreen(
          roomId: consultation.chatInfo!.id,
          clientName: consultation.client.name,
          isVideo: isVideo,
        ),
      ),
    ),
  );
}

class _ConsultationFilterItem {
  final String type;
  final String label;

  const _ConsultationFilterItem(this.type, this.label);
}

class _ConsultationCard extends StatelessWidget {
  final LawyerConsultationModel consultation;

  const _ConsultationCard({required this.consultation});

  Color _serviceColor() {
    if (consultation.isCallType) {
      return const Color(0xFF27AE60); // Green
    }
    return AppColors.golden; // Golden/Brown
  }

  IconData _getServiceIcon() {
    if (consultation.isCallType) return Icons.phone_in_talk_rounded;
    return Icons.article_outlined;
  }

  String _serviceLabel(BuildContext context) {
    if (consultation.isCallType) return AppStrings.voiceCall.tr(context);
    if (consultation.isWritten) {
      return AppStrings.writtenConsultation.tr(context);
    }
    if (consultation.isVideoCall) return 'مكالمة فيديو';
    if (consultation.isVoiceCall) return 'مكالمة صوتية';
    if (consultation.isWritten) return 'استشارة مكتوبة';
    return consultation.typeText.isNotEmpty
        ? consultation.typeText
        : consultation.type;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: HoggaCard(
        color: context.cardBg,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        borderRadius: 16.r,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.lawyerConsultationDetails,
            arguments: consultation.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: _serviceColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getServiceIcon(),
                    size: 20.sp,
                    color: _serviceColor(),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.title.isNotEmpty
                            ? consultation.title
                            : _serviceLabel(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12.sp,
                            color: context.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              consultation.client.name.isNotEmpty
                                  ? consultation.client.name
                                  : AppStrings.client.tr(context),
                              style: context.text.labelSmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: context.divColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        consultation.consultationNumber.isNotEmpty
                            ? consultation.consultationNumber
                            : '#${consultation.id}',
                        style: context.text.labelSmall?.copyWith(
                          color: AppColors.golden,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                      ),
                      Text(
                        AppStrings.referenceNumber.tr(context),
                        style: context.text.labelSmall?.copyWith(
                          color: context.textSecondary,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _buildBadge(
                  context: context,
                  icon: _getServiceIcon(),
                  label: _serviceLabel(context),
                  color: _serviceColor(),
                ),
                _buildBadge(
                  context: context,
                  icon: Icons.check_circle_outline,
                  label: AppStrings.paidStatus.tr(context),
                  color: const Color(0xFF27AE60),
                ),
                if (consultation.hasChatRoom && !consultation.isCallType) ...[
                  _buildBadge(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    label: AppStrings.chat.tr(context),
                    color: AppColors.golden,
                  ),
                ],
              ],
            ),

            if (consultation.isCallType &&
                consultation.callDuration != null) ...[
              SizedBox(height: 8.h),
              _CallDurationBanner(
                callDuration: consultation.callDuration,
                isCallType: consultation.isCallType,
                color: _serviceColor(),
              ),
            ],

            SizedBox(height: 10.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 13.sp,
                            color: AppColors.golden,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              consultation.scheduledAt != null &&
                                      consultation.scheduledAt!.isNotEmpty
                                  ? consultation.scheduledAt!
                                  : consultation.createdAt,
                              style: context.text.bodySmall?.copyWith(
                                color: context.textSecondary,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (consultation.price.isNotEmpty) ...[
                            Text(
                              consultation.price,
                              style: context.text.titleLarge?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              AppStrings.currencySymbol.tr(context),
                              style: context.text.bodySmall?.copyWith(
                                color: AppColors.golden,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ] else if (consultation.priceType.isNotEmpty) ...[
                            Text(
                              consultation.priceType,
                              style: context.text.titleMedium?.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                LawyerStatusBadge(text: consultation.statusText),
              ],
            ),

            if (consultation.hasChatRoom &&
                consultation.status.toLowerCase() != 'canceled' &&
                consultation.status.toLowerCase() != 'cancelled' &&
                consultation.status.toLowerCase() != 'completed' &&
                !consultation.isCompletedByProvider)
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (consultation.isCallType) {
                        openLawyerConsultationCall(context, consultation);
                      } else {
                        openLawyerConsultationChat(context, consultation);
                      }
                    },
                    icon: Icon(
                      consultation.isCallType
                          ? Icons.phone_in_talk_rounded
                          : Icons.chat_bubble_outline_rounded,
                      size: 18.sp,
                      color: _serviceColor(),
                    ),
                    label: Text(
                      consultation.isCallType
                          ? AppStrings.makeVoiceCall.tr(context)
                          : AppStrings.enterChat.tr(context),
                      /*
                      consultation.isCallType
                          ? (consultation.isVideoCall
                              ? 'إجراء مكالمة مرئية'
                              : AppStrings.makeVoiceCall.tr(context))
                          : AppStrings.enterChat.tr(context),
                      */
                      style: context.text.labelLarge?.copyWith(
                        color: _serviceColor(),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _serviceColor(), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsultationHeader extends StatelessWidget {
  final LawyerConsultationModel consultation;

  const _ConsultationHeader({required this.consultation});

  IconData _getTypeIcon() {
    if (consultation.isCallType) return Icons.phone_in_talk_rounded;
    if (consultation.isVideoCall) return Icons.videocam_rounded;
    if (consultation.isVoiceCall) return Icons.phone_in_talk_rounded;
    return Icons.article_outlined;
  }

  String _getTypeLabel(BuildContext context) {
    if (consultation.isCallType) return AppStrings.voiceCall.tr(context);
    if (consultation.isWritten) {
      return AppStrings.writtenConsultation.tr(context);
    }
    if (consultation.isVideoCall) return 'مكالمة فيديو';
    if (consultation.isVoiceCall) return 'مكالمة صوتية';
    if (consultation.isWritten) return 'استشارة مكتوبة';
    return consultation.typeText.isNotEmpty
        ? consultation.typeText
        : consultation.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  consultation.consultationNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: AppColors.golden,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              LawyerStatusBadge(text: consultation.statusText),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            consultation.title,
            style: context.text.titleMedium?.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _DarkChip(icon: _getTypeIcon(), label: _getTypeLabel(context)),
              if (consultation.price.isNotEmpty)
                _DarkChip(
                  icon: Icons.payments_outlined,
                  label:
                      '${consultation.price} ${AppStrings.currencyRial.tr(context)}',
                )
              else if (consultation.priceType.isNotEmpty)
                _DarkChip(
                  icon: Icons.payments_outlined,
                  label: consultation.priceType,
                ),
              _DarkChip(
                icon: Icons.calendar_today_outlined,
                label: consultation.scheduledAt ?? consultation.createdAt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ConsultationClientModel client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return LawyerCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _ClientAvatar(client: client, size: 46.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.client.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  client.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
                if (client.phone?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Text(
                    client.phone!,
                    style: context.text.labelSmall?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallDurationBanner extends StatelessWidget {
  final CallDurationModel? callDuration;
  final bool isCallType;
  final Color color;

  const _CallDurationBanner({
    required this.callDuration,
    required this.isCallType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final duration = callDuration;
    if (!isCallType || duration == null) {
      return const SizedBox.shrink();
    }

    final total = duration.totalMinutes;
    final remaining = duration.remainingMinutes;
    final used = duration.usedMinutes;
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 12.sp, color: color),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  AppStrings.callMinutes.tr(context),
                  style: context.text.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.5.sp,
                  ),
                ),
              ),
              Text(
                '$remaining / $total ${AppStrings.minutesLabel.tr(context)}',
                style: context.text.labelSmall?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: 1.0 - progress,
              minHeight: 3.5.h,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LawyerCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.accentGolden, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.labelSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: context.text.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  final ConsultationClientModel client;
  final double size;

  const _ClientAvatar({required this.client, required this.size});

  @override
  Widget build(BuildContext context) {
    final photo = client.photo;
    if (photo != null && photo.isNotEmpty) {
      return CustomNetworkImage(
        imageUrl: photo,
        width: size,
        height: size,
        borderRadius: size / 2,
        errorWidget: CircleAvatar(
          radius: size / 2,
          backgroundColor: context.chipBg,
          child: Icon(
            Icons.person_rounded,
            color: context.textSecondary,
            size: size * 0.5,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: context.chipBg,
      child: Icon(
        Icons.person_rounded,
        color: context.textSecondary,
        size: size * 0.5,
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DarkChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.golden),
          SizedBox(width: 4.w),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: AppColors.cream,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
