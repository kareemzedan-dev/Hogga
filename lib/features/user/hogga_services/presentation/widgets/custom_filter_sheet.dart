import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/utils/app_sizes.dart';

class FilterOption<T> {
  final String label;
  final T value;
  FilterOption({required this.label, required this.value});
}

class CustomFilterSheet<T> extends StatefulWidget {
  final String title;
  final List<FilterOption<T>> options;
  final T? initialValue;
  final Function(T?) onConfirm;
  final bool showSearch;
  final String? searchHint;

  const CustomFilterSheet({
    super.key,
    required this.title,
    required this.options,
    this.initialValue,
    required this.onConfirm,
    this.showSearch = false,
    this.searchHint,
  });

  @override
  State<CustomFilterSheet<T>> createState() => _CustomFilterSheetState<T>();
}

class _CustomFilterSheetState<T> extends State<CustomFilterSheet<T>> {
  T? _selectedValue;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  List<FilterOption<T>> get _filteredOptions {
    if (!widget.showSearch || _query.isEmpty) return widget.options;
    return widget.options.where((o) => o.label.contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: context.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.divColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: context.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                widget.title,
                style: context.text.titleLarge?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          AppSizes.h(12),
          
          if (widget.showSearch) ...[
            TextField(

              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? AppStrings.searchHint.tr(context),
                hintStyle: TextStyle(color: context.textSecondary),
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                filled: true,
                fillColor: context.mc.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            AppSizes.h(16),
          ],

          // Options list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredOptions.length,
              itemBuilder: (context, index) {
                final option = _filteredOptions[index];
                final isSelected = _selectedValue == option.value;
                return InkWell(
                  onTap: () => setState(() => _selectedValue = option.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            color: isSelected ? AppColors.golden : context.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        // Custom Radio
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.golden : context.textSecondary,
                              width: isSelected ? 6 : 1.5,
                            ),
                            color: isSelected ? context.textPrimary : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          AppSizes.h(16),
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfirm(_selectedValue);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
              child: Text(
                AppStrings.confirm.tr(context),
                style: TextStyle(
                  color: context.isDark ? AppColors.primary : AppColors.cream,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  fontFamily: 'Rubik',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

