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

  /// Hero-style layout: large QR with yellow corner brackets, no title chrome.
  final bool compact;

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

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          if (_error != null && payload.isEmpty)
            _StatusInline(message: _error!)
          else if (payload.isEmpty && _loading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            )
          else if (payload.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final size = (constraints.maxWidth * 0.92).clamp(220.0, 320.0);
                return _QrWithBrackets(
                  size: size,
                  bracketColor: cts.yellow,
                  child: QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: size - 28,
                    backgroundColor: scheme.surface,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: scheme.onSurface,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: scheme.onSurface,
                    ),
                  ),
                );
              },
            )
          else
            const _StatusInline(message: 'QR unavailable. Tap refresh.'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_payload != null)
                Text(
                  'Refreshes in ~${_payload!.expiresIn}s',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              IconButton(
                tooltip: 'Refresh QR',
                visualDensity: VisualDensity.compact,
                onPressed: _loading ? null : _loadQr,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, color: cts.navy, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyCard(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
    final payload = _payload?.qrPayload ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  color: cts.yellowDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Boarding QR',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
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
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Commuters scan this code to board. Swipe remains as fallback.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
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
                  size: 200,
                  backgroundColor: scheme.surface,
                ),
              )
            else
              const _StatusInline(message: 'QR unavailable. Tap refresh.'),
            if (_payload != null) ...[
              const SizedBox(height: 8),
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

class _QrWithBrackets extends StatelessWidget {
  const _QrWithBrackets({
    required this.size,
    required this.bracketColor,
    required this.child,
  });

  final double size;
  final Color bracketColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const thickness = 4.0;
    const arm = 28.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(color: bracketColor, thickness: thickness, arm: arm),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Transform.rotate(
              angle: 1.5708,
              child: _Corner(
                color: bracketColor,
                thickness: thickness,
                arm: arm,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Transform.rotate(
              angle: 3.1416,
              child: _Corner(
                color: bracketColor,
                thickness: thickness,
                arm: arm,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform.rotate(
              angle: -1.5708,
              child: _Corner(
                color: bracketColor,
                thickness: thickness,
                arm: arm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.color,
    required this.thickness,
    required this.arm,
  });

  final Color color;
  final double thickness;
  final double arm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: arm,
      height: arm,
      child: CustomPaint(
        painter: _CornerPainter(color: color, thickness: thickness),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, thickness / 2), Offset(size.width, thickness / 2), paint);
    canvas.drawLine(Offset(thickness / 2, 0), Offset(thickness / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.thickness != thickness;
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
