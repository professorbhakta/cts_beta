import 'package:cts/appManager/colors.dart';
import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:flutter/material.dart';

class DriverHomeWireframe extends StatelessWidget {
  const DriverHomeWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Driver home',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppColors.acBlackLight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WireframeBlock(label: 'Date + call admin', height: 40),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: WireframeBlock(label: 'Batch', height: 48)),
                        const SizedBox(width: 8),
                        Expanded(child: WireframeBlock(label: 'Time', height: 48)),
                        const SizedBox(width: 8),
                        Expanded(child: WireframeBlock(label: 'Cab', height: 48)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            CommonPrimaryButton(
              label: 'START TRIP',
              width: 240,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
