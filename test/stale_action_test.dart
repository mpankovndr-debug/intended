import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/widgets/stale_action_nudge.dart';

final _today = DateTime(2026, 8, 20);

Moment _moment(String habit, int daysAgo) => Moment.create(
      habitName: habit,
      category: 'Health',
      at: _today.subtract(Duration(days: daysAgo)),
    );

void main() {
  group('isStale', () {
    test('says nothing about someone with no history at all', () {
      expect(
        StaleAction.isStale(habit: 'Body scan', moments: [], now: _today),
        isFalse,
      );
    });

    test('an action reached for inside the window is not stale', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: [_moment('Body scan', 6), _moment('Body scan', 40)],
          now: _today,
        ),
        isFalse,
      );
    });

    test('ten days of silence on one action is stale', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: [_moment('Drink water', 1), _moment('Body scan', 40)],
          now: _today,
        ),
        isTrue,
      );
    });

    test('the threshold is exactly ten days', () {
      List<Moment> history(int daysAgo) => [
            _moment('Body scan', daysAgo),
            _moment('Drink water', 60),
          ];
      expect(
        StaleAction.isStale(
            habit: 'Body scan', moments: history(9), now: _today),
        isFalse,
      );
      expect(
        StaleAction.isStale(
            habit: 'Body scan', moments: history(11), now: _today),
        isTrue,
      );
    });

    test('a history younger than the window stays silent', () {
      // An action three days into someone's whole practice has not failed to
      // land. It has not been tried.
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: [_moment('Drink water', 3)],
          now: _today,
        ),
        isFalse,
      );
    });

    test('does not depend on the order moments arrive in', () {
      final newestFirst = [_moment('Drink water', 1), _moment('Drink water', 40)];
      expect(
        StaleAction.isStale(
            habit: 'Body scan', moments: newestFirst, now: _today),
        isTrue,
      );
      expect(
        StaleAction.isStale(
            habit: 'Body scan',
            moments: newestFirst.reversed.toList(),
            now: _today),
        isTrue,
      );
    });
  });

  group('an action that has not had a fair chance yet', () {
    // A long history, so the account-age test passes and only the action's
    // own age is left deciding.
    final oldAccount = [_moment('Drink water', 1), _moment('Drink water', 180)];

    test('added three days ago to an old account is not stale', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: oldAccount,
          now: _today,
          adoptedAt: _today.subtract(const Duration(days: 3)),
        ),
        isFalse,
      );
    });

    test('adopted exactly on the threshold is not yet stale', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: oldAccount,
          now: _today,
          adoptedAt: _today.subtract(const Duration(days: StaleAction.afterDays)),
        ),
        isFalse,
      );
    });

    test('adopted a moment past the threshold can be', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: oldAccount,
          now: _today,
          adoptedAt: _today.subtract(
            const Duration(days: StaleAction.afterDays, seconds: 1),
          ),
        ),
        isTrue,
      );
    });

    test('an unrecorded adoption reads as old enough, so nothing changes', () {
      // Everything already on Today when adoption started being written down.
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: oldAccount,
          now: _today,
          adoptedAt: null,
        ),
        isTrue,
      );
    });

    test('a recent adoption cannot make a young account speak', () {
      // Both fair-chance tests must pass, not either one.
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: [_moment('Drink water', 3)],
          now: _today,
          adoptedAt: _today.subtract(const Duration(days: 100)),
        ),
        isFalse,
      );
    });

    test('adoption is an instant, whatever zone it was stamped in', () {
      expect(
        StaleAction.isStale(
          habit: 'Body scan',
          moments: oldAccount,
          now: _today,
          adoptedAt: DateTime.utc(2026, 8, 19, 22),
        ),
        isFalse,
      );
    });

    test('a too-new action is skipped, not allowed to block an older one', () {
      // 'Body scan' has been quiet for months and deserves the card; the
      // freshly added 'Stretch' sits in front of it in render order and must
      // not swallow the only nudge on the screen.
      expect(
        StaleAction.primary(
          visible: ['Drink water', 'Stretch', 'Body scan'],
          moments: [_moment('Drink water', 1), _moment('Body scan', 40)],
          now: _today,
          adoptedAt: {'Stretch': _today.subtract(const Duration(days: 2))},
        ),
        'Body scan',
      );
    });
  });

  group('primary', () {
    final history = [
      _moment('Drink water', 1),
      _moment('Body scan', 40),
    ];

    test('picks the first quiet action in render order', () {
      expect(
        StaleAction.primary(
          visible: ['Drink water', 'Body scan', 'Stretch'],
          moments: history,
          now: _today,
        ),
        'Body scan',
      );
    });

    test('only one action is ever offered the whole question', () {
      // Three quiet actions, one card. Four decisions on one screen is the
      // pressure this app removes.
      final chosen = StaleAction.primary(
        visible: ['Body scan', 'Stretch', 'Journal'],
        moments: history,
        now: _today,
      );
      expect(chosen, 'Body scan');
    });

    test('render order is the tiebreak, so it never changes between visits', () {
      expect(
        StaleAction.primary(
          visible: ['Stretch', 'Body scan'],
          moments: history,
          now: _today,
        ),
        'Stretch',
      );
      expect(
        StaleAction.primary(
          visible: ['Body scan', 'Stretch'],
          moments: history,
          now: _today,
        ),
        'Body scan',
      );
    });

    test('nothing quiet means nothing to ask', () {
      expect(
        StaleAction.primary(
          visible: ['Drink water'],
          moments: history,
          now: _today,
        ),
        isNull,
      );
    });

    test('says nothing with no history at all', () {
      expect(
        StaleAction.primary(visible: ['Body scan'], moments: [], now: _today),
        isNull,
      );
    });

    test('a history younger than the window stays silent', () {
      expect(
        StaleAction.primary(
          visible: ['Body scan'],
          moments: [_moment('Drink water', 3)],
          now: _today,
        ),
        isNull,
      );
    });
  });
}
