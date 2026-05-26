import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    // Safety check: ensure value exists in items
    final T? effectiveValue = items.any((item) => item.value == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
            child: Text(
              label! + (isRequired ? ' *' : ''),
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.colors.onSurface.withOpacity(0.85),
              ),
            ),
          ),
        ],
        DropdownButtonFormField<T>(
          value: effectiveValue,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: context.text.bodyMedium?.copyWith(
            fontSize: 15, // Increased from 14
            color: context.colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          elevation: 4,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colors.primary,
            size: 26,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.text.labelMedium?.copyWith(
              fontSize: 14,
              color: context.customColors.grey.withOpacity(0.55),
            ),
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: context.colors.primary, size: 22) 
                : null,
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.customColors.lightGrey.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.customColors.lightGrey.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.primary, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.error, width: 1.2),
            ),
          ),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: context.colors.surface,
          menuMaxHeight: 350,
        ),
      ],
    );
  }
}
