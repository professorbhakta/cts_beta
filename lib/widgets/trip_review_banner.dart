import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

/// In-app Path A banner (no FCM): trips need end_km / close attention.
class TripReviewBanner extends StatelessWidget {
  const TripReviewBanner({
    super.key,
    required this.message,
    this.onTap,
    this.actionLabel = 'Review',
  });

  final String message;
  final VoidCallback? onTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return Material(
      color: cts.orangeSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cts.navy, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onTap != null)
                TextButton(
                  onPressed: onTap,
                  child: Text(actionLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
