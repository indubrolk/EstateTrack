
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Localization
import 'core/localization/locale_controller.dart';
import 'l10n/app_localizations.dart';

// Screens
import 'features/auth/presentation/login_screen.dart';

// import 'features/attendance/presentation/attendance_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: EstateTrackApp(),
    ),
  );
}

class EstateTrackApp extends StatelessWidget {
  const EstateTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, selectedLocale, child) {
        return MaterialApp(
          title: 'EstateTrack',
          debugShowCheckedModeBanner: false,

          // Current selected language
          locale: selectedLocale,

          // Supported languages
          supportedLocales: const [
            Locale('en'), // English
            Locale('si'), // Sinhala
            Locale('ta'), // Tamil
          ],

          // Localization delegates
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Theme
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF12633B),
            ),
            useMaterial3: true,
          ),

          // First screen
          home: const LoginScreen(),
        );
      },
    );
  }
}
