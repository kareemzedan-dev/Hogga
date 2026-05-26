import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/utils/app_sizes.dart';
import '../../domain/models/lawyer_model.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import './custom_filter_sheet.dart';

class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({super.key});

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  String _query = '';
  String? _selectedCity;

  List<String> get _filtered => omanCities
      .where((c) => c.contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    return CustomFilterSheet<String>(
      title: AppStrings.chooseCity.tr(context),
      showSearch: true,
      searchHint: AppStrings.searchCity.tr(context),
      initialValue: _selectedCity,
      options: [
        FilterOption(label: AppStrings.all.tr(context), value: ''),
        ...omanCities.map((c) => FilterOption(label: c.tr(context), value: c)),
      ],
      onConfirm: (val) {
        if (val != null) {
          Navigator.pop(context, val);
        }
      },
    );
  }
}
