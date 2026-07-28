import 'package:flutter/widgets.dart';

/// A widget that listens to a [ChangeNotifier] and calls a callback
/// whenever the notifier's state changes.
///
/// This is useful for handling side-effects like navigation, dialogs, or
/// snackbars in response to state changes, without rebuilding the UI.
class ProviderListener<T extends ChangeNotifier> extends StatefulWidget {
  final T provider;
  final Function(BuildContext context, T provider) onChange;
  final Widget child;

  const ProviderListener({
    super.key,
    required this.provider,
    required this.onChange,
    required this.child,
  });

  @override
  State<ProviderListener<T>> createState() => _ProviderListenerState<T>();
}

class _ProviderListenerState<T extends ChangeNotifier>
    extends State<ProviderListener<T>> {
  @override
  void initState() {
    super.initState();
    // Add the listener when the widget is first created.
    widget.provider.addListener(_listener);
  }

  @override
  void didUpdateWidget(ProviderListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the provider instance changes, remove the old listener and add a new one.
    if (widget.provider != oldWidget.provider) {
      oldWidget.provider.removeListener(_listener);
      widget.provider.addListener(_listener);
    }
  }

  @override
  void dispose() {
    // Clean up the listener when the widget is removed from the tree.
    widget.provider.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    // Call the provided callback function when the provider notifies listeners.
    widget.onChange(context, widget.provider);
  }

  @override
  Widget build(BuildContext context) {
    // This widget does not build any UI itself, it just returns its child.
    return widget.child;
  }
}
