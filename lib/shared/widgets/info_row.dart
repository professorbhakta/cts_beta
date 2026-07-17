import 'package:flutter/material.dart';

/// A reusable widget for displaying information with an icon, label, and value
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconSize = 18,
    this.showColon = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final double iconSize;
  final bool showColon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText = showColon ? '$label: ' : label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          if (showColon)
            Text(
              labelText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          Expanded(
            child: Text(
              showColon ? value : '$labelText $value',
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}


