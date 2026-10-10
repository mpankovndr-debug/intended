import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'responsive_utils.dart';
import '../theme/theme_provider.dart';

/// Intended text styles with locale-aware sizing
///
/// TWO FONT ROLES, both swapped by locale — Sora has no Cyrillic:
/// - Headers: Sora (EN) / Montserrat (RU)
/// - Body:    Sora (EN) / Montserrat (RU)
///
/// Russian text is typically 20-30% longer than English.
/// These styles automatically reduce font sizes slightly for Russian.
///
/// Usage:
/// ```dart
/// Text(localizedString, style: AppTextStyles.h1(context))
/// ```
class AppTextStyles {
  // Font families
  static const String _headerFont = 'Sora';
  static const String _bodyFontEn = 'Sora';
  static const String _bodyFontRu = 'Montserrat';

  /// Get current locale code from context
  static String _getLocale(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// Returns the body font for the current locale.
  /// Public so inline styles outside AppTextStyles can use it.
  static String bodyFont(BuildContext context) {
    return _bodyFontForLocale(_getLocale(context));
  }

  static String _bodyFontForLocale(String locale) {
    return locale == 'ru' ? _bodyFontRu : _bodyFontEn;
  }

  /// The display face for [localeName] — for surfaces that compose their own
  /// text styles rather than calling into this class, like the share card.
  ///
  /// Sora carries no Cyrillic whatsoever: 0 of the 64 letters А–я are in the
  /// font file. Russian set in Sora does not produce tofu — iOS substitutes
  /// Helvetica silently (a 22pt w600 heading in a simulator capture overlays
  /// Helvetica Bold to within a third of a point) — it simply stops being the
  /// brand, which is why this went unnoticed. Montserrat is the Cyrillic
  /// display face, and sets 7–11% wider than that Helvetica did.
  ///
  /// Takes the locale name rather than a `BuildContext` so the choice stays a
  /// pure function that a test can call.
  static String displayFontFor(String localeName) =>
      localeName.startsWith('ru') ? _bodyFontRu : _headerFont;

  /// What text draws in when its own style names no family: the display face
  /// for [localeName], then the system faces for what that face cannot draw.
  ///
  /// The app-wide default, installed by `LocaleTextTheme`. Pure for the same
  /// reason [displayFontFor] is.
  static TextStyle defaultTextStyleFor(String localeName) => TextStyle(
        fontFamily: displayFontFor(localeName),
        fontFamilyFallback: const ['SF Pro', 'SF Pro Rounded'],
      );

  /// The size of the season's word under a page title set at [titleSize].
  ///
  /// 30pt, and never more than 96% of the title: the word is the biggest
  /// thing in its card and must not outgrow the screen it sits on. On a
  /// full-width screen that changes nothing — 30 under 34 in English, 30
  /// under 31.3 in Russian. It bites where the title has shrunk further: on
  /// a 375pt phone in Russian the title is 29.8pt, and a fixed 30 stood
  /// over it.
  ///
  /// Pure, so the rule can be tested without a context.
  static double seasonWordSize(double titleSize) {
    final ceiling = titleSize * 0.96;
    return ceiling < 30 ? ceiling : 30;
  }

  /// Adjust font size for Russian text (8% smaller)
  static double _localizedSize(double base, String locale) {
    if (locale == 'ru') {
      return base * 0.92;
    }
    return base;
  }

  /// Adjust line height for Russian (slightly taller for readability)
  static double _localizedHeight(double base, String locale) {
    if (locale == 'ru') {
      return base * 1.05;
    }
    return base;
  }

  // ============================================================
  // HEADERS (Sora EN / Montserrat RU)
  // ============================================================

  /// Display - Large welcome title
  /// 36px, Sora (EN) / Montserrat (RU), weight 600
  static TextStyle display(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(36, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.textPrimary,
      letterSpacing: -0.6,
      height: _localizedHeight(1.18, locale),
    );
  }

  /// H1 - Screen titles ("Profile", "Your week")
  /// 34px, Sora (EN) / Montserrat (RU), weight 700
  static TextStyle h1(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(34, locale)),
      fontWeight: FontWeight.w700,
      fontFamily: displayFontFor(locale),
      color: colors.textPrimary,
      letterSpacing: -0.5,
      height: _localizedHeight(1.2, locale),
    );
  }

  /// H2 - Modal titles ("Browse Habits", "Change focus areas?")
  /// 28px, Sora (EN) / Montserrat (RU), weight 600
  static TextStyle h2(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(28, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.ctaPrimary, // Warm brown for main titles
      letterSpacing: -0.5,
      height: _localizedHeight(1.25, locale),
    );
  }

  /// H3 - Smaller section headers
  /// 20px, Sora (EN) / Montserrat (RU), weight 600
  static TextStyle h3(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(20, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.textPrimary,
      height: _localizedHeight(1.3, locale),
    );
  }

  /// Category header - "BODY & MOVEMENT", "MIND & REFLECTION"
  /// 13px, Sora (EN) / Montserrat (RU), weight 600, UPPERCASE, letter-spacing 0.5
  static TextStyle categoryHeader(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(13, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.buttonDark, // Medium brown
      letterSpacing: 0.5,
    );
  }

  /// Section label - "PINNED", "SETTINGS", "SUPPORT"
  /// 13px, Sora (EN) / Montserrat (RU), weight 600, UPPERCASE
  static TextStyle sectionLabel(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(13, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.textDisabled,
      letterSpacing: 0.5,
    );
  }

  // ============================================================
  // BODY TEXT (Sora EN / Montserrat RU)
  // ============================================================

  /// Body Large - Habit card text, primary content
  /// 16px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle bodyLarge(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(16, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textPrimary, // Dark brown
      height: _localizedHeight(1.5, locale),
    );
  }

  /// Body - Descriptions, secondary text
  /// 15px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle body(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(15, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.ctaPrimary,
      height: _localizedHeight(1.5, locale),
    );
  }

  /// Subtitle - Below titles ("12 habits available")
  /// 15px, Sora (EN) / Montserrat (RU), weight 500, muted color
  static TextStyle subtitle(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(15, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textSecondary, // Muted brown
      height: _localizedHeight(1.5, locale),
    );
  }

  /// Body with custom color
  static TextStyle bodyColored(BuildContext context, Color color) {
    return body(context).copyWith(color: color);
  }

  /// Caption - Timestamps, metadata, hints
  /// 13px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle caption(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(13, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textDisabled,
      height: _localizedHeight(1.4, locale),
    );
  }

  /// Tiny text - Version numbers, fine print
  /// 12px, Sora (EN) / Montserrat (RU), weight 400
  static TextStyle tiny(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(12, locale)),
      fontWeight: FontWeight.w400,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textDisabled,
      height: _localizedHeight(1.4, locale),
    );
  }

  // ============================================================
  // BUTTONS (Sora EN / Montserrat RU)
  // ============================================================

  /// Primary button text
  /// 17px, Sora (EN) / Montserrat (RU), weight 600
  static TextStyle buttonPrimary(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(17, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.buttonText,
    );
  }

  /// Secondary/text button ("Close", "Cancel", "Skip")
  /// 16px, Sora (EN) / Montserrat (RU), weight 600
  static TextStyle buttonSecondary(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(16, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textSecondary, // Muted brown
    );
  }

  /// Link button (e.g., "Skip for now", "Not now")
  /// 16px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle buttonLink(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(16, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.ctaPrimary,
    );
  }

  // ============================================================
  // INPUTS (Sora EN / Montserrat RU)
  // ============================================================

  /// Input field text
  /// 15px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle input(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(15, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textPrimary, // Dark brown
    );
  }

  /// Input placeholder
  static TextStyle inputPlaceholder(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return input(context).copyWith(color: colors.textDisabled);
  }

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  /// Tagline text ("Small steps. No pressure.")
  /// 20px, Sora (EN) / Montserrat (RU), weight 500
  static TextStyle tagline(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(20, locale)),
      fontWeight: FontWeight.w500,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.ctaPrimary,
      height: _localizedHeight(1.4, locale),
    );
  }

  /// Date string (e.g., "Saturday, February 7")
  /// 15px, Sora (EN) / Montserrat (RU), weight 400
  static TextStyle dateLabel(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(15, locale)),
      fontWeight: FontWeight.w400,
      fontFamily: _bodyFontForLocale(locale),
      color: colors.textSecondary,
    );
  }

  /// Weekly summary large text
  /// 24px, Sora (EN) / Montserrat (RU) — it's a header — weight 600
  static TextStyle summaryLarge(BuildContext context) {
    final locale = _getLocale(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    return TextStyle(
      fontSize: Responsive.sp(_localizedSize(24, locale)),
      fontWeight: FontWeight.w600,
      fontFamily: displayFontFor(locale),
      color: colors.textPrimary,
      height: _localizedHeight(1.3, locale),
    );
  }
}

/// Helper extension for convenient style copying
extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle bold() => copyWith(fontWeight: FontWeight.w700);
  TextStyle semiBold() => copyWith(fontWeight: FontWeight.w600);
  TextStyle medium() => copyWith(fontWeight: FontWeight.w500);
}
