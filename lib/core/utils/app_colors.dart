

import 'dart:ui';

import 'package:flutter/material.dart';

/// hogga Brand Identity Colors
/// Primary Dark Brown: #3D1F0D  — الخلفية الرئيسية الداكنة
/// Golden Brown:       #8B5A2B  — اللون الذهبي للوجو والتمييز
/// Cream / Beige:      #F5E1A0  — الخلفية الفاتحة والنصوص
class AppColors {
  // ─── Brand Core ───────────────────────────────────────────────
  /// اللون الرئيسي — بني داكن (الشوكولاتة)
  static const Color primary = Color(0xFF422716); // البني المحروق الرسمي للهوية
  static const Color primaryLight = Color(0xFFFDE5A5); // للإبقاء على التوافق مع الكود الحالي
  
  /// Cream / Beige: #FDE5A5 — نسخة للهوية الرسمية
  static const Color cream = Color(0xFFFDE5A5);

  /// درجة فاتحة جداً من الكريم للهوية — تستخدم كخلفية
  static const Color creamLight = Color(0xFFFFF4D2); // درجة أفتح قليلاً من الكريم الرسمي للخلفيات

  /// نسخة شفافة من Primary للاستخدام كـ overlay أو background خفيف
  static const Color primaryOverlay = Color(0x1A422716);

  /// اللون الذهبي / البني الوسط — يُستخدم للأيقونات والتمييز
  static const Color golden = Color(0xFF8B5A2B);

  // ─── Status / Semantic ────────────────────────────────────────
  static const Color error   = Color(0xFFD32F2F);
  static const Color danger  = Color(0xFFEB5757);
  static const Color success = Color(0xFF8B5A2B); // golden — ضمن هوية العلامة
  static const Color warning = Color(0xFFF57C00);
  static const Color info    = Color(0xFFF5E1A0);

  // ─── Borders & Dividers ───────────────────────────────────────
  static const Color borderColor  = Color(0xFFE8D5B0);
  static const Color dividerColor = Color(0xFFD6C49A);

  // ─── Neutral ──────────────────────────────────────────────────
  static const Color white      = Colors.white;
  static const Color black      = Colors.black;
  static const Color grey       = Colors.grey;
  static const Color lightBlack = Color(0xFF3A3A3A);
  static const Color darkWhite  = Color(0xFFF9F5EC);

  static const Color lightGrey  = Color(0xFFE8D5B0);
  static const Color mediumGrey = Color(0xFFB0956B);
  static const Color darkGrey   = Color(0xFF5A4A35);


  static const Color splashBackgroundDark  = Color(0xFF422716); // Matched to brand primary
  static const Color splashBackgroundLight = Color(0xFFFDE5A5); // Matched to brand cream


  // ─── Theme Surfaces ───────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFDE5A5); // الكريمي الرسمي للهوية
  static const Color backgroundDark  = Color(0xFF261208); // الخلفية الداكنة العميقة
  static const Color surfaceLight    = Colors.white;
  static const Color surfaceDark     = Color(0xFF422716); // بني محروق الهوية الرسمي

  // ─── On-colors ────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF3D1F0D);
  static const Color textPrimaryDark    = Color(0xFFF0E0C0); // كريمي للدارك مود
  static const Color onSecondary        = Color(0xFF3D1F0D);
  static const Color onError            = Colors.white;
  static const Color onBackgroundLight  = Color(0xFF3D1F0D);
  static const Color onBackgroundDark   = Color(0xFFF0E0C0);
  static const Color onSurfaceLight     = Color(0xFF3D1F0D);
  static const Color onSurfaceDark      = Color(0xFFF0E0C0);

  // ─── Legacy / Missing ──────────────────────────────────────────
  static const Color barby = Color(0xFFFF4081);
  static const Color lightBarby = Color(0xFFF8BBD0);
  static const Color lightBrown = Color(0xFFD7CCC8);
  static const Color deepOrange = Color(0xFFFF5722);
  static const Color cardBackground = Colors.white;
  static const Color brown = Color(0xFF795548);
}


