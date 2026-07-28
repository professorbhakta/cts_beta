import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:flutter/material.dart';

class ProfileWireframe extends StatelessWidget {
  const ProfileWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 64)),
            const SizedBox(height: 24),
            const WireframeBlock(label: 'Name / mobile / role rows', height: 120),
            const SizedBox(height: 32),
            CommonPrimaryButton(
              label: 'Logout',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
