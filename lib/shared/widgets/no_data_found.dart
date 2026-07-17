import 'package:flutter/material.dart';
import 'package:cts/appManager/colors.dart';

class NoDataFound extends StatelessWidget {
  final String? message;

  const NoDataFound({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "NO DATA FOUND",
        style: TextStyle(
          color: AppColors.acShadowColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

