import 'gratitude_entry.dart';

/// A month of pages, read the way [PauseMonth] reads pauses and the grid
/// reads moments: filtered by each entry's own recorded wall clock, oldest
/// first so the first page you scroll to is the month's first page. Pure
/// statics, so the whole reading is testable without a screen.
class GratitudeMonth {
  GratitudeMonth._();

  /// The entries whose *local* day falls in [anchor]'s month. Never the
  /// device's current zone — [GratitudeEntry.localDay] carries the offset the
  /// page was written in.
  ///
  /// *Scar:* `momentsForMonth` once added the anchor's offset to an already
  /// local anchor, and every user west of UTC read the previous month for a
  /// whole month. The anchor here is compared field by field, never shifted.
  static List<GratitudeEntry> forMonth(
      List<GratitudeEntry> all, DateTime anchor) {
    final inMonth = [
      for (final e in all)
        if (e.localDay.year == anchor.year && e.localDay.month == anchor.month)
          e,
    ];
    // Dart's sort is not stable; the id (an ISO instant) breaks ties so the
    // list cannot reshuffle between visits.
    inMonth.sort((a, b) {
      final byTime = a.completedAt.compareTo(b.completedAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return inMonth;
  }

  /// Months that hold at least one page, newest first, as UTC-flagged firsts
  /// of the month. What the archive's back arrow walks; a month with nothing
  /// in it is not a stop on that walk, because an empty month view is the
  /// "look how much you haven't done" this app does not render.
  static List<DateTime> monthsWithPages(List<GratitudeEntry> all) {
    final keys = <String, DateTime>{};
    for (final e in all) {
      final d = e.localDay;
      keys['${d.year}-${d.month}'] = DateTime.utc(d.year, d.month, 1);
    }
    final months = keys.values.toList()..sort((a, b) => b.compareTo(a));
    return months;
  }

  /// The page written on [day], or null. Null rather than an empty entry:
  /// every model feeding a card returns null when it has nothing (§11), and
  /// "no page yet" is what tells the writing screen to open a fresh one.
  static GratitudeEntry? forDay(List<GratitudeEntry> all, DateTime day) {
    final target = DateTime.utc(day.year, day.month, day.day);
    for (final e in all) {
      if (e.localDay == target) return e;
    }
    return null;
  }
}
