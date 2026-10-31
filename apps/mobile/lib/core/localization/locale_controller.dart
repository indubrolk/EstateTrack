import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(
  const Locale('en'),
);

void changeLanguage(String languageCode) {
  final locale = Locale(languageCode);
  if (AppLocalizations.supportedLocales.contains(locale)) {
    appLocale.value = locale;
  }
}
