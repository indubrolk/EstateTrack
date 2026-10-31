// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'EstateTrack';

  @override
  String get appSubtitle => 'நவீன தோட்ட முகாமைத்துவ அமைப்பு';

  @override
  String get localStorage => 'உள்ளூர் தரவுச் சேமிப்பு செயலில் உள்ளது';

  @override
  String get regionName => 'நுவரெலியா பிராந்தியத் தோட்டங்கள்';

  @override
  String get fieldMode => 'களப் பயன்முறை செயல்பாட்டில் உள்ளது';

  @override
  String get offlineMessage =>
      'இணைய இணைப்பு இல்லாமலும் சேமிக்கப்பட்ட மேற்பார்வையாளர் PIN மூலம் உள்நுழையலாம்.';

  @override
  String get username => 'பயனர்பெயர் அல்லது கள மேற்பார்வையாளர் அடையாள எண்';

  @override
  String get pin => 'கடவுச்சொல் / PIN';

  @override
  String get pinHint => '4-6 இலக்க PIN எண்ணை உள்ளிடவும்';

  @override
  String get secureVault => 'பாதுகாப்பான உள்ளூர் சேமிப்பில் வைக்கப்பட்டுள்ளது';

  @override
  String get resetPin => 'PIN எண்ணை மீட்டமைக்கவும்';

  @override
  String get assignedDivision => 'ஒதுக்கப்பட்ட பணிப் பிரிவு';

  @override
  String get upperDivision => 'மேல் பிரிவு #04';

  @override
  String get valleyDivision => 'பள்ளத்தாக்கு மேற்கு #02';

  @override
  String get login => 'ESTATETRACK-இல் உள்நுழையவும்';

  @override
  String get bluetoothScales => 'புளூடூத் தராசுகள்';

  @override
  String get connectionNotChecked => 'இணைப்பு சரிபார்க்கப்படவில்லை';

  @override
  String get helpline => 'தோட்ட அலுவலக உதவி எண்';

  @override
  String get developmentPreview => 'EstateTrack • மேம்பாட்டு முன்னோட்டம்';

  @override
  String get usernameRequired => 'மேற்பார்வையாளர் அடையாள எண்ணை உள்ளிடவும்';

  @override
  String get pinInvalid => 'சரியான 4-6 இலக்க PIN எண்ணை உள்ளிடவும்';

  @override
  String get loginDemo => 'உள்நுழைவு திரை தயார். அங்கீகாரத்தை இணைக்க வேண்டும்.';

  @override
  String get pinResetUnavailable => 'PIN மீட்டமைப்பு இன்னும் இணைக்கப்படவில்லை.';
}
