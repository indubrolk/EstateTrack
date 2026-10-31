import 'package:flutter/material.dart';

final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(
  const Locale('en'),
);

void changeLanguage(String languageCode) {
  appLocale.value = Locale(languageCode);
}
