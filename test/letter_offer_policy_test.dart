import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/letter_offer_policy.dart';

void main() {
  final day10 = DateTime(2026, 8, 15, 12);
  final firstLaunch = DateTime(2026, 8, 5, 9);

  bool offer({
    bool hasSubscription = false,
    bool letterExists = true,
    DateTime? first,
    DateTime? now,
    String? lastOfferedMonth,
  }) =>
      LetterOfferPolicy.shouldOffer(
        hasSubscription: hasSubscription,
        letterExists: letterExists,
        firstLaunch: first ?? firstLaunch,
        now: now ?? day10,
        lastOfferedMonth: lastOfferedMonth,
      );

  group('LetterOfferPolicy', () {
    test('offers when free, letter real, old enough, not yet this month', () {
      expect(offer(), isTrue);
    });

    test('never offers to subscribers', () {
      expect(offer(hasSubscription: true), isFalse);
    });

    test('never offers without a computed letter', () {
      expect(offer(letterExists: false), isFalse);
    });

    test('stays quiet when first launch is unknown', () {
      expect(
        LetterOfferPolicy.shouldOffer(
          hasSubscription: false,
          letterExists: true,
          firstLaunch: null,
          now: day10,
          lastOfferedMonth: null,
        ),
        isFalse,
      );
    });

    test('quiet through day three, allowed from day four', () {
      final first = DateTime(2026, 8, 5, 9);
      // Day 3 of life (inDays == 2): quiet.
      expect(offer(first: first, now: DateTime(2026, 8, 7, 12)), isFalse);
      // inDays == 3, the fourth day: allowed.
      expect(offer(first: first, now: DateTime(2026, 8, 8, 10)), isTrue);
    });

    test('at most once per month, re-arms on the next month', () {
      expect(offer(lastOfferedMonth: '2026-08'), isFalse);
      expect(offer(lastOfferedMonth: '2026-07'), isTrue);
    });

    test('monthKey pads to a stable yyyy-MM', () {
      expect(LetterOfferPolicy.monthKey(DateTime(2026, 8, 1)), '2026-08');
      expect(LetterOfferPolicy.monthKey(DateTime(2026, 12, 31)), '2026-12');
    });
  });
}
