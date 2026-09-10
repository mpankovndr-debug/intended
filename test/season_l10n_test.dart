import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations_en.dart';
import 'package:intended/l10n/app_localizations_ru.dart';
import 'package:intended/utils/season_l10n.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // The app gets date symbols from flutter_localizations; a plain test has to
  // load them itself.
  setUpAll(initializeDateFormatting);

  test('the share subject names the month on the card, not a week', () {
    // It used to say "My week on Intended", in English, for every locale.
    expect(SeasonL10n.shareSubject(DateTime(2026, 9), AppLocalizationsEn()),
        'My September on Intended');
  });

  test('Russian names the month in the nominative, so «Мой» agrees', () {
    // All twelve, because the subject only reads if every month is masculine
    // nominative. yMMMM would append « г.»; a format with a day, «сентября».
    const nominative = [
      'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
      'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
    ];
    for (var m = 1; m <= 12; m++) {
      expect(SeasonL10n.shareSubject(DateTime(2026, m), AppLocalizationsRu()),
          'Мой ${nominative[m - 1]} в Intended');
    }
  });
}
