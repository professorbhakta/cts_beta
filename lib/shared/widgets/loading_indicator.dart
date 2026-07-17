import 'package:flutter/material.dart';

/// A standardized loading indicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.height,
    super.key,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    final loadingWidget = const Center(child: CircularProgressIndicator());

    if (height != null) {
      return SizedBox(
        height: height,
        child: loadingWidget,
      );
    }

    return loadingWidget;
  }
}
