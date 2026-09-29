import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/chapter.dart';
import 'package:intended/services/chapter_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// At most one chapter is open, and it ends only with the person's answer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('nothing stored: no chapters, none open', () async {
    expect(await ChapterService.all(), isEmpty);
    expect(await ChapterService.current(), isNull);
  });

  test('a started chapter is the open one, and is stored', () async {
    final started = await ChapterService.start(
      sentence: 'let the day go before I sleep',
      pathKey: 'windingDown',
      now: DateTime(2026, 9, 29, 20),
    );
    final current = await ChapterService.current();
    expect(current, isNotNull);
    expect(current!.id, started.id);
    expect(current.sentence, 'let the day go before I sleep');
    expect(current.endMonthKey, '2026-12');
  });

  test('a second chapter cannot start while one is open', () async {
    await ChapterService.start(sentence: 'a', pathKey: 'p');
    expect(
      () => ChapterService.start(sentence: 'b', pathKey: 'p'),
      throwsStateError,
    );
    expect(await ChapterService.all(), hasLength(1));
  });

  test('the open sentence can be edited, and the edit is what reads back',
      () async {
    await ChapterService.start(sentence: 'sleep earlier', pathKey: 'p');
    await ChapterService.updateSentence('stop fighting my sleep');
    expect(
        (await ChapterService.current())!.sentence, 'stop fighting my sleep');
  });

  test('closing keeps the answer and the note, then a new one can start',
      () async {
    await ChapterService.start(
      sentence: 'let the day go',
      pathKey: 'windingDown',
      now: DateTime(2026, 9, 29, 20),
    );
    await ChapterService.closeCurrent(
      answer: ChapterAnswer.partOfMe,
      note: '  The breathing stuck.  ',
      now: DateTime.utc(2027, 1, 1, 9),
    );
    expect(await ChapterService.current(), isNull);

    await ChapterService.start(
      sentence: 'let the day go',
      pathKey: 'windingDown',
      now: DateTime(2027, 1, 1, 10),
    );
    final all = await ChapterService.all();
    expect(all, hasLength(2));
    expect(all.first.close!.answer, ChapterAnswer.partOfMe);
    expect(all.first.close!.note, 'The breathing stuck.');
    expect(all.last.isClosed, isFalse);
  });

  test('an empty note is no note', () async {
    await ChapterService.start(sentence: 'a', pathKey: 'p');
    final closed = await ChapterService.closeCurrent(
      answer: ChapterAnswer.somethingElse,
      note: '   ',
    );
    expect(closed.close!.note, isNull);
  });

  test('editing or closing with nothing open is an error, not a no-op',
      () async {
    expect(() => ChapterService.updateSentence('x'), throwsStateError);
    expect(
      () => ChapterService.closeCurrent(answer: ChapterAnswer.keepGoing),
      throwsStateError,
    );
  });

  test('a corrupted store reads as empty instead of crashing', () async {
    SharedPreferences.setMockInitialValues({'chapters': '{not json'});
    expect(await ChapterService.all(), isEmpty);
  });

  test('one unreadable record is dropped; the rest survive', () async {
    await ChapterService.start(sentence: 'a', pathKey: 'p');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chapters')!;
    await prefs.setString('chapters', '[{"id":"broken"},${raw.substring(1)}');
    final all = await ChapterService.all();
    expect(all, hasLength(1));
    expect(all.single.sentence, 'a');
  });
}
