import 'package:flutter_svg/flutter_svg.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class CustomConfirmationSheet extends StatelessWidget {
  final String? iconPath;
  final IconData? iconData;
  final String title;
  final String subtitle;
  final String? warningNote;
  final String actionText;
  final VoidCallback onAction;
  final Color? actionColor;
  final Color? iconColor;

  const CustomConfirmationSheet({
    super.key,
    this.iconPath,
    this.iconData,
    required this.title,
    required this.subtitle,
    this.warningNote,
    required this.actionText,
    required this.onAction,
    this.actionColor,
    this.iconColor,
  }) : assert(iconPath != null || iconData != null, 'Either iconPath or iconData must be provided');

  @override
  Widget build(BuildContext context) {
    final destructiveColor = actionColor ?? context.colors.error;
    final symbolColor = iconColor ?? destructiveColor;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top drag handle ──
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.divColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Hero Icon Badge ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: symbolColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: symbolColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: iconData != null
                      ? Icon(
                          iconData,
                          size: 34,
                          color: symbolColor,
                        )
                      : (iconPath != null
                          ? SvgPicture.asset(
                              iconPath!,
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                symbolColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              Icons.info_outline_rounded,
                              size: 34,
                              color: symbolColor,
                            )),
                ),
              ),

              const SizedBox(height: 18),

              // ── Title ──
              Text(
                title,
                style: context.text.titleLarge?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // ── Subtitle ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Optional Warning Box ──
              if (warningNote != null && warningNote!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: destructiveColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: destructiveColor.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: destructiveColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warningNote!,
                          style: context.text.labelSmall?.copyWith(
                            color: destructiveColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Action Buttons (Side-by-side Row) ──
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.divColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: context.chipBg,
                        ),
                        child: Text(
                          AppStrings.cancel.tr(context),
                          style: context.text.titleSmall?.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: destructiveColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
