import 'package:flutter/material.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_strings.dart';
import '../../../../../../core/widgets/custom_text_field.dart';

class SubmitOfferSheet extends StatefulWidget {
  const SubmitOfferSheet({super.key});

  @override
  State<SubmitOfferSheet> createState() => _SubmitOfferSheetState();
}

class _SubmitOfferSheetState extends State<SubmitOfferSheet> {
  bool _expiresAtSpecificTime = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 20),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          CustomTextField(
            hintText: AppStrings.implementationDurationInDays.tr(context),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.start,
            prefixIcon: const Icon(Icons.access_time, size: 20),
          ),
          const SizedBox(height: 16),
          _buildToggleRow(context),
          if (_expiresAtSpecificTime) ...[
            const SizedBox(height: 16),
            CustomTextField(
              hintText: AppStrings.offerExpiryDate.tr(context),
              readOnly: true,
              textAlign: TextAlign.start,
              prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
              onTap: () {
                // Show date picker
              },
            ),
          ],
          const SizedBox(height: 16),
          CustomTextField(
            hintText: AppStrings.offerValue.tr(context),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.start,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: AppStrings.offerDetails.tr(context),
            maxLines: 4,
            textAlign: TextAlign.start,
            prefixIcon: const Icon(Icons.description_outlined, size: 20),
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: context.textPrimary,
        ),
        Text(
          AppStrings.submitOffer.tr(context),
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildToggleRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.divColor),
      ),
      child: Row(
        children: [
          Switch(
            value: _expiresAtSpecificTime,
            onChanged: (val) => setState(() => _expiresAtSpecificTime = val),
            activeTrackColor: AppColors.golden,
            activeColor: context.isDark ? AppColors.cream : Colors.white,
          ),
          const Spacer(),
          Expanded(
            child: Text(
              AppStrings.offerExpiresAt.tr(context),
              textAlign: TextAlign.start,
              style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.event_available_rounded, color: context.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Send offer logic
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.offerSentSuccess.tr(context))),
          );
        },
        child: Text(AppStrings.sendOfferNow.tr(context)),
      ),
    );
  }
}
