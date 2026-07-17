import 'package:cts/appManager/colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

/// A reusable searchable dropdown widget that matches the form styling
class SearchableDropdown<T> extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.icon,
    this.itemAsString,
    this.filterFn,
    this.compareFn,
    this.isLoading = false,
    this.errorMessage,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;
  final String Function(T)? itemAsString;
  final bool Function(T, String)? filterFn;
  final bool Function(T, T)? compareFn;
  final bool isLoading;
  final String? errorMessage;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading state
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.acYellowWarm.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.acWhite,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.acRed,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.acWhite,
        ),
        child: Text(
          'Error: $errorMessage',
          style: TextStyle(color: AppColors.acRed),
        ),
      );
    }

    return DropdownSearch<T>(
      selectedItem: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      enabled: enabled,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search $label...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.acYellowWarm,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.acWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        menuProps: MenuProps(
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
        ),
        itemBuilder: (context, item, isSelected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.acYellowWarm.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.acYellowWarm,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemAsString?.call(item) ?? item.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.acYellowWarm
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: theme.textTheme.bodyLarge,
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: AppColors.acYellowWarm,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.acYellowWarm.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.acYellowWarm.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.acYellowWarm,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.acRed,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.acRed,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.acWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      itemAsString: itemAsString,
      filterFn: filterFn,
      compareFn: compareFn,
    );
  }
}


