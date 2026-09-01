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
    this.compact = false,
  });

  final String batchId;

  /// When false (trip ended / STOP), clears QR and releases wakelock.
  final bool enabled;

  /// Large high-contrast QR under batch/KM — minimal chrome.
  final bool compact;

  @override
  State<BoardingQrPanel> createState() => BoardingQrPanelState();
}

class BoardingQrPanelState extends State<BoardingQrPanel> {
  BoardingQrPayload? _payload;
  String? _error;
  bool _loading = false;
  Timer? _refreshTimer;

  /// External refresh (e.g. "QR refresh" header control).
  Future<void> refresh() => _loadQr();

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
    if (!widget.enabled) return const SizedBox.shrink();

    if (widget.compact) {
      return _buildHeroQr(context);
    }
    return _buildLegacyCard(context);
  }

  Widget _buildHeroQr(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final payload = _payload?.qrPayload ?? '';

    return Column(
      children: [
        if (_error != null && payload.isEmpty)
          _StatusInline(message: _error!)
        else if (payload.isEmpty && _loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (payload.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final size = (constraints.maxWidth * 0.94).clamp(240.0, 340.0);
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border.all(
                    color: cts.navy.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: size - 32,
                    backgroundColor: scheme.surface,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: cts.navy,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: cts.navy,
                    ),
                  ),
                ),
              );
            },
          )
        else
          const _StatusInline(message: 'QR unavailable. Tap refresh.'),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_payload != null)
              Text(
                'Refreshes in ~${_payload!.expiresIn}s',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cts.navy.withValues(alpha: 0.55),
                ),
              ),
            IconButton(
              tooltip: 'Refresh QR',
              visualDensity: VisualDensity.compact,
              onPressed: _loading ? null : _loadQr,
              icon: _loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cts.navy,
                      ),
                    )
                  : Icon(Icons.refresh, color: cts.navy, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegacyCard(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final payload = _payload?.qrPayload ?? '';

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cts.navy.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2, color: cts.navy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Boarding QR',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cts.navy,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh QR',
                  onPressed: _loading ? null : _loadQr,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.refresh, color: cts.navy),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Commuters scan this code to board. Swipe remains as fallback.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null && payload.isEmpty)
              _StatusInline(message: _error!)
            else if (payload.isEmpty && _loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (payload.isNotEmpty)
              Center(
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: scheme.surface,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: cts.navy,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: cts.navy,
                  ),
                ),
              )
            else
              const _StatusInline(message: 'QR unavailable. Tap refresh.'),
            if (_payload != null) ...[
              const SizedBox(height: 8),
              Text(
                'Refreshes in ~${_payload!.expiresIn}s',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cts.navy.withValues(alpha: 0.55),
                ),
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
