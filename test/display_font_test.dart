import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/utils/text_styles.dart';

/// Reads the `cmap` of a TrueType file and returns the set of code points it
/// can actually draw. Hand-rolled because the alternative is trusting a font
/// to cover an alphabet, which is exactly the assumption that shipped the
/// whole Russian share card in the iOS system face.
Set<int> _codePoints(String path) {
  final b = File(path).readAsBytesSync().buffer.asByteData();
  final numTables = b.getUint16(4);
  var cmapOffset = -1;
  for (var i = 0; i < numTables; i++) {
    final rec = 12 + i * 16;
    final tag = String.fromCharCodes(
      [for (var j = 0; j < 4; j++) b.getUint8(rec + j)],
    );
    if (tag == 'cmap') cmapOffset = b.getUint32(rec + 8);
  }
  if (cmapOffset < 0) return {};

  final points = <int>{};
  final numSub = b.getUint16(cmapOffset + 2);
  for (var i = 0; i < numSub; i++) {
    final sub = cmapOffset + b.getUint32(cmapOffset + 4 + i * 8 + 4);
    if (b.getUint16(sub) != 4) continue; // format 4 covers the BMP
    final segX2 = b.getUint16(sub + 6);
    final ends = sub + 14;
    final starts = ends + segX2 + 2;
    for (var s = 0; s < segX2 ~/ 2; s++) {
      final end = b.getUint16(ends + s * 2);
      final start = b.getUint16(starts + s * 2);
      if (start == 0xFFFF) continue;
      for (var c = start; c <= end; c++) {
        points.add(c);
      }
    }
  }
  return points;
}

void main() {
  test('Sora cannot draw Cyrillic, so Russian must not be set in it', () {
    final sora = _codePoints('assets/fonts/Sora-SemiBold.ttf');
    final cyrillic = [for (var c = 0x0410; c <= 0x044F; c++) c];

    // Not an assumption — the assertion this whole fix rests on. If a future
    // Sora release adds Cyrillic, this fails and the locale swap can go.
    expect(
      cyrillic.where(sora.contains),
      isEmpty,
      reason: 'Sora gained Cyrillic — revisit displayFontFor',
    );
  });

  test('Montserrat covers the Cyrillic the card needs', () {
    final montserrat = _codePoints('assets/fonts/Montserrat-SemiBold.ttf');
    for (final word in ['Вечер', 'Утро', 'Постоянство', 'Всплески',
      'Возвращение', 'Нить', 'Фокус', 'Поиск', 'Начало']) {
      for (final ch in word.runes) {
        expect(montserrat.contains(ch), isTrue,
            reason: 'Montserrat is missing ${String.fromCharCode(ch)} in $word');
      }
    }
  });

  test('Montserrat draws everything the Russian strings say', () {
    // Every bundled weight against every character of copy, not a sample.
    // The two ornaments are missing from Sora as well, so the system face
    // draws them in both languages; anything else missing would be Russian
    // text in a typeface the rest of its screen is not using.
    const ornaments = {0x2726 /* ✦ */, 0x2665 /* ♥ */};
    final arb = jsonDecode(File('lib/l10n/app_ru.arb').readAsStringSync())
        as Map<String, dynamic>;
    final used = <int>{
      for (final entry in arb.entries)
        if (!entry.key.startsWith('@') && entry.value is String)
          ...(entry.value as String).runes,
    }..removeAll(const {0x09, 0x0A, 0x0D});

    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final montserrat = _codePoints('assets/fonts/Montserrat-$weight.ttf');
      expect(
        used.difference(montserrat).difference(ornaments).map(String.fromCharCode),
        isEmpty,
        reason: 'Montserrat-$weight cannot draw these',
      );
    }
  });

  test('the display face follows the locale', () {
    expect(AppTextStyles.displayFontFor('ru'), 'Montserrat');
    expect(AppTextStyles.displayFontFor('ru_RU'), 'Montserrat');
    expect(AppTextStyles.displayFontFor('en'), 'Sora');
    expect(AppTextStyles.displayFontFor('en_US'), 'Sora');
  });

  test('the default text style follows the locale', () {
    expect(AppTextStyles.defaultTextStyleFor('ru').fontFamily, 'Montserrat');
    // English is, to the letter, what `CupertinoApp.theme` used to carry.
    expect(
      AppTextStyles.defaultTextStyleFor('en'),
      const TextStyle(
        fontFamily: 'Sora',
        fontFamilyFallback: ['SF Pro', 'SF Pro Rounded'],
      ),
    );
  });

  test('no style names Sora directly, except the wordmark', () {
    // A style that hardcodes Sora is wrong in one of the app's two languages:
    // forty-five of them were, and nothing said so, because a device swaps in
    // its own face without a sound. `displayFontFor` is the way to ask.
    //
    // The wordmark is the exception — "Intended" is Latin in every locale and
    // deliberately the brand face. A new one belongs in this list, with the
    // same comment at the site that the two here carry.
    const wordmarks = {
      'lib/onboarding_v2/welcome_v2_screen.dart': 1,
      'lib/widgets/season_share_card.dart': 1,
    };
    // Where the faces are named, once.
    const definition = 'lib/utils/text_styles.dart';

    final literal = RegExp('''['"]Sora['"]''');
    final found = <String, int>{};
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (path == definition) continue;
      // Code only: comments are free to talk about Sora.
      final hits = entity
          .readAsLinesSync()
          .map((line) => line.split('//').first)
          .where(literal.hasMatch)
          .length;
      if (hits > 0) found[path] = hits;
    }

    expect(found, wordmarks);
  });
}
