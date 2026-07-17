import 'package:cts/shared/widgets/search_bar_widget.dart';
import 'package:cts/shared/widgets/sort_dropdown_widget.dart';
import 'package:flutter/material.dart';

/// Shared search + sort toolbar for admin CRUD list screens.
class AdminSearchSortRow<T> extends StatelessWidget {
  const AdminSearchSortRow({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    required this.sortOptions,
    required this.selectedSort,
    required this.onSortChanged,
    required this.sortTooltip,
  });

  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final List<SortOption<T>> sortOptions;
  final T selectedSort;
  final ValueChanged<T> onSortChanged;
  final String sortTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            hintText: hintText,
            onSearchChanged: onSearchChanged,
          ),
        ),
        SortDropdownWidget<T>(
          options: sortOptions,
          selectedValue: selectedSort,
          onSortChanged: onSortChanged,
          icon: Icons.sort,
          tooltip: sortTooltip,
        ),
      ],
    );
  }
}
