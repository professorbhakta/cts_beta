import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  final String? message;

  const NoDataFound({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "NO DATA FOUND",
        style: TextStyle(
          color: context.cts.shadow,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
