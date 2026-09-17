import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ThemeContext extension — helpers for clean theme access in widgets
// ─────────────────────────────────────────────────────────────────────────────
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  hoggaColors get mc => theme.extension<hoggaColors>()!;
  double get horizontalPadding => 16.0;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isAr => Localizations.localeOf(this).languageCode == 'ar';

  // ── Semantic surface shortcuts ───────────────────────────────────────────
  /// Main scaffold/page background
  Color get pageBg => theme.scaffoldBackgroundColor;

  /// Card / bottom-sheet / dialog background
  Color get cardBg => mc.cardBg;

  /// Primary text color
  Color get textPrimary => mc.textPrimary;

  /// Secondary / hint / label color
  Color get textSecondary => mc.textSecondary;

  /// Icon color
  Color get iconColor => mc.iconColor;

  /// Divider / border color
  Color get divColor => mc.dividerColor;

  /// Chip / tag background
  Color get chipBg => mc.chipBg;

  /// Accent golden color
  Color get accentGolden => AppColors.golden;

  /// Success color (Green)
  Color get success => mc.success;

  /// Warning color (Orange)
  Color get warning => mc.warning;

  // ── Legacy compat ────────────────────────────────────────────────────────
  AppColorsExtension get customColors => theme.extension<AppColorsExtension>()!;
}

// ─────────────────────────────────────────────────────────────────────────────
// hoggaColors — semantic ThemeExtension (NEW)
// ─────────────────────────────────────────────────────────────────────────────
class hoggaColors extends ThemeExtension<hoggaColors> {
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final Color dividerColor;
  final Color chipBg;
  final Color inputFill;
  final Color navBarBg;
  final Color headerBg;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color success;
  final Color warning;

  const hoggaColors({
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.dividerColor,
    required this.chipBg,
    required this.inputFill,
    required this.navBarBg,
    required this.headerBg,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.success,
    required this.warning,
  });

  // LIGHT values
  static const hoggaColors light = hoggaColors(
    cardBg: Color(
      0xFFF5EACF,
    ), // Stronger "Golden Sand" parchment for clear distinction
    textPrimary: AppColors.primary,
    textSecondary: AppColors.mediumGrey,
    iconColor: AppColors.primary,
    dividerColor: Color(0xFFB0956B), // Stronger Bronze/Gold border
    chipBg: Color(0xFFFDE5A5),
    inputFill: Color(0xFFF5EACF),
    navBarBg: AppColors.backgroundLight,
    headerBg: AppColors.backgroundLight,
    shimmerBase: Color(0xFFEADBCA),
    shimmerHighlight: Color(0xFFFDE5A5),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF57C00),
  );

  // DARK values — مزيج البني المحروق (المسيطر) والكريمي (الكاسر للحدة)
  static const hoggaColors dark = hoggaColors(
    cardBg: Color(
      0xFF2D180C,
    ), // Slightly lighter than background for separation
    textPrimary: AppColors.cream,
    textSecondary: Color(0xCCFDE5A5), // 80% opacity Cream
    iconColor: AppColors.cream,
    dividerColor: Color(0x1AFAF0D0), // 10% opacity Cream
    chipBg: Color(0xFF4A2A18),
    inputFill: Color(0xFF1E0E06), // Very dark for depth
    navBarBg: Color(0xFF1E0E06),
    headerBg: Color(0xFF1E0E06),
    shimmerBase: Color(0xFF3D1F0D), // بني محروق
    shimmerHighlight: Color(0xFF4A2A18), // درجة أفتح
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
  );

  @override
  hoggaColors copyWith({
    Color? cardBg,
    Color? textPrimary,
    Color? textSecondary,
    Color? iconColor,
    Color? dividerColor,
    Color? chipBg,
    Color? inputFill,
    Color? navBarBg,
    Color? headerBg,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? success,
    Color? warning,
  }) {
    return hoggaColors(
      cardBg: cardBg ?? this.cardBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      iconColor: iconColor ?? this.iconColor,
      dividerColor: dividerColor ?? this.dividerColor,
      chipBg: chipBg ?? this.chipBg,
      inputFill: inputFill ?? this.inputFill,
      navBarBg: navBarBg ?? this.navBarBg,
      headerBg: headerBg ?? this.headerBg,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  hoggaColors lerp(ThemeExtension<hoggaColors>? other, double t) {
    if (other is! hoggaColors) return this;
    return hoggaColors(
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Rubik',
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight, // #FAF0D0
    cardColor: Colors.white,
    dividerColor: AppColors.borderColor,
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(fontSize: 15),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Rubik',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFEADBCA), // كريمي بدرجة أغمق
      selectedItemColor: AppColors.primary, // بني داكن للمُختار
      unselectedItemColor: Color(0xFFA69477), // بني باهت لغير المُختار
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.golden,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.primary,
      outline: AppColors.borderColor,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        color: AppColors.darkGrey,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      displayLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 27.sp,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.cream,
        minimumSize: Size(double.infinity, 54.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Rubik',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: Size(double.infinity, 54.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Rubik',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(
        color: AppColors.grey,
        fontSize: 12.sp,
        fontFamily: 'Rubik',
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      errorStyle: TextStyle(
        color: AppColors.danger,
        fontSize: 11.sp,
        fontFamily: 'Rubik',
      ),
    ),
    extensions: [
      hoggaColors.light,
      AppColorsExtension(
        barby: AppColors.barby,
        lightBarby: AppColors.lightBarby,
        lightBrown: AppColors.lightBrown,
        deepOrange: AppColors.deepOrange,
        cardBackground: AppColors.cardBackground,
        brown: AppColors.brown,
        grey: AppColors.grey,
        lightGrey: AppColors.lightGrey,
        mediumGrey: AppColors.mediumGrey,
        darkGrey: AppColors.darkGrey,
      ),
    ],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Rubik',
    primaryColor: AppColors.cream,
    scaffoldBackgroundColor: const Color(0xFF261208), // داكن عميق
    cardColor: AppColors.surfaceDark, // #4A2A18
    dividerColor: const Color(0x26FAF0D0), // كريمي شفاف لكسر الحدة
    snackBarTheme: const SnackBarThemeData(
      contentTextStyle: TextStyle(fontSize: 15),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF261208),
      foregroundColor: AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.cream,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Rubik',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.cream),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF261208), // خلفية الناف بار
      selectedItemColor: Color(0xFFFAF0D0), // كريمي للمُختار
      unselectedItemColor: Color(0xFF8A6A45), // بني باهت לغير المُختار
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF3D1F0D),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0x26FAF0D0), width: 1),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cream, // نستخدم الكريمي ليظهر بوضوح في الدارك
      onPrimary: AppColors.primary, // البني المحروق
      secondary: AppColors.golden,
      onSecondary: AppColors.primary,
      surface: Color(0xFF3D1F0D), // البني المحروق مسيطر
      onSurface: AppColors.cream,
      outline: Color(0xFFFAF0D0), // كريمي لكسر الحدة
      error: AppColors.error,
      onError: AppColors.cream,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w400,
      ),
      labelSmall: TextStyle(
        color: const Color(0xFFC4AD88),
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      displayLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 27.sp,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.primary,
        minimumSize: Size(double.infinity, 54.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Rubik',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        side: const BorderSide(color: AppColors.cream),
        minimumSize: Size(double.infinity, 54.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Rubik',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF3D1F0D), // البني المحروق مسيطر للمدخلات
      hintStyle: TextStyle(
        color: const Color(0xFFC4AD88),
        fontSize: 12.sp,
        fontFamily: 'Rubik',
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(
          color: Color(0xFFD6C49A),
        ), // ذهبي/كريمي لكسر الحدة
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFD6C49A)), // ذهبي/كريمي
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.cream, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      errorStyle: TextStyle(
        color: AppColors.danger,
        fontSize: 11.sp,
        fontFamily: 'Rubik',
      ),
    ),
    extensions: [
      hoggaColors.dark,
      AppColorsExtension(
        barby: AppColors.cream,
        lightBarby: const Color(0xFF3D1F0D),
        lightBrown: const Color(0xFF3D1F0D),
        deepOrange: AppColors.golden,
        cardBackground: const Color(0xFF3D1F0D),
        brown: AppColors.golden,
        grey: const Color(0xFFD6C49A),
        lightGrey: const Color(0xFF5A3B2A),
        mediumGrey: const Color(0xFF8A6A45),
        darkGrey: const Color(0xFFFAF0D0),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AppColorsExtension — keeping for backwards compatibility
// ─────────────────────────────────────────────────────────────────────────────
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color barby;
  final Color lightBarby;
  final Color lightBrown;
  final Color deepOrange;
  final Color cardBackground;
  final Color brown;
  final Color grey;
  final Color lightGrey;
  final Color mediumGrey;
  final Color darkGrey;

  const AppColorsExtension({
    required this.barby,
    required this.lightBarby,
    required this.lightBrown,
    required this.deepOrange,
    required this.cardBackground,
    required this.brown,
    required this.grey,
    required this.lightGrey,
    required this.mediumGrey,
    required this.darkGrey,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? barby,
    Color? lightBarby,
    Color? lightBrown,
    Color? deepOrange,
    Color? cardBackground,
    Color? brown,
    Color? grey,
    Color? lightGrey,
    Color? mediumGrey,
    Color? darkGrey,
  }) {
    return AppColorsExtension(
      barby: barby ?? this.barby,
      lightBarby: lightBarby ?? this.lightBarby,
      lightBrown: lightBrown ?? this.lightBrown,
      deepOrange: deepOrange ?? this.deepOrange,
      cardBackground: cardBackground ?? this.cardBackground,
      brown: brown ?? this.brown,
      grey: grey ?? this.grey,
      lightGrey: lightGrey ?? this.lightGrey,
      mediumGrey: mediumGrey ?? this.mediumGrey,
      darkGrey: darkGrey ?? this.darkGrey,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      barby: Color.lerp(barby, other.barby, t)!,
      lightBarby: Color.lerp(lightBarby, other.lightBarby, t)!,
      lightBrown: Color.lerp(lightBrown, other.lightBrown, t)!,
      deepOrange: Color.lerp(deepOrange, other.deepOrange, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      brown: Color.lerp(brown, other.brown, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      mediumGrey: Color.lerp(mediumGrey, other.mediumGrey, t)!,
      darkGrey: Color.lerp(darkGrey, other.darkGrey, t)!,
    );
  }
}
