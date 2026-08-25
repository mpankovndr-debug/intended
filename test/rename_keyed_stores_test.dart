import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/month_plan.dart';
import 'package:intended/services/plan_service.dart';
import 'package:intended/widgets/stale_action_nudge.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app stores under an action's *title* has to move when the
/// title does. Otherwise a rename quietly undoes the user's own answers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StaleNudgeDismissals.rename', () {
    test('a dismissal follows the new name', () async {
      SharedPreferences.setMockInitialValues({
        'stale_nudge_dismissed': ['Walk the dog', 'Read'],
      });
      await StaleNudgeDismissals.rename('Walk the dog', 'Walk Bruno');

      final all = await StaleNudgeDismissals.read();
      expect(all, {'Walk Bruno', 'Read'});
    });

    test('an action that was never dismissed stays undismissed', () async {
      SharedPreferences.setMockInitialValues({
        'stale_nudge_dismissed': ['Read'],
      });
      await StaleNudgeDismissals.rename('Walk the dog', 'Walk Bruno');

      expect(await StaleNudgeDismissals.read(), {'Read'});
    });
  });

  group('PlanService.renameSubject', () {
    test('a declined suggestion stays declined', () async {
      SharedPreferences.setMockInitialValues({
        'plan_declined_nudges': jsonEncode({
          '2026-08': ['setAside:Walk the dog', 'keepAnchor:Read'],
        }),
      });
      await PlanService.renameSubject('Walk the dog', 'Walk Bruno');

      expect(
        await PlanService.declinedFor('2026-08'),
        {'setAside:Walk Bruno', 'keepAnchor:Read'},
      );
    });

    test('a subject holding a colon splits on the first one only', () async {
      SharedPreferences.setMockInitialValues({
        'plan_declined_nudges': jsonEncode({
          '2026-08': ['setAside:Read: one page'],
        }),
      });
      await PlanService.renameSubject('Read: one page', 'Read a page');

      expect(
        await PlanService.declinedFor('2026-08'),
        {'setAside:Read a page'},
      );
    });

    test('another action\'s decline is untouched', () async {
      SharedPreferences.setMockInitialValues({
        'plan_declined_nudges': jsonEncode({
          '2026-08': ['setAside:Read'],
        }),
      });
      await PlanService.renameSubject('Walk the dog', 'Walk Bruno');

      expect(await PlanService.declinedFor('2026-08'), {'setAside:Read'});
    });

    test('an accepted change keeps naming the same action', () async {
      SharedPreferences.setMockInitialValues({
        'plan_accepted_nudges': jsonEncode([
          {
            'kind': NudgeKind.keepAnchor.name,
            'subject': 'Walk the dog',
            'monthKey': '2026-08',
            'acceptedOn': '2026-08-03T00:00:00.000Z',
            'before': 14,
          },
        ]),
      });
      await PlanService.renameSubject('Walk the dog', 'Walk Bruno');

      final all = await PlanService.acceptedNudges();
      expect(all.single.subject, 'Walk Bruno');
      // The measurement it carries must survive the rewrite untouched.
      expect(all.single.before, 14);
      expect(all.single.kind, NudgeKind.keepAnchor);
    });
  });
}
