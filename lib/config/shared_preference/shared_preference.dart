import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/app_secure_storage.dart';

class AppPreferences {
  AppPreferences._internal();

  static final AppPreferences _instance = AppPreferences._internal();

  factory AppPreferences() => _instance;

  static SharedPreferences? _prefs;
  static String? _cachedToken;
  static String? _cachedLocale;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedLocale = _prefs!.getString(_localeKey);
    _cachedLocale = _isSupportedLocale(savedLocale) ? savedLocale : null;

    // Migration logic & Token Caching
    final secureStorage = AppSecureStorage();
    _cachedToken = await secureStorage.getToken();

    // If no token in secure storage, check old shared prefs
    if (_cachedToken == null) {
      final oldToken = _prefs!.getString(_tokenKey);
      if (oldToken != null) {
        // Migrate to secure storage
        await secureStorage.saveToken(oldToken);
        _cachedToken = oldToken;
        // Remove from insecure storage
        await _prefs!.remove(_tokenKey);
      }
    }
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs!.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs!.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    // Clear secure token too
    final localeBeforeClear = locale;
    await AppSecureStorage().deleteToken();
    _cachedToken = null;
    final cleared = await _prefs!.clear();
    await saveLocale(localeBeforeClear);
    return cleared;
  }

  static const String _tokenKey = 'token';
  static const String _emailKey = 'email';
  static const String _nameKey = 'name';
  static const String _phoneKey = 'phone';
  static const String _roleKey = 'role';
  static const String _typeKey = 'type';
  static const String _accountTypeKey = 'account_type';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _defaultDashboardKey = 'default_dashboard';
  static const String _isProviderKey = 'is_provider';
  static const String _localeKey = 'locale_code';
  static const String _imageKey = 'user_image';

  Future<void> saveToken(String token) async {
    await AppSecureStorage().saveToken(token);
    _cachedToken = token;
  }

  String? get token => _cachedToken;

  Future<void> saveEmail(String email) async {
    await setString(_emailKey, email);
  }

  String? get email => getString(_emailKey);

  Future<void> saveName(String name) async {
    await setString(_nameKey, name);
  }

  String? get name => getString(_nameKey);

  Future<void> saveImage(String? imageUrl) async {
    if (imageUrl == null) return;
    await setString(_imageKey, imageUrl);
  }

  String? get image => getString(_imageKey);

  Future<void> savePhone(String phone) async {
    await setString(_phoneKey, phone);
  }

  String? get phone => getString(_phoneKey);

  Future<void> saveRole(String role) async {
    await setString(_roleKey, role);
  }

  String get role => getString(_roleKey) ?? 'user';

  Future<void> saveType(String type) async {
    await setString(_typeKey, type);
  }

  String? get type => getString(_typeKey);

  Future<void> saveAccountType(String accountType) async {
    await setString(_accountTypeKey, accountType);
  }

  String? get accountType => getString(_accountTypeKey);

  Future<void> saveDefaultDashboard(bool value) async {
    await setBool(_defaultDashboardKey, value);
  }

  bool get defaultDashboard => getBool(_defaultDashboardKey) ?? false;

  Future<void> setLoggedIn(bool value) async {
    await setBool(_isLoggedInKey, value);
  }

  bool get isLoggedIn => getBool(_isLoggedInKey) ?? false;

  Future<void> saveIsProvider(bool value) async {
    await setBool(_isProviderKey, value);
  }

  bool get isProvider =>
      (getBool(_isProviderKey) ?? false) ||
      role.toLowerCase() == 'provider' ||
      role.toLowerCase() == 'lawyer';

  bool get isLawyer => isProvider;

  Future<void> saveLocale(String localeCode) async {
    final normalizedLocale = localeCode.toLowerCase();
    if (!_isSupportedLocale(normalizedLocale)) {
      return;
    }
    _cachedLocale = normalizedLocale;
    await setString(_localeKey, normalizedLocale);
  }

  String get locale {
    if (_isSupportedLocale(_cachedLocale)) {
      return _cachedLocale!;
    }

    final savedLocale = getString(_localeKey);
    if (_isSupportedLocale(savedLocale)) {
      _cachedLocale = savedLocale;
      return savedLocale!;
    }

    final systemLocale = PlatformDispatcher.instance.locale.languageCode
        .toLowerCase();
    if (_isSupportedLocale(systemLocale)) {
      return systemLocale;
    }

    return 'ar';
  }

  static bool _isSupportedLocale(String? localeCode) {
    return localeCode == 'ar' || localeCode == 'en';
  }

  Future<void> logout() async {
    await clear();
  }

  // ─── Smart Drafts Management (Max 2 Drafts) ────────────────────
  static const String _activeDraftsKey = 'active_draft_keys';

  Future<void> saveDraft(String flowKey, String jsonData) async {
    await setString(flowKey, jsonData);

    // Update active drafts list
    List<String> activeKeys = _prefs!.getStringList(_activeDraftsKey) ?? [];
    if (!activeKeys.contains(flowKey)) {
      activeKeys.add(flowKey);
    }

    // Enforce max 2 drafts policy (FIFO)
    if (activeKeys.length > 2) {
      String oldestKey = activeKeys.removeAt(0); // Remove oldest
      await remove(oldestKey); // Delete its data
    }
    await _prefs!.setStringList(_activeDraftsKey, activeKeys);
  }

  String? getDraft(String flowKey) {
    return getString(flowKey);
  }

  Future<void> clearDraft(String flowKey) async {
    await remove(flowKey);
    List<String> activeKeys = _prefs!.getStringList(_activeDraftsKey) ?? [];
    if (activeKeys.contains(flowKey)) {
      activeKeys.remove(flowKey);
      await _prefs!.setStringList(_activeDraftsKey, activeKeys);
    }
  }

  // ─── Lawyer Specializations Persistence ────────────────────────
  static const String _lawyerSpecializationsKey = 'lawyer_specialization_ids';

  Future<void> saveLawyerSpecializationIds(List<int> ids) async {
    await _prefs?.setStringList(
      _lawyerSpecializationsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  Set<int> getLawyerSpecializationIds() {
    final list = _prefs?.getStringList(_lawyerSpecializationsKey);
    if (list == null) return {};
    return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }
}
