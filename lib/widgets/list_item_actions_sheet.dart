import 'package:cts/appManager/colors.dart';
import 'package:flutter/material.dart';

/// Bottom sheet shown on long-press for edit/delete actions on list cards.
class ListItemActionsSheet {
  ListItemActionsSheet._();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.acYellowWarm),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetContext);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.acRed),
              title: Text(
                'Delete',
                style: TextStyle(color: AppColors.acRed),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
