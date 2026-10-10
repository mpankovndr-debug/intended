import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../models/action_cue.dart';
import '../services/action_cues.dart';

/// "after I pour my coffee": one quiet line under an action's title on
/// Today (spec §4), when the person tied that action to something they
/// already do. Nothing at all when they did not.
class CueLine extends StatefulWidget {
  const CueLine({super.key, required this.action, required this.style});

  /// The action's stored title, the key its cue is kept under.
  final String action;
  final TextStyle style;

  @override
  State<CueLine> createState() => _CueLineState();
}

class _CueLineState extends State<CueLine> {
  ActionCue? _cue;

  @override
  void initState() {
    super.initState();
    ActionCues.changes.addListener(_read);
    _read();
  }

  @override
  void didUpdateWidget(CueLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action != widget.action) _read();
  }

  @override
  void dispose() {
    ActionCues.changes.removeListener(_read);
    super.dispose();
  }

  Future<void> _read() async {
    final action = widget.action;
    final cue = (await ActionCues.read())[action];
    if (!mounted || action != widget.action) return;
    if (cue != _cue) setState(() => _cue = cue);
  }

  @override
  Widget build(BuildContext context) {
    final cue = _cue;
    if (cue == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        l10n.todayCueLine(cue.label(l10n)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.style,
      ),
    );
  }
}
