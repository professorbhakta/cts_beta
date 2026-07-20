import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/shared/widgets/quick_action_button.dart';
import 'package:cts/appManager/colors.dart';
import 'package:flutter/material.dart';

class AdminDashboardWireframe extends StatelessWidget {
  const AdminDashboardWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Admin dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WireframeBlock(label: 'Welcome + date', height: 56),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: WireframeBlock(label: 'Batches stat', height: 100),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: WireframeBlock(label: 'Commuters stat', height: 100),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: WireframeBlock(label: 'Routes', height: 72)),
                const SizedBox(width: 12),
                Expanded(child: WireframeBlock(label: 'POPs', height: 72)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: WireframeBlock(label: 'Cabs', height: 72)),
                const SizedBox(width: 12),
                Expanded(child: WireframeBlock(label: 'Drivers', height: 72)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add Batch',
                  onTap: () {},
                  color: AppColors.acYellowWarm,
                ),
                QuickActionButton(
                  icon: Icons.play_circle_outline,
                  label: 'Running',
                  onTap: () {},
                  color: AppColors.acYellowBright,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
