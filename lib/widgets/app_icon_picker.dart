import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/app_icon_service.dart';

/// Describes an icon entry for the picker.
typedef _IconEntry = ({
  AppIcon icon,
  String Function(AppLocalizations) name,
  Color previewBg,
  Color previewAccent,
  String? assetPath,
  bool isPremium,
});

/// Horizontal icon picker for the appearance sheet.
/// Shows rounded-rectangle icon previews; locked variants show a lock badge.
class AppIconPicker extends StatefulWidget {
  final bool isPremium;
  final VoidCallback onPremiumTap;

  const AppIconPicker({
    super.key,
    required this.isPremium,
    required this.onPremiumTap,
  });

  @override
  State<AppIconPicker> createState() => _AppIconPickerState();
}

class _AppIconPickerState extends State<AppIconPicker> {
  AppIcon _current = AppIcon.defaultIcon;

  static final List<_IconEntry> _icons = [
    (
      icon: AppIcon.defaultIcon,
      name: (l10n) => l10n.appIconDefault,
      previewBg: const Color(0xFFF2D4B0),
      previewAccent: const Color(0xFF7A6A58),
      assetPath: 'assets/images/intended_icon.png',
      isPremium: false,
    ),
    (
      icon: AppIcon.midnight,
      name: (l10n) => l10n.appIconMidnight,
      previewBg: const Color(0xFF2D2D35),
      previewAccent: const Color(0xFF9B8BB4),
      assetPath: 'assets/images/intended_icon_midnight.png',
      isPremium: true,
    ),
    (
      icon: AppIcon.rose,
      name: (l10n) => l10n.appIconRose,
      previewBg: const Color(0xFFF0C0C2),
      previewAccent: const Color(0xFFB5676A),
      assetPath: 'assets/images/intended_icon_rose.png',
      isPremium: true,
    ),
    (
      icon: AppIcon.forest,
      name: (l10n) => l10n.appIconForest,
      previewBg: const Color(0xFFD5E2D0),
      previewAccent: const Color(0xFF6B8F6B),
      assetPath: 'assets/images/intended_icon_forest.png',
      isPremium: true,
    ),
    (
      icon: AppIcon.sky,
      name: (l10n) => l10n.appIconSky,
      previewBg: const Color(0xFFC8D8E8),
      previewAccent: const Color(0xFF4A6E96),
      assetPath: 'assets/images/intended_icon_sky.png',
      isPremium: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final current = await AppIconService.getCurrent();
    if (mounted) setState(() => _current = current);
  }

  Future<void> _selectIcon(_IconEntry entry) async {
    if (entry.isPremium && !widget.isPremium) {
      widget.onPremiumTap();
      return;
    }
    HapticFeedback.lightImpact();
    final success = await AppIconService.setIcon(entry.icon);
    if (success && mounted) {
      setState(() => _current = entry.icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.appIconSectionTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.35),
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildIconCard(_icons[index], l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildIconCard(_IconEntry entry, AppLocalizations l10n) {
    final isSelected = _current == entry.icon;
    final isLocked = entry.isPremium && !widget.isPremium;

    return GestureDetector(
      onTap: () => _selectIcon(entry),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            // Icon preview
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: entry.previewBg,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: entry.previewAccent, width: 2.5)
                    : Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Icon preview image
                  if (entry.assetPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(isSelected ? 11.5 : 13),
                      child: Image.asset(
                        entry.assetPath!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entry.previewAccent.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  // Lock badge
                  if (isLocked)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 9,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Name
            Text(
              entry.name(l10n),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isLocked
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
