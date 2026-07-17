import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';

class SpecialModelForm extends StatelessWidget {
  const SpecialModelForm({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DashboardShell(
      title: 'Special Model',
      child: StatusMessage(
        icon: Icons.construction_outlined,
        title: 'Not available',
        message: 'This form is not yet implemented.',
        color: scheme.outline,
      ),
    );
  }
}
