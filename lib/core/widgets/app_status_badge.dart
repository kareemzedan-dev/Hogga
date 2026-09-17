import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;
  final String? statusText;

  const AppStatusBadge({super.key, required this.status, this.statusText});

  @override
  Widget build(BuildContext context) {
    final String text = (statusText != null && statusText!.trim().isNotEmpty)
        ? statusText!.trim()
        : _translateStatus(context, status);
    final Color color = _getStatusColor(status);
    final Color bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  String _translateStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'active':
        return AppStrings.confirmedStatus.tr(context);
      case 'confirmed':
        return AppStrings.confirmedStatus.tr(context);
      case 'pending':
        return AppStrings.pendingStatus.tr(context);
      case 'paid':
      case 'مدفوع':
      case 'تم الدفع':
        return AppStrings.paidStatus.tr(context);
      case 'cancelled':
      case 'canceled':
        return AppStrings.cancelledStatus.tr(context);
      case 'finished':
      case 'completed':
      case 'complete':
        return AppStrings.completed.tr(context);
      case 'delivered':
        return AppStrings.deliveredStatus.tr(context);
      case 'shipped':
        return AppStrings.shippedStatus.tr(context);
      default:
        return AppStrings.unknownStatus.tr(context);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'active':
        return const Color(0xFF2E7D32);
      case 'confirmed':
        return const Color(0xFF2E7D32); // Green
      case 'pending':
        return const Color(0xFFBF8C1E); // Mustard
      case 'paid':
      case 'مدفوع':
      case 'تم الدفع':
        return const Color(0xFF2E7D32);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFEB5757); // Red
      case 'finished':
      case 'completed':
      case 'complete':
        return const Color(0xFF2D9CDB);
      case 'delivered':
        return const Color(0xFF2D9CDB); // Blue
      case 'shipped':
        return const Color(0xFF8B1818); // Primary
      default:
        return Colors.grey;
    }
  }
}
