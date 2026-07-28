import 'package:cts/appManager/colors.dart';
import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';

class CrudListWireframe extends StatelessWidget {
  const CrudListWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Routes (list template)',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'All Routes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SearchBarWidget(
              hintText: 'Search…',
              onSearchChanged: (_) {},
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ModernListCard(
                    title: 'Route A',
                    subtitle: 'Swipe for edit / delete',
                    icon: Icons.route,
                    iconColor: AppColors.acYellowWarm,
                  ),
                  ModernListCard(
                    title: 'Route B',
                    subtitle: 'Example row',
                    icon: Icons.route,
                    iconColor: AppColors.acYellowWarm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
