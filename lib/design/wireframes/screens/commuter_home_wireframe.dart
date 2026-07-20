import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:flutter/material.dart';

class CommuterHomeWireframe extends StatelessWidget {
  const CommuterHomeWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Commuter home',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, Commuter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: WireframeBlock(label: 'Today\'s date', height: 40),
                    ),
                    Switch(value: true, onChanged: (_) {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
