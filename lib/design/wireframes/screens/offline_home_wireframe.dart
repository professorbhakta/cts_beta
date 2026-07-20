import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:flutter/material.dart';

class OfflineHomeWireframe extends StatelessWidget {
  const OfflineHomeWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Offline mode',
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: WireframeBlock(
          label: 'Tab content: Routes / Batches / Commuters / Output',
          height: 320,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          NavigationDestination(icon: Icon(Icons.route), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.directions_bus), label: 'Batches'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Commuters'),
          NavigationDestination(icon: Icon(Icons.output), label: 'Output'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
