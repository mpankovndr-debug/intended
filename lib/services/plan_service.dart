import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/moment.dart';
import '../models/month_plan.dart';
import 'moments_service.dart';

/// A change the user accepted, and the count it is measured against.
///
/// The baseline is captured at the moment of acceptance rather than
/// recomputed later, so the "up from 14" can never quietly become a different
/// number once the comparison has been shown.
class AcceptedNudge {
  const AcceptedNudge({
    required this.kind,
    required this.subject,
    required this.monthKey,
    required this.acceptedOn,
    required this.before,
  });

  final NudgeKind kind;

  /// The action name, focus area or hour the change was about.
  final String subject;

  /// The plan month this was accepted from.
  final String monthKey;

  /// The user's own calendar day, as wall clock.
  final DateTime acceptedOn;

  /// Moments in the window immediately before the change.
  final int before;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'subject': subject,
        'monthKey': monthKey,
        'acceptedOn': acceptedOn.toIso8601String(),
        'before': before,
      };

  static AcceptedNudge? fromJson(Map<String, dynamic> json) {
    // A record written by a build that knew a kind this one doesn't is
    // dropped rather than guessed at.
    final matches = NudgeKind.values.where((k) => k.name == json['kind']);
    if (matches.isEmpty) return null;
    final kind = matches.first;
    return AcceptedNudge(
      kind: kind,
      subject: json['subject'] as String? ?? '',
      monthKey: json['monthKey'] as String? ?? '',
      acceptedOn: DateTime.parse(json['acceptedOn'] as String),
      before: json['before'] as int? ?? 0,
    );
  }
}

/// A completed before/after on a change the user made (§6.3).
class PlanProof {
  const PlanProof({
    required this.kind,
    required this.subject,
    required this.acceptedOn,
    required this.before,
    required this.after,
  });

  final NudgeKind kind;
  final String subject;
  final DateTime acceptedOn;
  final int before;
  final int after;
}

/// Stores the changes a user accepted, and measures what followed (§6.3).
///
/// Month one the app tells you things about yourself; month eight it tells you
/// whether what you changed is working. That second thing is what stops the
/// insights running out of novelty around month four, and it is the reason the
/// date of every accepted change is written down rather than just the change.
class PlanService {
  PlanService._();

  static const String _acceptedKey = 'plan_accepted_nudges';
  static const String _declinedKey = 'plan_declined_nudges';

  /// The measurement window, either side of a change.
  ///
  /// Both sides are the same length, always. Comparing "everything since" with
  /// a fixed month before would make every change look better the longer ago
  /// it was made, which is a graph that only ever goes up and therefore says
  /// nothing.
  static const int windowDays = 28;

  /// Records an accepted change and captures the baseline it will be measured
  /// against.
  static Future<void> accept(
    PlanNudge nudge,
    String monthKey, {
    DateTime? now,
  }) async {
    final today = _wallToday(now);
    final moments = await MomentsService.getAll();

    final accepted = AcceptedNudge(
      kind: nudge.kind,
      subject: nudge.subject,
      monthKey: monthKey,
      acceptedOn: today,
      before: _countBetween(
        moments,
        today.subtract(const Duration(days: windowDays)),
        today,
      ),
    );

    final all = await acceptedNudges();
    all.add(accepted);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _acceptedKey,
      jsonEncode([for (final a in all) a.toJson()]),
    );
  }

  /// Notes that the user passed on a suggestion, so this month's page stops
  /// asking. A suggestion that returns on every visit is a nag.
  static Future<void> decline(PlanNudge nudge, String monthKey) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _declined();
    final forMonth = {...?all[monthKey], nudge.id};
    all[monthKey] = forMonth;
    await prefs.setString(
      _declinedKey,
      jsonEncode(all.map((k, v) => MapEntry(k, v.toList()))),
    );
  }

  static Future<Set<String>> declinedFor(String monthKey) async {
    final all = await _declined();
    return all[monthKey] ?? {};
  }

  /// The change accepted from [monthKey]'s plan, if there is one.
  ///
  /// One decision per month (§5.3): once something has been accepted, the card
  /// stops proposing and the rest of the month's suggestions wait behind the
  /// "more when you're ready" line.
  static Future<AcceptedNudge?> acceptedFor(String monthKey) async {
    final all = await acceptedNudges();
    for (final a in all.reversed) {
      if (a.monthKey == monthKey) return a;
    }
    return null;
  }

  static Future<List<AcceptedNudge>> acceptedNudges() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_acceptedKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      final all = <AcceptedNudge>[];
      for (final e in decoded) {
        final parsed = AcceptedNudge.fromJson(e as Map<String, dynamic>);
        if (parsed != null) all.add(parsed);
      }
      return all;
    } catch (_) {
      return [];
    }
  }

  /// The most recent change that has had a full window to show an effect.
  ///
  /// Null until then. A change made nine days ago has not been given the same
  /// four weeks its baseline had, and reporting it early would be measuring
  /// enthusiasm rather than effect.
  static Future<PlanProof?> proof({DateTime? now}) async {
    final today = _wallToday(now);
    final all = await acceptedNudges();

    AcceptedNudge? latest;
    for (final a in all) {
      if (today.difference(a.acceptedOn).inDays < windowDays) continue;
      if (latest == null || a.acceptedOn.isAfter(latest.acceptedOn)) {
        latest = a;
      }
    }
    if (latest == null) return null;

    final moments = await MomentsService.getAll();
    return PlanProof(
      kind: latest.kind,
      subject: latest.subject,
      acceptedOn: latest.acceptedOn,
      before: latest.before,
      after: _countBetween(
        moments,
        latest.acceptedOn,
        latest.acceptedOn.add(const Duration(days: windowDays)),
      ),
    );
  }

  static Future<Map<String, Set<String>>> _declined() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_declinedKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, {for (final id in v as List) id as String}),
      );
    } catch (_) {
      return {};
    }
  }

  /// Moments in `[from, to)`, counted on the clock each one recorded.
  static int _countBetween(List<Moment> moments, DateTime from, DateTime to) {
    return moments.where((m) {
      final at = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final day = DateTime.utc(at.year, at.month, at.day);
      return !day.isBefore(from) && day.isBefore(to);
    }).length;
  }

  /// Today on the user's own clock, flagged UTC so it compares directly with
  /// the wall-clock days every reader in this app builds from stored offsets.
  static DateTime _wallToday(DateTime? now) {
    final local = now ?? DateTime.now();
    return DateTime.utc(local.year, local.month, local.day);
  }
}
