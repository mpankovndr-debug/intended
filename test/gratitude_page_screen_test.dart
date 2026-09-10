import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/gratitude_entry.dart';
import 'package:intended/screens/gratitude_page_screen.dart';
import 'package:intended/theme/theme_provider.dart';

/// The archive door is a bare icon, so without a label VoiceOver reaches a
/// silent button. Its name is copy, and copy is what tests can hold on to.
Widget _host() {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GratitudePageScreen(),
    ),
  );
}

Future<void> _seed(List<GratitudeEntry> entries) async {
  SharedPreferences.setMockInitialValues({
    'gratitude_entries': jsonEncode([for (final e in entries) e.toJson()]),
  });
}

void main() {
  testWidgets('with a page behind you, the archive door is announced',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _seed([
      GratitudeEntry.create(
        forSelf: const ['soup'],
        forOthers: const [],
        at: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
    await tester.pumpWidget(_host());
    await tester.pump(); // _load resolves
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Past pages')),
      isSemantics(label: 'Past pages', isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('with nothing behind you, there is no door to announce',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _seed(const []);
    await tester.pumpWidget(_host());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The page did load — so the missing label is the door's absence, not
    // a screen that never rendered.
    expect(find.text('What are you thankful for?'), findsOneWidget);
    expect(find.bySemanticsLabel('Past pages'), findsNothing);
    semantics.dispose();
  });
}
