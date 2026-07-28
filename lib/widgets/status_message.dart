import 'package:flutter/material.dart';
import 'package:cts/api/api_result.dart';

/// A reusable widget for displaying status messages (error, empty, info states)
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
    this.color,
    this.iconSize = 64,
    this.errorType,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Factory constructor for empty states with action button
  factory StatusMessage.empty({
    required String title,
    String? message,
    required String actionLabel,
    required VoidCallback onAction,
    IconData? icon,
    Color? color,
  }) {
    return StatusMessage(
      icon: icon ?? Icons.inbox_outlined,
      title: title,
      message: message,
      onAction: onAction,
      actionLabel: actionLabel,
      color: color,
    );
  }

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final Color? color;
  final double iconSize;
  final ApiFailureType? errorType;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Factory constructor for error messages with automatic icon selection
  factory StatusMessage.error({
    required String title,
    String? message,
    VoidCallback? onRetry,
    ApiFailureType? errorType,
    Color? color,
  }) {
    return StatusMessage(
      icon: _iconForErrorType(errorType),
      title: title,
      message: message,
      onRetry: onRetry,
      color: color,
      errorType: errorType,
    );
  }

  static IconData _iconForErrorType(ApiFailureType? errorType) {
    switch (errorType) {
      case ApiFailureType.network:
        return Icons.wifi_off;
      case ApiFailureType.timeout:
        return Icons.timer_off;
      case ApiFailureType.unauthorized:
        return Icons.lock_outline;
      case ApiFailureType.server:
        return Icons.cloud_off;
      case ApiFailureType.invalidRequest:
        return Icons.error_outline;
      case ApiFailureType.parsing:
        return Icons.broken_image;
      case ApiFailureType.cancelled:
        return Icons.cancel_outlined;
      case ApiFailureType.unexpected:
      case null:
        return Icons.error_outline;
    }
  }

  Color _resolveColor(ColorScheme scheme) {
    if (color != null) return color!;
    switch (errorType) {
      case ApiFailureType.network:
      case ApiFailureType.timeout:
      case ApiFailureType.invalidRequest:
      case ApiFailureType.parsing:
        return scheme.tertiary;
      case ApiFailureType.unauthorized:
      case ApiFailureType.server:
      case ApiFailureType.unexpected:
        return scheme.error;
      case ApiFailureType.cancelled:
        return scheme.onSurface.withValues(alpha: 0.5);
      case null:
        return scheme.onSurface.withValues(alpha: 0.38);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final effectiveColor = _resolveColor(scheme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: effectiveColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color ?? scheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
