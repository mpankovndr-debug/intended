import 'package:flutter_test/flutter_test.dart';
import 'package:intended/utils/text_styles.dart';

/// The page title's size by the arithmetic the styles use: 34pt, 8% off in
/// Russian, and scaled down with the screen as far as 85%.
double _title(double screenWidth, {required bool russian}) =>
    34 * (russian ? 0.92 : 1.0) * (screenWidth / 393).clamp(0.85, 1.0);

void main() {
  group("the season's word sits below the page title", () {
    test('30pt on a full-width screen, in both languages', () {
      expect(AppTextStyles.seasonWordSize(_title(393, russian: false)), 30);
      expect(AppTextStyles.seasonWordSize(_title(393, russian: true)), 30);
      expect(AppTextStyles.seasonWordSize(_title(440, russian: true)), 30);
    });

    test('English keeps its 30pt on a 375pt phone', () {
      expect(AppTextStyles.seasonWordSize(_title(375, russian: false)), 30);
    });

    test('Russian on a 375pt phone, where a fixed 30 stood over the title',
        () {
      final title = _title(375, russian: true);
      expect(title, lessThan(30));
      expect(AppTextStyles.seasonWordSize(title), lessThan(title));
    });

    test('never as big as the title, and never over 30', () {
      for (var title = 20.0; title <= 40; title += 0.05) {
        final word = AppTextStyles.seasonWordSize(title);
        expect(word, lessThan(title), reason: 'under a ${title}pt title');
        expect(word, lessThanOrEqualTo(30));
      }
    });
  });
}
