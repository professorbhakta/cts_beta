import 'package:flutter/material.dart';

/// Sort option model
class SortOption<T> {
  final String label;
  final String? subLabel; // For A-Z, Z-A, 0-9, 9-0 indicators
  final T value;
  final IconData? icon;

  const SortOption({
    required this.label,
    this.subLabel,
    required this.value,
    this.icon,
  });

  @override
  String toString() => label;
}

/// Reusable sort dropdown widget
///
/// This widget displays a dropdown button next to search bars
/// that allows users to select how to sort the data.
class SortDropdownWidget<T> extends StatelessWidget {
  final String? hintText;
  final List<SortOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSortChanged;
  final IconData icon;
  final String tooltip;

  const SortDropdownWidget({
    super.key,
    this.hintText,
    required this.options,
    this.selectedValue,
    required this.onSortChanged,
    this.icon = Icons.sort,
    this.tooltip = 'Sort by',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: selectedValue ?? options.first.value,
            isExpanded: false,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            items: options.map((SortOption<T> option) {
              return DropdownMenuItem<T>(
                value: option.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(option.icon, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (option.subLabel != null)
                            Text(
                              option.subLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (T? newValue) {
              if (newValue != null) {
                onSortChanged(newValue);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            selectedItemBuilder: (BuildContext context) {
              return options.map((SortOption<T> option) {
                final isSelected = option.value == selectedValue;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: option.subLabel != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.label,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.grey[800],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  option.subLabel!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              option.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.grey[800],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
