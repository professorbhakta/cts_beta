import 'package:flutter/material.dart';

/// Muted placeholder blocks for design-review layouts (no API).
class WireframeBlock extends StatelessWidget {
  const WireframeBlock({
    super.key,
    required this.label,
    this.height,
    this.width,
    this.child,
  });

  final String label;
  final double? height;
  final double? width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: child ??
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
    );
  }
}

class WireframeScreenScaffold extends StatelessWidget {
  const WireframeScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title (wireframe)'),
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
