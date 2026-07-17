import 'package:flutter/material.dart';

Future<String?> showOfflineTextDialog(
  BuildContext context, {
  required String title,
  required String labelText,
  String? hintText,
  String initialValue = '',
  required String? Function(String?) validator,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
}) async {
  final controller = TextEditingController(text: initialValue);
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
          ),
          validator: validator,
          onFieldSubmitted: (_) {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, true);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, true);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (saved != true) return null;
  return controller.text.trim();
}
