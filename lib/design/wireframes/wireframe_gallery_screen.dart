import 'package:cts/design/wireframes/wireframe_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Debug-only hub: preview layout patterns without login or API.
class WireframeGalleryScreen extends StatelessWidget {
  const WireframeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wireframes')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Wireframe gallery is only available in debug builds.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI wireframe gallery'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Placeholder layouts matching production screen patterns. '
            'See docs/FLOWS_BY_ROLE.md and docs/UI_ARCHITECTURE.md.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...WireframeCatalog.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(entry.title),
                subtitle: Text('${entry.role} · ${entry.subtitle}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/designWireframes/${entry.id}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class WireframeDetailScreen extends StatelessWidget {
  const WireframeDetailScreen({super.key, required this.wireframeId});

  final String wireframeId;

  @override
  Widget build(BuildContext context) {
    final entry = WireframeCatalog.byId(wireframeId);
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(child: Text('Unknown wireframe: $wireframeId')),
      );
    }
    return entry.builder();
  }
}
