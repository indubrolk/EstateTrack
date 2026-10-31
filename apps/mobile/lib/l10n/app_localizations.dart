import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EstateTrack'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Plantation Management System'**
  String get appSubtitle;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'LOCAL STORAGE ACTIVE'**
  String get localStorage;

  /// No description provided for @regionName.
  ///
  /// In en, this message translates to:
  /// **'Nuwara Eliya Regional Plantations'**
  String get regionName;

  /// No description provided for @fieldMode.
  ///
  /// In en, this message translates to:
  /// **'Field Mode Enabled'**
  String get fieldMode;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline-ready: Sign in with your saved supervisor PIN without internet connectivity.'**
  String get offlineMessage;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username or Field Supervisor ID'**
  String get username;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Password / PIN'**
  String get pin;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-6 digit PIN'**
  String get pinHint;

  /// No description provided for @secureVault.
  ///
  /// In en, this message translates to:
  /// **'Stored in secure offline vault'**
  String get secureVault;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Quick PIN Reset'**
  String get resetPin;

  /// No description provided for @assignedDivision.
  ///
  /// In en, this message translates to:
  /// **'Assigned Muster Division'**
  String get assignedDivision;

  /// No description provided for @upperDivision.
  ///
  /// In en, this message translates to:
  /// **'Upper Div #04'**
  String get upperDivision;

  /// No description provided for @valleyDivision.
  ///
  /// In en, this message translates to:
  /// **'Valley West #02'**
  String get valleyDivision;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN TO ESTATETRACK'**
  String get login;

  /// No description provided for @bluetoothScales.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Scales'**
  String get bluetoothScales;

  /// No description provided for @connectionNotChecked.
  ///
  /// In en, this message translates to:
  /// **'Connection not checked'**
  String get connectionNotChecked;

  /// No description provided for @helpline.
  ///
  /// In en, this message translates to:
  /// **'Estate Office Helpline'**
  String get helpline;

  /// No description provided for @developmentPreview.
  ///
  /// In en, this message translates to:
  /// **'EstateTrack • Development Preview'**
  String get developmentPreview;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your supervisor ID'**
  String get usernameRequired;

  /// No description provided for @pinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 4-6 digit PIN'**
  String get pinInvalid;

  /// No description provided for @loginDemo.
  ///
  /// In en, this message translates to:
  /// **'Login UI ready. Connect authentication next.'**
  String get loginDemo;

  /// No description provided for @pinResetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'PIN reset is not connected yet.'**
  String get pinResetUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
