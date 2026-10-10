import 'package:flutter/cupertino.dart';

import '../utils/text_styles.dart';

/// The app-wide default text style, chosen where the locale is known.
///
/// Whatever names no family of its own — a bare `Text`, a button label, a
/// text field — draws in this. It used to be Sora for everyone, set on
/// `CupertinoApp.theme`. Sora has no Cyrillic, so in Russian every such
/// string fell to the platform's fallback face (see
/// `AppTextStyles.displayFontFor`): the theme names and the app-icon labels
/// in the pickers, sitting among text that was otherwise all Montserrat.
///
/// `CupertinoApp.theme` is read above `Localizations` and cannot see the
/// resolved locale. `CupertinoApp.builder` runs below it and above the
/// Navigator, so this goes there and every route inherits it — pages,
/// sheets and dialogs alike.
class LocaleTextTheme extends StatelessWidget {
  const LocaleTextTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.defaultTextStyleFor(
        Localizations.localeOf(context).toString());
    final theme = CupertinoTheme.of(context);
    // Both, because the default reaches text by two roads: `Text` reads the
    // ambient DefaultTextStyle, Cupertino buttons and fields read the theme.
    return CupertinoTheme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(textStyle: style),
      ),
      child: DefaultTextStyle(style: style, child: child),
    );
  }
}
