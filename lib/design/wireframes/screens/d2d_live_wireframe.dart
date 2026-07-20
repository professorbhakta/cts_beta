import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:flutter/material.dart';

class D2dLiveWireframe extends StatelessWidget {
  const D2dLiveWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'D2D live',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WireframeBlock(label: 'Batch / trip header', height: 64),
          const SizedBox(height: 16),
          for (var i = 1; i <= 4; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WireframeBlock(
                label: 'Commuter row $i — swipe actions, call',
                height: 72,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Stop / Close'),
      ),
    );
  }
}
