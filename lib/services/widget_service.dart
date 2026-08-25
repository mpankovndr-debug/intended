import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/moment.dart';
import '../models/widget_month_summary.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/reflection_service.dart';
import '../theme/app_colors.dart';
import '../theme/category_colors.dart';
import '../utils/habit_l10n.dart';
import '../widgets/moment_grid.dart';

/// Pushes habit, month and theme data to the iOS home screen widgets via
/// App Groups. Every sentence the widget shows is composed here, in the
/// app's own localizer; the extension only lays text out.
class WidgetService {
  static const _appGroupId = 'group.com.intendedapp.ios';
  static const _iOSBasicWidgetName = 'IntendedBasicWidget';
  static const _iOSPremiumWidgetName = 'IntendedPremiumWidget';
  static const _iOSLockScreenWidgetName = 'IntendedLockScreenWidget';
  static const _iOSPauseWidgetName = 'IntendedPauseWidget';

  /// Bump when the art assets change so installed devices re-render them.
  static const _artVersion = 6;
  static const _artThemeKey = 'widget_art_theme';

  static Future<void>? _initFuture;

  /// Call once at startup.
  static Future<void> initialize() {
    _initFuture ??= HomeWidget.setAppGroupId(_appGroupId);
    return _initFuture!;
  }

  /// Push all widget data. Call after habit changes, theme changes, app launch.
  static Future<void> updateWidget({
    required List<String> userHabits,
    required Map<String, String> customHabitFocusAreas,
    required bool isPremium,
    required AppTheme theme,
    required String greeting,
    String locale = 'en',
    AppLocalizations? l10n,
    List<String> monthTileHexes = const [],
    List<Moment> monthMoments = const [],
  }) async {
    await initialize();

    final now = DateTime.now();
    final completedIds = await HabitTracker.allCompletedIdsForDate(now);

    // Build habit list with completion status, focus area colour, and the
    // wall-clock time of today's moment (from the moment's own offset).
    final habitDataList = <Map<String, dynamic>>[];
    for (final habit in userHabits) {
      final id = HabitTracker.habitId(habit);
      final done = completedIds.contains(id);
      final category = _categoryForHabit(habit, customHabitFocusAreas);
      final color = category != null
          ? AppColors.categoryColors[category]
          : null;
      final doneAt = done
          ? WidgetMonthSummary.latestTodayFor(monthMoments, habit, now)
          : null;

      final displayName = l10n != null ? localizeHabitName(habit, l10n) : habit;
      habitDataList.add({
        'name': displayName,
        'rawName': habit, // English key for HabitTracker ID resolution
        'done': done,
        'colorHex': color != null ? _colorToHex(color) : null,
        'doneAt': doneAt != null ? DateFormat.Hm(locale).format(doneAt) : null,
      });
    }

    final completedCount =
        habitDataList.where((h) => h['done'] == true).length;
    final totalCount = userHabits.length;

    // The month in words: "August · 23 moments" for the small and medium,
    // "August 23 · 37 moments · back 2 times" for the large. Returns use the
    // grid's own definition so the widget never disagrees with Insights.
    // An empty month names the month and nothing else — "0 moments" is a
    // denominator in disguise.
    final momentCount = monthMoments.length;
    final returnCount = MomentGrid.returnIndicesFor(monthMoments).length;
    final moments = l10n?.widgetMomentsCount(momentCount) ?? '$momentCount';
    final eyebrowSmall = [
      DateFormat.MMMM(locale).format(now),
      if (momentCount > 0) moments,
    ].join(' · ');
    final eyebrowLarge = [
      DateFormat.MMMMd(locale).format(now),
      if (momentCount > 0) moments,
      if (returnCount > 0 && l10n != null)
        l10n.widgetReturnsCount(returnCount),
    ].join(' · ');

    final legend = [
      for (final e in WidgetMonthSummary.legend(monthMoments))
        {
          'label':
              '${l10n != null ? localizeCategoryName(e.category, l10n) : e.category} ${e.count}',
          'hex': _colorToHex(CategoryColors.of(e.category, theme)),
        },
    ];

    // Theme colors for widget rendering
    final colors = AppColors.of(theme);
    final themeData = {
      'id': theme.name,
      'isDark': theme.isDark,
      'bgTop': _colorToHex(colors.bgGradientTop),
      'bgBottom': _colorToHex(colors.bgGradientBottom),
      'bg1': _colorToHex(colors.onboardingBg1),
      'bg2': _colorToHex(colors.onboardingBg2),
      'bg3': _colorToHex(colors.onboardingBg3),
      'textPrimary': _colorToHex(colors.textPrimary),
      'textSecondary': _colorToHex(colors.textSecondary),
      'textTertiary': _colorToHex(colors.textTertiary),
      'accent': _colorToHex(colors.checkmarkFill),
      'cardBg': _colorToHex(colors.cardBackground),
      'cardBgOpacity': colors.cardBackgroundOpacity,
      'checkmark': _colorToHex(colors.checkmarkFill),
    };

    // Write all data to shared UserDefaults
    await Future.wait([
      HomeWidget.saveWidgetData<String>(
          'widget_habits', jsonEncode(habitDataList)),
      HomeWidget.saveWidgetData<int>(
          'widget_completed_count', completedCount),
      HomeWidget.saveWidgetData<int>('widget_total_count', totalCount),
      HomeWidget.saveWidgetData<String>('widget_greeting', greeting),
      HomeWidget.saveWidgetData<bool>('widget_is_premium', isPremium),
      HomeWidget.saveWidgetData<String>(
          'widget_month_tiles', jsonEncode(monthTileHexes)),
      HomeWidget.saveWidgetData<String>('widget_eyebrow_small', eyebrowSmall),
      HomeWidget.saveWidgetData<String>('widget_eyebrow_large', eyebrowLarge),
      HomeWidget.saveWidgetData<String>('widget_legend', jsonEncode(legend)),
      HomeWidget.saveWidgetData<String>(
          'widget_month_unlock', l10n?.widgetMonthUnlock ?? ''),
      HomeWidget.saveWidgetData<String>('widget_theme', jsonEncode(themeData)),
      HomeWidget.saveWidgetData<String>('widget_locale', locale),
    ]);

    await _ensureArt(theme);

    // Tell iOS to reload all widget timelines
    await HomeWidget.updateWidget(iOSName: _iOSBasicWidgetName);
    await HomeWidget.updateWidget(iOSName: _iOSPremiumWidgetName);
    await HomeWidget.updateWidget(iOSName: _iOSLockScreenWidgetName);
    await HomeWidget.updateWidget(iOSName: _iOSPauseWidgetName);
  }

  /// Renders the theme's painted background into the app group container,
  /// once per theme. Two ceilings decide the size, and the tighter one is not
  /// the documented one: WidgetKit refuses to archive a timeline entry whose
  /// images exceed a total area (~1.24M px² on an iPhone 17 Pro Max), so a 3×
  /// render of the large widget — 1092×1146 = 1,251,432 px² — fails with
  /// `ArchivingError.imageTooLarge` and the widget shows its placeholder
  /// forever. These are rendered at 2×, which is invisible on art this soft
  /// and leaves half the area budget spare on smaller devices; it also keeps
  /// the extension well under its 30 MB memory ceiling.
  static Future<void> _ensureArt(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final stamp = '${theme.name}@$_artVersion';
    if (prefs.getString(_artThemeKey) == stamp) return;

    final art = WidgetArt.forTheme(theme);
    if (art == null) {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('widget_art_square', ''),
        HomeWidget.saveWidgetData<String>('widget_art_wide', ''),
      ]);
      await prefs.setString(_artThemeKey, stamp);
      return;
    }
    try {
      await _renderArt(
          art.square, 'widget_art_square', const Size(760, 800), art.squareAlign);
      await _renderArt(
          art.wide, 'widget_art_wide', const Size(760, 356), art.wideAlign);
      await prefs.setString(_artThemeKey, stamp);
    } catch (_) {
      // Leave the stamp unset so the next update retries; the widget keeps
      // whatever it had (or its gradient).
    }
  }

  static Future<void> _renderArt(
    String asset,
    String key,
    Size px,
    Alignment align,
  ) async {
    final bytes = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: px.width.round(),
    );
    final frame = await codec.getNextFrame();
    // RawImage paints a decoded image synchronously, which is what an
    // off-screen render needs — Image.asset would paint its first frame blank.
    // width/height are not decoration: without them RawImage lays out at the
    // image's *natural* pixel size, overflows the render box, and the capture
    // bakes in Flutter's overflow stripes (seen in the widget gallery).
    await HomeWidget.renderFlutterWidget(
      RawImage(
        image: frame.image,
        width: px.width,
        height: px.height,
        fit: BoxFit.cover,
        alignment: align,
      ),
      key: key,
      logicalSize: px,
    );
    frame.image.dispose();
  }

  /// Resolves a habit title to its focus area category name.
  static String? _categoryForHabit(
      String habit, Map<String, String> customFocusAreas) {
    for (final entry in OnboardingState.habitsByCategory.entries) {
      if (entry.value.contains(habit)) return entry.key;
    }
    // An action from a retired focus area, still held by whoever had it.
    final retired = OnboardingState.retiredHabitCategories[habit];
    if (retired != null) return retired;
    // Custom habits
    return customFocusAreas[habit] ??
        ReflectionService.customHabitFocusAreaFor(habit);
  }

  /// Converts a Color to a hex string like "FF3C342A".
  static String _colorToHex(Color c) {
    final argb = ((c.a * 255).round() << 24) |
        ((c.r * 255).round() << 16) |
        ((c.g * 255).round() << 8) |
        (c.b * 255).round();
    return argb.toRadixString(16).padLeft(8, '0').toUpperCase();
  }
}
