import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart' show showIntendedModal, AppBackground;
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class _FaqItem {
  final String Function(AppLocalizations) question;
  final String Function(AppLocalizations) answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqCategory {
  final String Function(AppLocalizations) title;
  final IconData icon;
  final List<_FaqItem> items;
  const _FaqCategory({
    required this.title,
    required this.icon,
    required this.items,
  });
}

List<_FaqCategory> _buildCategories() => [
      _FaqCategory(
        title: (l) => l.faqSectionGettingStarted,
        icon: CupertinoIcons.lightbulb_fill,
        items: [
          _FaqItem(question: (l) => l.faqWhatIsIntended,      answer: (l) => l.faqWhatIsIntendedAnswer),
          _FaqItem(question: (l) => l.faqWhatIsIntentionPath,  answer: (l) => l.faqWhatIsIntentionPathAnswer),
          _FaqItem(question: (l) => l.faqChangeIntentionPath,  answer: (l) => l.faqChangeIntentionPathAnswer),
          _FaqItem(question: (l) => l.faqWhatAreFocusAreas,   answer: (l) => l.faqWhatAreFocusAreasAnswer),
          _FaqItem(question: (l) => l.faqHowIsDifferent,      answer: (l) => l.faqHowIsDifferentAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionDailyHabits,
        icon: CupertinoIcons.checkmark_circle_fill,
        items: [
          _FaqItem(question: (l) => l.faqHowToCheckIn,  answer: (l) => l.faqHowToCheckInAnswer),
          _FaqItem(question: (l) => l.faqMissedDay,     answer: (l) => l.faqMissedDayAnswer),
          _FaqItem(question: (l) => l.faqHowToPin,      answer: (l) => l.faqHowToPinAnswer),
          _FaqItem(question: (l) => l.faqCustomHabits,  answer: (l) => l.faqCustomHabitsAnswer),
          _FaqItem(question: (l) => l.faqSwapHabit,     answer: (l) => l.faqSwapHabitAnswer),
          _FaqItem(question: (l) => l.faqRefreshes,     answer: (l) => l.faqRefreshesAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionReflections,
        icon: CupertinoIcons.waveform,
        items: [
          _FaqItem(question: (l) => l.faqWeeklyReflection,  answer: (l) => l.faqWeeklyReflectionAnswer),
          _FaqItem(question: (l) => l.faqMonthlyReflection, answer: (l) => l.faqMonthlyReflectionAnswer),
          _FaqItem(question: (l) => l.faqShareReflection,   answer: (l) => l.faqShareReflectionAnswer),
          _FaqItem(question: (l) => l.faqNoReflection,      answer: (l) => l.faqNoReflectionAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionNotifications,
        icon: CupertinoIcons.bell_fill,
        items: [
          _FaqItem(question: (l) => l.faqHowNotifications,   answer: (l) => l.faqHowNotificationsAnswer),
          _FaqItem(question: (l) => l.faqChangeTime,         answer: (l) => l.faqChangeTimeAnswer),
          _FaqItem(question: (l) => l.faqPathNotifications,  answer: (l) => l.faqPathNotificationsAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionWidgets,
        icon: CupertinoIcons.rectangle_on_rectangle,
        items: [
          _FaqItem(question: (l) => l.faqAddWidget,          answer: (l) => l.faqAddWidgetAnswer),
          _FaqItem(question: (l) => l.faqWidgetNotUpdating,  answer: (l) => l.faqWidgetNotUpdatingAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionPricing,
        icon: CupertinoIcons.star_fill,
        items: [
          _FaqItem(question: (l) => l.faqWhatIsPlus,    answer: (l) => l.faqWhatIsPlusAnswer),
          _FaqItem(question: (l) => l.faqPricing,       answer: (l) => l.faqPricingAnswer),
          _FaqItem(question: (l) => l.faqBoost,         answer: (l) => l.faqBoostAnswer),
          _FaqItem(question: (l) => l.faqFreeVersion,   answer: (l) => l.faqFreeVersionAnswer),
          _FaqItem(question: (l) => l.faqRestore,       answer: (l) => l.faqRestoreAnswer),
          _FaqItem(question: (l) => l.faqCancel,        answer: (l) => l.faqCancelAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionPrivacy,
        icon: CupertinoIcons.lock_fill,
        items: [
          _FaqItem(question: (l) => l.faqDataStorage,  answer: (l) => l.faqDataStorageAnswer),
          _FaqItem(question: (l) => l.faqDataSelling,  answer: (l) => l.faqDataSellingAnswer),
          _FaqItem(question: (l) => l.faqDeleteApp,    answer: (l) => l.faqDeleteAppAnswer),
        ],
      ),
      _FaqCategory(
        title: (l) => l.faqSectionTroubleshooting,
        icon: CupertinoIcons.wrench_fill,
        items: [
          _FaqItem(question: (l) => l.faqCrash,       answer: (l) => l.faqCrashAnswer),
          _FaqItem(question: (l) => l.faqHabitsGone,  answer: (l) => l.faqHabitsGoneAnswer),
          _FaqItem(question: (l) => l.faqAppleName,   answer: (l) => l.faqAppleNameAnswer),
        ],
      ),
    ];

// ─── Level 1: Category Grid ───────────────────────────────────────────────────

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  Future<void> _contactSupport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@intendedapp.com',
      query: 'subject=Intended App — Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
        showIntendedModal(
          context: context,
          title: l10n.profileCannotOpenEmail,
          subtitle: l10n.profileEmailFallback,
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.ctaPrimary.withOpacity(0.85),
                          colors.ctaSecondary.withOpacity(0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colors.ctaPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      borderRadius: BorderRadius.circular(24),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.commonOk,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeP = Provider.of<ThemeProvider>(context);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final categories = _buildCategories();
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(8, topPadding + 16, 24, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        color: colors.ctaPrimary,
                        size: 22,
                      ),
                    ),
                    Text(
                      l10n.profileHelpSupport,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid + footer
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _CategoryCard(
                            category: categories[index],
                            colors: colors,
                            isDark: isDark,
                            l10n: l10n,
                            onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => _FaqCategoryScreen(
                                  category: categories[index],
                                ),
                              ),
                            ),
                          ),
                          childCount: categories.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.05,
                        ),
                      ),
                    ),
                    // Footer spans full width below the grid
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                        child: _ContactFooter(
                          l10n: l10n,
                          colors: colors,
                          onContact: () => _contactSupport(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category card ────────────────────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final _FaqCategory category;
  final AppColorScheme colors;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.colors,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scale.reverse().then((_) {
      _scale.forward();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.profileCard
                      .withOpacity(colors.profileCardOpacity),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isDark
                        ? colors.borderCard
                            .withOpacity(colors.borderCardOpacity)
                        : const Color(0xFFFFFFFF).withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.accentRegular.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.category.icon,
                        size: 22,
                        color: colors.accentMuted,
                      ),
                    ),
                    const Spacer(),
                    // Category title
                    Text(
                      widget.category.title(widget.l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Question count hint
                    Text(
                      '${widget.category.items.length} questions',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Level 2: Category question list ─────────────────────────────────────────

class _FaqCategoryScreen extends StatefulWidget {
  final _FaqCategory category;

  const _FaqCategoryScreen({super.key, required this.category});

  @override
  State<_FaqCategoryScreen> createState() => _FaqCategoryScreenState();
}

class _FaqCategoryScreenState extends State<_FaqCategoryScreen> {
  int? _expandedIndex;

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeP = Provider.of<ThemeProvider>(context);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(8, topPadding + 16, 24, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        color: colors.ctaPrimary,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.category.title(l10n),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Question list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 48),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colors.profileCard
                            .withOpacity(colors.profileCardOpacity),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard
                                  .withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          for (int i = 0;
                              i < widget.category.items.length;
                              i++) ...[
                            if (i > 0)
                              Container(
                                height: 1,
                                color: colors.ctaPrimary.withOpacity(0.1),
                              ),
                            _FaqItemWidget(
                              item: widget.category.items[i],
                              isExpanded: _expandedIndex == i,
                              isLastInSection:
                                  i == widget.category.items.length - 1,
                              onTap: () => _toggle(i),
                              colors: colors,
                              l10n: l10n,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Accordion row ────────────────────────────────────────────────────────────

class _FaqItemWidget extends StatelessWidget {
  final _FaqItem item;
  final bool isExpanded;
  final bool isLastInSection;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final AppLocalizations l10n;

  const _FaqItemWidget({
    required this.item,
    required this.isExpanded,
    required this.isLastInSection,
    required this.onTap,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question row
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question(l10n),
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 20,
                      color: colors.ctaPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer area
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.ctaPrimary.withOpacity(0.06),
                      borderRadius: isLastInSection
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )
                          : BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      item.answer(l10n),
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Contact footer ───────────────────────────────────────────────────────────

class _ContactFooter extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColorScheme colors;
  final VoidCallback onContact;

  const _ContactFooter({
    required this.l10n,
    required this.colors,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    // Footer spans the full grid width — use a layout trick to double the
    // column width by wrapping in a GridView single-item span isn't supported
    // in GridView.builder, so we use a visual-only footer widget with no
    // intrinsic height constraint (GridView will size it per childAspectRatio).
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.faqStillHaveQuestion,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onContact,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.ctaPrimary.withOpacity(0.6),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.faqContactButton,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.ctaPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
