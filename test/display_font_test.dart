import 'dart:io';

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

  test('the display face follows the locale', () {
    expect(AppTextStyles.displayFontFor('ru'), 'Montserrat');
    expect(AppTextStyles.displayFontFor('ru_RU'), 'Montserrat');
    expect(AppTextStyles.displayFontFor('en'), 'Sora');
    expect(AppTextStyles.displayFontFor('en_US'), 'Sora');
  });
}
