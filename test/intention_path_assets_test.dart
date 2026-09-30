import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/intention_path.dart';

/// Two paths once pointed at icon files that did not exist, and the other
/// five at the same grey placeholder. Nothing drew them, so nothing noticed.
/// The direction picker draws every one.
void main() {
  final paths = IntentionPathId.values.map(IntentionPath.getById).toList();

  test('every path glyph exists on disk', () {
    for (final path in paths) {
      expect(File(path.iconAsset).existsSync(), isTrue,
          reason: '${path.id.key} -> ${path.iconAsset}');
    }
  });

  test('every path glyph sits in a folder the app bundles', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final path in paths) {
      final folder = path.iconAsset.substring(
        0,
        path.iconAsset.lastIndexOf('/') + 1,
      );
      expect(pubspec, contains('- $folder'),
          reason: '${path.id.key} -> ${path.iconAsset}');
    }
  });

  test('no two paths share a glyph', () {
    final assets = paths.map((p) => p.iconAsset).toList();
    expect(assets.toSet(), hasLength(assets.length));
  });
}
