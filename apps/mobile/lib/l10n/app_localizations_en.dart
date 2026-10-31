// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EstateTrack';

  @override
  String get appSubtitle => 'Smart Plantation Management System';

  @override
  String get localStorage => 'LOCAL STORAGE ACTIVE';

  @override
  String get regionName => 'Nuwara Eliya Regional Plantations';

  @override
  String get fieldMode => 'Field Mode Enabled';

  @override
  String get offlineMessage =>
      'Offline-ready: Sign in with your saved supervisor PIN without internet connectivity.';

  @override
  String get username => 'Username or Field Supervisor ID';

  @override
  String get pin => 'Password / PIN';

  @override
  String get pinHint => 'Enter 4-6 digit PIN';

  @override
  String get secureVault => 'Stored in secure offline vault';

  @override
  String get resetPin => 'Quick PIN Reset';

  @override
  String get assignedDivision => 'Assigned Muster Division';

  @override
  String get upperDivision => 'Upper Div #04';

  @override
  String get valleyDivision => 'Valley West #02';

  @override
  String get login => 'LOGIN TO ESTATETRACK';

  @override
  String get bluetoothScales => 'Bluetooth Scales';

  @override
  String get connectionNotChecked => 'Connection not checked';

  @override
  String get helpline => 'Estate Office Helpline';

  @override
  String get developmentPreview => 'EstateTrack • Development Preview';

  @override
  String get usernameRequired => 'Enter your supervisor ID';

  @override
  String get pinInvalid => 'Enter a valid 4-6 digit PIN';

  @override
  String get loginDemo => 'Login UI ready. Connect authentication next.';

  @override
  String get pinResetUnavailable => 'PIN reset is not connected yet.';
}
