import 'package:flutter_test/flutter_test.dart';
import 'package:intended/widgets/season_share_card.dart';

/// The hero's type scale. Untested, this is exactly the kind of layout rule
/// that regresses silently: a word gets renamed, nobody re-measures, and the
/// card ships with a clipped or comically shrunken season.
void main() {
  test('every step is one of the three, and nothing goes below the last', () {
    for (final word in [
      'Утро', 'Вечер', 'Постоянство', 'Всплески',
      'Возвращение', 'Нить', 'Фокус', 'Поиск', 'Начало',
      'Early', 'Evening', 'Steady', 'Bursts',
      'Returning', 'Continuous', 'Focused', 'Wandering', 'Beginning',
    ]) {
      final size = SeasonShareCard.heroSizeFor(word, 'Montserrat');
      expect(
        SeasonShareCard.heroSteps.contains(size),
        isTrue,
        reason: '$word landed on $size, which is not a step',
      );
    }
  });

  test('a longer word never gets a larger step than a shorter one', () {
    // The property that matters: the scale is monotonic in rendered width, so
    // a word can only ever step *down*. Absolute point sizes depend on the
    // test environment's font fallback, so the ordering is what is asserted.
    final short = SeasonShareCard.heroSizeFor('Нить', 'Montserrat');
    final long = SeasonShareCard.heroSizeFor(
        'Совершенно невозможно длинное слово', 'Montserrat');
    expect(long, lessThanOrEqualTo(short));
    expect(long, greaterThanOrEqualTo(SeasonShareCard.heroSteps.last));
  });

  test('a word that cannot fit at any step still returns the smallest', () {
    final size = SeasonShareCard.heroSizeFor('X' * 400, 'Montserrat');
    expect(size, SeasonShareCard.heroSteps.last);
  });
}
