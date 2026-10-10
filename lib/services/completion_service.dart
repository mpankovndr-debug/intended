import '../main.dart' show HabitTracker;
import '../models/moment.dart';
import 'analytics_service.dart';
import 'milestone_service.dart';
import 'moments_service.dart';
import 'reflection_service.dart';

/// Records one completed action: the one way in for Today's card, the
/// yesterday-log, the reduced home screen, and onboarding's first moment.
///
/// It was copied into each of those, and every copy has to write both
/// stores: a Moment without its `habit_done_` key leaves anything counting
/// from one store disagreeing with anything counting from the other.
///
/// Backup and the home-screen widget need a `BuildContext`, so the caller
/// runs those.
class CompletionService {
  CompletionService._();

  /// [on] is a *local* date for the yesterday-log; a live completion leaves
  /// it null and is also counted in analytics, as it always was.
  static Future<Moment> record(String habitTitle, {DateTime? on}) async {
    await HabitTracker.markDone(habitTitle, on: on);
    if (on == null) AnalyticsService.logHabitCompleted(habitTitle);

    final moment = Moment.create(
      habitName: habitTitle,
      category: ReflectionService.categoryForHabit(habitTitle),
      at: on,
    );
    await MomentsService.record(moment);
    MilestoneService.invalidate();
    return moment;
  }
}
