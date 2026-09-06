import 'package:cts/theme/cts_colors.dart';
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

/// Reusable sort dropdown — cream board hairline chrome.
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
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hairline),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: selectedValue ?? options.first.value,
            isExpanded: false,
            icon: Icon(Icons.arrow_drop_down, color: cts.navy),
            items: options.map((SortOption<T> option) {
              return DropdownMenuItem<T>(
                value: option.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(option.icon, size: 18, color: cts.navy),
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
                              color: cts.navy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (option.subLabel != null)
                            Text(
                              option.subLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cts.navy.withValues(alpha: 0.6),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          ? cts.navy
                          : cts.navy.withValues(alpha: 0.55),
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
                                    color: cts.navy,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  option.subLabel!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cts.navy.withValues(alpha: 0.6),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              option.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: cts.navy,
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
