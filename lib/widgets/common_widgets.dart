// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Document Format Badge
// ---------------------------------------------------------------------------
class FormatBadge extends StatelessWidget {
  final DocumentFormat format;
  final bool compact;

  const FormatBadge({super.key, required this.format, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: format.bgColor,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        format.label,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: format.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document Card (History list item)
// ---------------------------------------------------------------------------
class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.9,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
          ),
        ),
        child: Row(
          children: [
            // Format icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: document.format.bgColor,
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                document.format.icon,
                color: document.format.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Name & metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      FormatBadge(format: document.format, compact: true),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(document.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (document.wordCount != null) ...[
                        Text(
                          ' · ${document.wordCount} words',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
              elevation: 4,
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'open',
                  child: _MenuOption(Icons.open_in_new_rounded, 'Open'),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: _MenuOption(Icons.share_rounded, 'Share'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: _MenuOption(
                    Icons.delete_outline_rounded,
                    'Delete',
                    color: AppColors.error,
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    onTap?.call();
                  case 'share':
                    onShare?.call();
                  case 'delete':
                    onDelete?.call();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuOption(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 10),
        Text(label,
            style:
                TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Button (Home screen)
// ---------------------------------------------------------------------------
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? color : theme.cardTheme.color,
          borderRadius: AppRadius.borderXl,
          border: isPrimary
              ? null
              : Border.all(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkSurface3
                      : AppColors.neutral200,
                ),
          boxShadow: isPrimary ? AppShadows.primary : AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.12),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : color,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isPrimary ? Colors.white : null,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPrimary
                    ? Colors.white.withOpacity(0.75)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Chip
// ---------------------------------------------------------------------------
class StatChip extends StatelessWidget {
  final String label;
  final String value;

  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : Colors.white,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading Dots Animation
// ---------------------------------------------------------------------------
class LoadingDots extends StatefulWidget {
  final Color? color;
  final double size;

  const LoadingDots({super.key, this.color, this.size = 8});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = ((_controller.value - i * 0.15) % 1.0);
            final scale = t < 0.3
                ? 1.0 + (t / 0.3) * 0.5
                : t < 0.6
                    ? 1.5 - ((t - 0.3) / 0.3) * 0.5
                    : 1.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              child: Transform.scale(
                scale: scale.clamp(1.0, 1.5),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color.withAlpha((255 * (0.3 + scale * 0.3)).round()),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Forge App Bar (reusable)
// ---------------------------------------------------------------------------
class ForgeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBorder;

  const ForgeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBorder = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      bottom: showBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Forge Search Bar
// ---------------------------------------------------------------------------
class ForgeSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const ForgeSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Search documents…',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Onboarding Feature Item
// ---------------------------------------------------------------------------
class OnboardingFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingFeatureRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Format Selection Card (Export screen)
// ---------------------------------------------------------------------------
class FormatCard extends StatelessWidget {
  final DocumentFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const FormatCard({
    super.key,
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E1B4B) : AppColors.primaryContainer)
              : (isDark ? AppColors.darkSurface2 : Colors.white),
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkSurface3 : AppColors.neutral200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : AppShadows.xs,
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: format.bgColor,
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(format.icon, color: format.color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              format.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? AppColors.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              format.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkSurface3 : AppColors.neutral300,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Tile
// ---------------------------------------------------------------------------
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Group / Card
// ---------------------------------------------------------------------------
class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                title!.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : Colors.white,
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      indent: 68,
                      height: 1,
                      color: isDark
                          ? AppColors.darkSurface3
                          : AppColors.neutral100,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
