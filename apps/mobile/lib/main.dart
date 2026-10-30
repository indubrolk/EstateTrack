
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/attendance/presentation/attendance_screen.dart';

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
    return MaterialApp(
      title: 'EstateTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E42),
        ),
        useMaterial3: true,
      ),
      home: const AttendanceScreen(),
    );
  }
}
