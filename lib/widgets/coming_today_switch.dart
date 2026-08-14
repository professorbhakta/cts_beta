import 'package:cts/appManager/colors.dart';
import 'package:flutter/material.dart';

/// Coming-today switch that keeps taps even inside [InkWell] / [Slidable].
class ComingTodaySwitch extends StatelessWidget {
  const ComingTodaySwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: AbsorbPointer(
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.acGreen,
          ),
        ),
      ),
    );
  }
}
