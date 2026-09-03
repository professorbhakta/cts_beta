import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

/// Quick action tile — hairline navy border, 4px radius.
/// Yellow fill only when [emphasized] (Add Batch).
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;

  /// Optional; quiet board is text-first (icons unused when null).
  final IconData? icon;

  /// Legacy accent; ignored when [emphasized] / hairline style applies.
  final Color? color;

  /// Solid yellow primary action (Add Batch only).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final bg = emphasized ? cts.yellow : theme.scaffoldBackgroundColor;
    final fg = cts.navy;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Ink(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: emphasized ? cts.yellow : hairline,
                  width: 1,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
