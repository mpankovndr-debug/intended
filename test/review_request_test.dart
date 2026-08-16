import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/review_request_service.dart';

/// The review policy shipped a whole release with zero coverage, because every
/// decision in it sat behind a BuildContext. It's pure statics now, and this
/// pins the behaviour that decides whether the app ever gets past the three
/// ratings Apple needs before it will show stars at all.
void main() {
  final now = DateTime(2026, 8, 16, 21, 30);

  group('which trigger a completion earns', () {
    test('finishing the day outranks any count', () {
      expect(
        ReviewRequestService.triggerForCompletion(totalCompletions: 1, allDoneToday: true),
        ReviewRequestService.triggerAllDoneToday,
      );
      // …even sitting exactly on the 5-milestone.
      expect(
        ReviewRequestService.triggerForCompletion(totalCompletions: 5, allDoneToday: true),
        ReviewRequestService.triggerAllDoneToday,
      );
    });

    test('the 5th and 7th completions each have their moment', () {
      expect(
        ReviewRequestService.triggerForCompletion(totalCompletions: 5, allDoneToday: false),
        ReviewRequestService.triggerMilestone5,
      );
      expect(
        ReviewRequestService.triggerForCompletion(totalCompletions: 7, allDoneToday: false),
        ReviewRequestService.triggerCompletions7,
      );
    });

    test('past 7, the smaller milestone cannot fire behind you', () {
      expect(
        ReviewRequestService.triggerForCompletion(totalCompletions: 40, allDoneToday: false),
        ReviewRequestService.triggerCompletions7,
      );
    });

    test('early completions earn nothing', () {
      for (final n in [0, 1, 4, 6]) {
        expect(
          ReviewRequestService.triggerForCompletion(totalCompletions: n, allDoneToday: false),
          isNull,
          reason: '$n completions should not ask',
        );
      }
    });
  });

  group('which trigger the month page earns', () {
    test('the letter outranks the season — it lands last and reads longest',
        () {
      expect(
        ReviewRequestService.triggerForMonthRead(seasonResolved: true, letterShown: true),
        ReviewRequestService.triggerLetterRead,
      );
    });

    test('a resolved season on its own is enough', () {
      expect(
        ReviewRequestService.triggerForMonthRead(seasonResolved: true, letterShown: false),
        ReviewRequestService.triggerSeasonRead,
      );
    });

    test('an unresolved month asks for nothing', () {
      // A "Beginning" season is the app saying it doesn't know you yet. Asking
      // for five stars on top of that is the worst version of this feature.
      expect(
        ReviewRequestService.triggerForMonthRead(seasonResolved: false, letterShown: false),
        isNull,
      );
    });
  });

  group('whether we may ask', () {
    bool may({
      String trigger = ReviewRequestService.triggerAllDoneToday,
      bool paywall = false,
      List<String> shown = const [],
      int dismissed = 0,
      DateTime? lastAsk,
    }) =>
        ReviewRequestService.mayAsk(
          trigger: trigger,
          paywallShownThisSession: paywall,
          shownTriggers: shown,
          legacyDismissedCount: dismissed,
          lastAskAt: lastAsk,
          now: now,
        );

    test('a clean slate may ask', () {
      expect(may(), isTrue);
    });

    test('never in the same session as a paywall', () {
      // Nobody should be asked to rate an app in the sitting they were asked
      // to pay for it.
      expect(may(paywall: true), isFalse);
    });

    test('each trigger fires at most once, ever', () {
      expect(
        may(shown: const [ReviewRequestService.triggerAllDoneToday]),
        isFalse,
      );
      // A different trigger is still free.
      expect(
        may(
          trigger: ReviewRequestService.triggerLetterRead,
          shown: const [ReviewRequestService.triggerAllDoneToday],
        ),
        isTrue,
      );
    });

    test('30-day cooldown across all triggers', () {
      expect(may(lastAsk: now.subtract(const Duration(days: 29))), isFalse);
      expect(
        may(lastAsk: now.subtract(const Duration(days: 29, hours: 23))),
        isFalse,
      );
      expect(may(lastAsk: now.subtract(const Duration(days: 30))), isTrue);
      expect(may(lastAsk: now.subtract(const Duration(days: 400))), isTrue);
    });

    test('anyone who dismissed the old dialog twice stays opted out', () {
      // They told the prompt this service used to show "Not yet", twice. That
      // was a choice, and it survives the rewrite even though nothing can add
      // to the count any more.
      expect(may(dismissed: 2), isFalse);
      expect(may(dismissed: 5), isFalse);
      expect(may(dismissed: 1), isTrue);
    });

    test('the gates are independent — any one of them is enough to block', () {
      expect(
        may(
          paywall: true,
          shown: const [ReviewRequestService.triggerAllDoneToday],
          dismissed: 2,
          lastAsk: now,
        ),
        isFalse,
      );
    });
  });

  test('trigger ids are stable — they are persisted', () {
    // Renaming any of these silently re-opens a trigger for every existing
    // user, because the stored list would no longer match.
    expect(ReviewRequestService.triggerAllDoneToday, 'all_done_today');
    expect(ReviewRequestService.triggerCompletions7, 'completions_7');
    expect(ReviewRequestService.triggerMilestone5, 'milestone_habits_5');
    expect(ReviewRequestService.triggerSeasonRead, 'season_read');
    expect(ReviewRequestService.triggerLetterRead, 'letter_read');
  });
}
