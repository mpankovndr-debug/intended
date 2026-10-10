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
  static Future<Moment> record(String habitTitle, {DateTime? on}) =>
      commit(draft(habitTitle, on: on), live: on == null);

  /// The moment a tap on [habitTitle] would record, not yet stored. The
  /// completion sheet shows it and keeps it only on Done, so a wrong card
  /// closed with the X writes nothing. [on] as for [record].
  static Moment draft(String habitTitle, {DateTime? on}) => Moment.create(
        habitName: habitTitle,
        category: ReflectionService.categoryForHabit(habitTitle),
        at: on,
      );

  /// Writes [moment] to both stores: [record], for a [draft] the sheet has
  /// added a mood or note to. [live] is false for the yesterday-log, which
  /// analytics never counted.
  static Future<Moment> commit(Moment moment, {required bool live}) async {
    // The moment's own wall clock, so the key lands on the day the moment
    // says — even when Done comes after midnight on a tap from before it.
    await HabitTracker.markDone(moment.habitName, on: moment.localWallClock);
    if (live) AnalyticsService.logHabitCompleted(moment.habitName);
    await MomentsService.record(moment);
    MilestoneService.invalidate();
    return moment;
  }
}
