import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/shared/widgets/admin_form_header.dart';
import 'package:cts/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';

class CrudFormWireframe extends StatelessWidget {
  const CrudFormWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Create route',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminFormHeader(
              icon: Icons.route_rounded,
              title: 'Create new route',
            ),
            const SizedBox(height: 24),
            const WireframeBlock(
              label: 'Route name field',
              height: 56,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonPrimaryButton(
                    label: 'Save',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
