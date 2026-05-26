import 'package:flutter/material.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/localization/app_localizations.dart';

class CountryPickerBottomSheet extends StatelessWidget {
  final Function(String, String) onSelected;

  const CountryPickerBottomSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final countries = [
      {'name': AppStrings.saudiArabia, 'code': '+966', 'flag': '🇸🇦'},
      {'name': AppStrings.uae, 'code': '+971', 'flag': '🇦🇪'},
      {'name': AppStrings.oman, 'code': '+968', 'flag': '🇴🇲'},
      {'name': AppStrings.kuwait, 'code': '+965', 'flag': '🇰🇼'},
      {'name': AppStrings.qatar, 'code': '+974', 'flag': '🇶🇦'},
      {'name': AppStrings.bahrain, 'code': '+973', 'flag': '🇧🇭'},
      {'name': AppStrings.egypt, 'code': '+20', 'flag': '🇪🇬'},
      {'name': AppStrings.jordan, 'code': '+962', 'flag': '🇯🇴'},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.close, color: context.colors.onSurface),
                Text(
                  AppStrings.chooseCountry.tr(context),
                  style: context.text.headlineSmall?.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: countries.length,
              separatorBuilder: (context, index) => Divider(color: context.colors.outline.withOpacity(0.1)),
              itemBuilder: (context, index) {
                final country = countries[index];
                final translatedName = country['name']!.tr(context);
                return ListTile(
                  onTap: () {
                    onSelected(country['code']!, 'flag'); // flag path ignored for now
                    Navigator.pop(context);
                  },
                  trailing: Text(
                    country['flag']!,
                    style: context.text.headlineSmall,
                  ),
                  title: Text(
                    '$translatedName (${country['code']})',
                    style: context.text.bodyLarge?.copyWith(color: context.colors.onSurface),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
