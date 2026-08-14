import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:flutter/material.dart';

void attachD2dActionErrorListener({
  required D2dChannelProvider? current,
  required D2dChannelProvider next,
  required VoidCallback listener,
}) {
  if (identical(current, next)) return;
  current?.removeListener(listener);
  next.addListener(listener);
}

void handleD2dActionError(
  BuildContext context,
  D2dChannelProvider? provider,
) {
  final message = provider?.actionErrorMessage;
  if (message == null) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
  provider?.clearActionError();
}
