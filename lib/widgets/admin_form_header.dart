import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

/// Shared gradient header for admin create/edit forms.
class AdminFormHeader extends StatelessWidget {
  const AdminFormHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final texts = context.texts;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            cts.yellowBright,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: scheme.surface, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: texts.titleLarge?.copyWith(
                color: scheme.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom inset so center-float FABs do not cover list content.
double d2dFabScrollPadding(BuildContext context) {
  return MediaQuery.paddingOf(context).bottom + 88;
}
