import 'package:cts/app/router/route_names.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StatusMessage.error(
          title: 'Something went wrong',
          message: 'An unexpected error occurred. Please try again.',
          onRetry: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RouteName.splashScreen);
            }
          },
        ),
      ),
    );
  }
}
