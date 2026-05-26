import 'package:hogga/core/localization/app_localizations.dart';
import 'package:hogga/core/theme/app_theme.dart';
import 'package:hogga/core/utils/app_strings.dart';
import 'package:hogga/core/widgets/main_appbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';





class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: AppStrings.appName,
    packageName: '',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppbar(
        title: AppStrings.aboutApp.tr(context),
        backBtn: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              context.isDark ? AppAssets.hoggaDark : AppAssets.hoggaLight,
              width: 140.w,
            ),
            const SizedBox(height: 10),
            Text(
              _packageInfo.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.version} ${_packageInfo.version}',
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 40),
            _buildFeatureSection(context),
            const SizedBox(height: 40),
            Text(
              AppStrings.copyright,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.mainFeatures,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(AppStrings.searchNearby, Icons.location_on_outlined),
        _buildFeatureItem(AppStrings.realReviews, Icons.star_border),
        _buildFeatureItem(AppStrings.reliableSecure, Icons.shield_outlined),
        _buildFeatureItem(AppStrings.roundClockSupport, Icons.headset_mic_outlined),
      ],
    );
  }

  Widget _buildFeatureItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
