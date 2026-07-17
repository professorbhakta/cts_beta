import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart' show text, sizeBox;
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final VoidCallback? onTap;

  const ErrorScreen({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 350,
        width: 350,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.acRed,
            width: 1.7,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                text("ERROR", AppColors.acBlack, 24, FontWeight.bold),
                sizeBox(4.4, 0),
                Icon(
                  Icons.error_outline,
                  color: AppColors.acRed,
                  size: 35,
                )
              ],
            ),
            text("Something went wrong", AppColors.acShadowColor, 18,
                FontWeight.w400),
            sizeBox(0, 17),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  // minimumSize: Size(50, 50),
                  maximumSize: const Size(143, 44),
                ),
                onPressed: () {
                  if (onTap != null) {
                    onTap!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: AppColors.acRed,
                      size: 26,
                    ),
                    sizeBox(4.4, 0),
                    text("Retry", AppColors.acBlack, 17, FontWeight.bold),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

