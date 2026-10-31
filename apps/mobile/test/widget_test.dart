import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/localization/locale_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/main.dart';

void main() {
  setUp(() => appLocale.value = const Locale('en'));
  tearDown(() => appLocale.value = const Locale('en'));

  Future<void> openApp(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: EstateTrackApp()));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  bool isSelected(WidgetTester tester, String key) {
    final semantics = find.ancestor(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(Semantics),
    );
    return tester
        .widgetList<Semantics>(semantics)
        .any((widget) => widget.properties.selected == true);
  }

  testWidgets('switches all languages without losing login details', (
    tester,
  ) async {
    await openApp(tester);
    await tester.enterText(find.byKey(const ValueKey('username')), 'SUP-1234');
    await tester.enterText(find.byKey(const ValueKey('pin')), '5678');
    await tapVisible(tester, find.byKey(const ValueKey('division-valley')));
    await tapVisible(tester, find.byTooltip('Show PIN'));

    for (final code in ['si', 'ta', 'en']) {
      await tapVisible(tester, find.byKey(ValueKey('language-$code')));
      final strings = await AppLocalizations.delegate.load(Locale(code));
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        Locale(code),
      );
      expect(find.text(strings.appSubtitle), findsOneWidget);
      expect(find.text(strings.username), findsOneWidget);
      expect(find.text(strings.login), findsOneWidget);
      expect(find.text(strings.valleyDivision), findsOneWidget);
      expect(isSelected(tester, 'language-$code'), isTrue);
      expect(isSelected(tester, 'division-valley'), isTrue);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('username')))
            .controller!
            .text,
        'SUP-1234',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('pin')))
            .controller!
            .text,
        '5678',
      );
      expect(find.byTooltip(strings.hidePin), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('existing validation errors follow language changes', (
    tester,
  ) async {
    await openApp(tester);
    await tester.enterText(find.byKey(const ValueKey('username')), '');
    await tester.enterText(find.byKey(const ValueKey('pin')), '12');
    await tapVisible(tester, find.byType(ElevatedButton));

    for (final code in ['en', 'si', 'ta']) {
      await tapVisible(tester, find.byKey(ValueKey('language-$code')));
      final strings = await AppLocalizations.delegate.load(Locale(code));
      expect(find.text(strings.usernameRequired), findsOneWidget);
      expect(find.text(strings.pinInvalid), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  for (final code in ['en', 'si', 'ta']) {
    testWidgets('$code fits a narrow screen and localizes actions', (
      tester,
    ) async {
      changeLanguage(code);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(tester, width: 320);
      final strings = await AppLocalizations.delegate.load(Locale(code));
      await tapVisible(tester, find.text(strings.resetPin));
      expect(find.text(strings.pinResetUnavailable), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.enterText(find.byKey(const ValueKey('pin')), '1234');
      await tapVisible(tester, find.byType(ElevatedButton));
      expect(find.text(strings.loginDemo), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('unsupported language does not replace the current locale', () {
    changeLanguage('si');
    changeLanguage('unsupported');
    expect(appLocale.value, const Locale('si'));
  });
}
