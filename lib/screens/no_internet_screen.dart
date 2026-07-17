import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';

class NoInternetError extends StatefulWidget {
  const NoInternetError({super.key});

  @override
  State<NoInternetError> createState() => _NoInternetErrorState();
}

class _NoInternetErrorState extends State<NoInternetError> {
  bool _isChecking = false;

  Future<void> _checkConnectivityAndRetry() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (!connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No internet connection. Please check your network settings.',
            ),
            backgroundColor: scheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking connectivity: $e'),
            backgroundColor: scheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isChecking
            ? const Center(child: CircularProgressIndicator())
            : StatusMessage.error(
                title: 'No Internet Connection',
                message:
                    'Please check your internet connection and try again.',
                onRetry: _checkConnectivityAndRetry,
              ),
      ),
    );
  }
}
