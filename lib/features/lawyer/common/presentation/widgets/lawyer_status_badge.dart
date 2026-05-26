import 'package:hogga/core/theme/app_theme.dart';

class LawyerStatusBadge extends StatelessWidget {
  final String text;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const LawyerStatusBadge({
    super.key,
    required this.text,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: context.text.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
