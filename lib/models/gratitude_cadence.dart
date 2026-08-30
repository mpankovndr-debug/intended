/// How often the page asks for you.
///
/// A choice, not a default we picked for everyone. The evidence points two
/// ways and both are honest: counting blessings once a week raised wellbeing
/// in Lyubomirsky's work where three times a week did not — hedonic
/// adaptation flattens a thing repeated too often — while a practice
/// prescribed daily by someone's therapist is a daily practice, and an app
/// that quietly rations it is working against them.
///
/// What the cadence sets is *when the reminder fires*. It is never a target,
/// never a denominator, and nothing anywhere counts pages against it: the
/// moment "you chose daily" can be compared with "you wrote four times", the
/// chooser has become the streak this app deleted.
enum GratitudeCadence {
  /// Every evening.
  daily('daily'),

  /// Three evenings, spread so no two are adjacent.
  fewDays('few_days'),

  /// One evening a week.
  weekly('weekly');

  const GratitudeCadence(this.key);

  /// Stable storage key. Never change these — they are persisted.
  final String key;

  static GratitudeCadence? fromKey(String? key) {
    if (key == null) return null;
    for (final c in GratitudeCadence.values) {
      if (c.key == key) return c;
    }
    return null;
  }
}

/// When the page reminder fires, as pure statics — no `BuildContext`, no
/// plugin, no clock beyond what is passed in. The scheduler's own selection
/// policy used to live inside a method that needed a Navigator and had zero
/// coverage (§11); this exists so that cannot happen again.
class GratitudeSchedule {
  GratitudeSchedule._();

  /// Weekdays (Mon=1) each cadence fires on.
  ///
  /// [GratitudeCadence.fewDays] is Monday, Wednesday and Saturday: three
  /// evenings with a gap either side of each, so a missed one is never two
  /// in a row. Not user-chosen — the chooser says "three evenings a week"
  /// and means exactly that. Promising a picker the app does not have is how
  /// copy starts lying.
  static const Map<GratitudeCadence, List<int>> weekdaysFor = {
    GratitudeCadence.daily: [1, 2, 3, 4, 5, 6, 7],
    GratitudeCadence.fewDays: [1, 3, 6],
    GratitudeCadence.weekly: [DateTime.sunday],
  };

  /// Whether the reminder belongs on [date]'s weekday under [cadence].
  static bool firesOn(GratitudeCadence cadence, DateTime date) =>
      weekdaysFor[cadence]!.contains(date.weekday);

  /// The next [count] local dates the reminder should fire on, starting from
  /// [from] and never including a slot already past today's [hour]:[minute].
  ///
  /// Returned as plain local dates at the given time. The caller turns them
  /// into zoned instants — this stays free of the timezone package so it can
  /// be tested with nothing but a DateTime.
  static List<DateTime> nextFireTimes(
    GratitudeCadence cadence, {
    required DateTime from,
    required int hour,
    required int minute,
    int count = 7,
  }) {
    final out = <DateTime>[];
    var day = DateTime(from.year, from.month, from.day);
    // Enough lookahead to fill [count] weekly slots, which is the sparsest
    // cadence — 14 of those is 98 days, so the bound has to clear that.
    for (var i = 0; i < 140 && out.length < count; i++) {
      final at = DateTime(day.year, day.month, day.day, hour, minute);
      if (firesOn(cadence, day) && at.isAfter(from)) out.add(at);
      day = day.add(const Duration(days: 1));
    }
    return out;
  }
}
