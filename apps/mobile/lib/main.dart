import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Localization
import 'core/localization/locale_controller.dart';
import 'l10n/app_localizations.dart';

// Screens
import 'features/auth/presentation/login_screen.dart';

// import 'features/attendance/presentation/attendance_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: EstateTrackApp()));
}

class EstateTrackApp extends StatelessWidget {
  const EstateTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, selectedLocale, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          debugShowCheckedModeBanner: false,

          // Current selected language
          locale: selectedLocale,

          // Supported languages
          supportedLocales: AppLocalizations.supportedLocales,

          // Localization delegates
          localizationsDelegates: AppLocalizations.localizationsDelegates,

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
