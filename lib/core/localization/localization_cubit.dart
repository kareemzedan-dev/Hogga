import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/shared_preference/shared_preference.dart';

class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(Locale(AppPreferences().locale));

  void changeLanguage(String languageCode) async {
    await AppPreferences().saveLocale(languageCode);
    emit(Locale(languageCode));
  }
}
