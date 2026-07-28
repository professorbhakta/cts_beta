import 'package:cts/design/wireframes/wireframe_primitives.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/common_text_formfield.dart';
import 'package:flutter/material.dart';

class AuthSignInWireframe extends StatelessWidget {
  const AuthSignInWireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return WireframeScreenScaffold(
      title: 'Sign in',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WireframeBlock(label: 'Logo / Welcome', height: 80),
            const SizedBox(height: 32),
            CommonTextFormField(
              hintText: 'Mobile (placeholder)',
              obscureText: false,
              onChange: (_) {},
            ),
            const SizedBox(height: 16),
            CommonTextFormField(
              hintText: 'Password (placeholder)',
              obscureText: true,
              onChange: (_) {},
            ),
            const SizedBox(height: 32),
            CommonPrimaryButton(
              label: 'LOGIN',
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            const Center(child: Text('Sign up link')),
          ],
        ),
      ),
    );
  }
}
