import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

/// Quiet overview stat tile — number + label + subtitle, hairline border.
/// No colored icons (admin dashboard mock).
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String title;
  final String value;
  final VoidCallback onTap;
  final String? subtitle;

  /// Unused on the quiet board; kept for call-site compatibility.
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _QuietOverviewTile(
      title: title,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

/// Compact overview tile — same quiet visual language as [DashboardStatCard].
class CompactStatCard extends StatelessWidget {
  const CompactStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String title;
  final String value;
  final VoidCallback onTap;
  final String? subtitle;

  /// Unused on the quiet board; kept for call-site compatibility.
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _QuietOverviewTile(
      title: title,
      value: value,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _QuietOverviewTile extends StatelessWidget {
  const _QuietOverviewTile({
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
