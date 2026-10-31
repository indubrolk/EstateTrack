// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'EstateTrack';

  @override
  String get appSubtitle => 'ස්මාර්ට් වැවිලි කළමනාකරණ පද්ධතිය';

  @override
  String get localStorage => 'දේශීය දත්ත ගබඩාව සක්‍රීයයි';

  @override
  String get regionName => 'නුවරඑළිය ප්‍රාදේශීය වැවිලි';

  @override
  String get fieldMode => 'ක්ෂේත්‍ර මාදිලිය සක්‍රීයයි';

  @override
  String get offlineMessage =>
      'අන්තර්ජාල සම්බන්ධතාවක් නොමැතිව ඔබගේ සුරැකි අධීක්ෂක PIN අංකය භාවිතයෙන් පිවිසිය හැක.';

  @override
  String get username => 'පරිශීලක නාමය හෝ ක්ෂේත්‍ර අධීක්ෂක හැඳුනුම් අංකය';

  @override
  String get pin => 'මුරපදය / PIN';

  @override
  String get showPin => 'PIN අංකය පෙන්වන්න';

  @override
  String get hidePin => 'PIN අංකය සඟවන්න';

  @override
  String get pinHint => 'ඉලක්කම් 4-6ක PIN අංකය ඇතුළත් කරන්න';

  @override
  String get secureVault => 'ආරක්ෂිත දේශීය ගබඩාවේ සුරකින ලදී';

  @override
  String get resetPin => 'PIN අංකය යළි සකසන්න';

  @override
  String get assignedDivision => 'පවරා ඇති සේවක අංශය';

  @override
  String get upperDivision => 'ඉහළ අංශය #04';

  @override
  String get valleyDivision => 'නිම්නය බටහිර #02';

  @override
  String get login => 'ESTATETRACK වෙත පිවිසෙන්න';

  @override
  String get bluetoothScales => 'බ්ලූටූත් තරාදි';

  @override
  String get connectionNotChecked => 'සම්බන්ධතාව පරීක්ෂා කර නැත';

  @override
  String get helpline => 'වතු කාර්යාල උපකාරක සේවාව';

  @override
  String get developmentPreview => 'EstateTrack • සංවර්ධන පෙරදසුන';

  @override
  String get usernameRequired => 'අධීක්ෂක හැඳුනුම් අංකය ඇතුළත් කරන්න';

  @override
  String get pinInvalid => 'වලංගු ඉලක්කම් 4-6ක PIN අංකයක් ඇතුළත් කරන්න';

  @override
  String get loginDemo =>
      'පිවිසුම් අතුරුමුහුණත සූදානම්. සත්‍යාපනය සම්බන්ධ කළ යුතුය.';

  @override
  String get pinResetUnavailable => 'PIN යළි සැකසීම තවම සම්බන්ධ කර නැත.';
}
