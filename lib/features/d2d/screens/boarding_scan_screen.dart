import 'package:cts/features/d2d/helpers/client_pack_feedback.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

/// Commuter scans the driver boarding QR → [D2dRepository.boardingScan].
class BoardingScanScreen extends StatefulWidget {
  const BoardingScanScreen({super.key});

  @override
  State<BoardingScanScreen> createState() => _BoardingScanScreenState();
}

class _BoardingScanScreenState extends State<BoardingScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handling = false;
  bool _permissionDenied = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _permissionDenied = true);
      ClientPackFeedback.showError(
        'Camera permission is required to scan the boarding QR.',
      );
    }
  }

  Future<bool> _offerJoinWaiting(String message) async {
    final wantsJoin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join waiting line?'),
        content: Text(
          '$message\n\nYou can join the FCFS waiting line for this trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Join waiting line'),
          ),
        ],
      ),
    );
    return wantsJoin == true;
  }

  Future<void> _joinWaiting(String token) async {
    final repo = context.read<D2dRepository>();
    final result = await repo.boardingScan(token, action: 'join_waiting');
    if (!mounted) return;

    if (result.isFailure) {
      ClientPackFeedback.showFailure(result.failure!);
      await _controller.start();
      return;
    }

    final data = result.data;
    final msg = data?.message?.trim();
    if (data?.queuePosition == 0) {
      ClientPackFeedback.showSuccess(msg ?? 'Boarded from waiting line.');
    } else {
      ClientPackFeedback.showSuccess(
        msg ?? 'You are #${data?.queuePosition ?? ''} in the waiting line.',
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (raw.isEmpty) return;

    _handling = true;
    try {
      final repo = context.read<D2dRepository>();
      await _controller.stop();
      final result = await repo.boardingScan(raw);
      if (!mounted) return;

      if (result.isFailure) {
        final failure = result.failure!;
        final code = failure.code;
        if (code == 'not_in_queue' || code == 'capacity_full') {
          final wantsJoin = await _offerJoinWaiting(
            failure.message ?? 'Cannot board right now.',
          );
          if (wantsJoin && mounted) {
            await _joinWaiting(raw);
            return;
          }
        }
        ClientPackFeedback.showFailure(failure);
        await _controller.start();
        return;
      }

      final already = result.data?.alreadyBoarded == true;
      ClientPackFeedback.showSuccess(
        already ? 'Already boarded.' : 'Boarded successfully.',
      );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan boarding QR')),
      body: _permissionDenied
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Camera permission is required to scan the boarding QR.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: openAppSettings,
                      child: const Text('Open settings'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        setState(() => _permissionDenied = false);
                        await _ensureCameraPermission();
                        if (!_permissionDenied) {
                          await _controller.start();
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Scan to board if you are on the live queue. '
                            'If not added yet, you can join the waiting line.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          IconButton.filled(
                            onPressed: () async {
                              await _controller.toggleTorch();
                              if (mounted) {
                                setState(() => _torchOn = !_torchOn);
                              }
                            },
                            icon: Icon(
                              _torchOn ? Icons.flash_on : Icons.flash_off,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
