import 'package:cts/theme/cts_colors.dart';
import 'dart:async';

import 'package:cts/features/d2d/helpers/client_pack_feedback.dart';
import 'package:cts/features/d2d/models/boarding_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Driver-only boarding QR for an active morning trip.
///
/// Keep-awake while mounted. Auto-refreshes before [expiresIn].
class BoardingQrPanel extends StatefulWidget {
  const BoardingQrPanel({
    super.key,
    required this.batchId,
    this.enabled = true,
  });

  final String batchId;

  /// When false (trip ended / STOP), clears QR and releases wakelock.
  final bool enabled;

  @override
  State<BoardingQrPanel> createState() => _BoardingQrPanelState();
}

class _BoardingQrPanelState extends State<BoardingQrPanel> {
  BoardingQrPayload? _payload;
  String? _error;
  bool _loading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _activateDisplay();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadQr();
      });
    }
  }

  @override
  void didUpdateWidget(covariant BoardingQrPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) {
      _tearDown();
      setState(() {
        _payload = null;
        _error = null;
      });
    } else if (widget.enabled && !oldWidget.enabled) {
      _activateDisplay();
      _loadQr();
    } else if (widget.enabled && widget.batchId != oldWidget.batchId) {
      _loadQr();
    }
  }

  @override
  void dispose() {
    _tearDown();
    super.dispose();
  }

  Future<void> _activateDisplay() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  void _tearDown() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    WakelockPlus.disable().catchError((_) {});
  }

  Future<void> _loadQr() async {
    if (!widget.enabled || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<D2dRepository>();
      final result = await repo.getBoardingQr(widget.batchId);
      if (!mounted) return;
      if (result.isFailure) {
        final failure = result.failure!;
        ClientPackFeedback.showFailure(failure);
        setState(() {
          _error = ClientPackFeedback.messageForFailure(failure);
          _payload = null;
        });
        return;
      }
      final data = result.data!;
      setState(() {
        _payload = data;
        _error = null;
      });
      _scheduleRefresh(data.expiresIn);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scheduleRefresh(int expiresInSec) {
    _refreshTimer?.cancel();
    final wait = expiresInSec <= 30
        ? (expiresInSec / 2).floor().clamp(5, expiresInSec)
        : (expiresInSec - 20).clamp(10, expiresInSec);
    _refreshTimer = Timer(Duration(seconds: wait), () {
      if (mounted && widget.enabled) _loadQr();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    if (!widget.enabled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final payload = _payload?.qrPayload ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surface,
      elevation: 1,
      shadowColor: scheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                Text(
                  'Boarding QR',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Refresh QR',
                      onPressed: _loading ? null : _loadQr,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_error != null && payload.isEmpty)
              _StatusInline(message: _error!)
            else if (payload.isEmpty && _loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (payload.isNotEmpty)
              Center(
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 280,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              )
            else
              const _StatusInline(message: 'QR unavailable. Tap refresh.'),
            if (_payload != null) ...[
              const SizedBox(height: 4),
              Text(
                'Refreshes in ~${_payload!.expiresIn}s',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusInline extends StatelessWidget {
  const _StatusInline({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.error,
            ),
      ),
    );
  }
}
