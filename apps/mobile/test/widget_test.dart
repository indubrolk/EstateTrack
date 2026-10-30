import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('EstateTrack app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EstateTrackApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
