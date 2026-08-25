import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'analytics_service.dart';

class ShareService {
  static Future<void> shareCard(
    GlobalKey repaintKey, {
    required Rect sharePositionOrigin,
    String surface = 'season_card',
  }) async {
    final context = repaintKey.currentContext;
    if (context == null) throw Exception('Widget not mounted');

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception('Could not capture image');
    }

    final image = await renderObject.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) throw Exception('Could not encode image');

    final pngBytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/intended_share_card.png');
    await file.writeAsBytes(pngBytes);

    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My week on Intended',
      sharePositionOrigin: sharePositionOrigin,
    );
    // The sheet opening and the user actually posting are different funnels.
    AnalyticsService.logShareResult(surface, result.status.name);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
