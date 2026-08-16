import '../l10n/app_localizations.dart';
import '../models/season.dart';

/// Pole → localised text. One copy, because there used to be three.
///
/// The `titleKey` scar: a switch like this was copy-pasted into six screens,
/// and adding five paths shipped a raw key to users because three copies were
/// missed. Every surface that names a season goes through here.
class SeasonL10n {
  const SeasonL10n._();

  /// The season's word — the hero on the share card, the word in the archive.
  static String word(String pole, AppLocalizations l10n) => switch (pole) {
        Season.morning => l10n.seasonMorning,
        Season.evening => l10n.seasonEvening,
        Season.steady => l10n.seasonSteady,
        Season.bursts => l10n.seasonBursts,
        Season.returning => l10n.seasonReturning,
        Season.continuous => l10n.seasonContinuous,
        Season.focused => l10n.seasonFocused,
        Season.wandering => l10n.seasonWandering,
        _ => l10n.seasonBeginning,
      };

  /// The reading under the word, in the app's second person — "you come here
  /// once the day has quieted".
  static String line(String pole, AppLocalizations l10n, int sampleSize) =>
      switch (pole) {
        Season.morning => l10n.seasonMorningLine,
        Season.evening => l10n.seasonEveningLine,
        Season.steady => l10n.seasonSteadyLine,
        Season.bursts => l10n.seasonBurstsLine,
        Season.returning => l10n.seasonReturningLine,
        Season.continuous => l10n.seasonContinuousLine,
        Season.focused => l10n.seasonFocusedLine,
        Season.wandering => l10n.seasonWanderingLine,
        _ => l10n.seasonBeginningLine(sampleSize),
      };

  /// The same reading in first person, for the card that gets posted.
  ///
  /// Present tense in every language, deliberately: Russian past-tense verbs
  /// carry the speaker's gender, so «я приходил» would tell half of readers
  /// the app thinks they are men — on the one screen built to be public.
  ///
  /// Each string is measured to fit 308pt at 15pt in its own display face. A
  /// line that wraps costs the card a row and moves the grid.
  static String shareLine(String pole, AppLocalizations l10n) =>
      switch (pole) {
        Season.morning => l10n.shareSeasonMorningLine,
        Season.evening => l10n.shareSeasonEveningLine,
        Season.steady => l10n.shareSeasonSteadyLine,
        Season.bursts => l10n.shareSeasonBurstsLine,
        Season.returning => l10n.shareSeasonReturningLine,
        Season.continuous => l10n.shareSeasonContinuousLine,
        Season.focused => l10n.shareSeasonFocusedLine,
        Season.wandering => l10n.shareSeasonWanderingLine,
        // A month still forming is never shared — the row that opens the card
        // hides below the threshold — so this is unreachable rather than copy.
        _ => l10n.shareSeasonEveningLine,
      };
}
