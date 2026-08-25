/// Focus-area → header glyph, one soft illustration per bounded category.
///
/// Per-category, never per-intention: users write their own intentions, so
/// that set is unbounded and can't be illustrated. The categories are the
/// same eight storage keys `CategoryColors` reads, so the glyph and the grid
/// tile always agree about what an intention is. Anything unmapped — customs
/// with no focus area, or a key from a future version — gets the star.
class CategoryGlyphs {
  static const String _fallback = 'assets/glyphs/custom_star.png';

  static const Map<String, String> _byCategory = {
    'Health': 'assets/glyphs/health_heart.png',
    'Self-care': 'assets/glyphs/selfcare_mug.png',
    'Mood': 'assets/glyphs/mood_flower.png',
    'Doing one thing': 'assets/glyphs/productivity_plane.png',
    'Home & organization': 'assets/glyphs/home_house.png',
    'Relationships': 'assets/glyphs/relationships_hearts.png',
    'Creativity': 'assets/glyphs/creativity_brush.png',
    'Finances': 'assets/glyphs/finances_coin.png',
  };

  static String of(String? category) => _byCategory[category] ?? _fallback;
}
