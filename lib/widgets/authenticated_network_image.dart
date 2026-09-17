import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:flutter/material.dart';

/// Loads a network image with `Authorization: Bearer <access>` from
/// [SessionManager]. Relative paths are joined to [AppConfig.apiBaseUrl].
///
/// On missing URL, auth failure, or HTTP error (incl. 404), shows [errorBuilder]
/// or a quiet empty box — never a loud error.
class AuthenticatedNetworkImage extends StatefulWidget {
  const AuthenticatedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorBuilder,
    this.placeholder,
    this.onTap,
  });

  /// Absolute URL or API-relative path (e.g. `d2d/odometer/photo/.../`).
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext context)? errorBuilder;
  final Widget? placeholder;
  final VoidCallback? onTap;

  @override
  State<AuthenticatedNetworkImage> createState() =>
      _AuthenticatedNetworkImageState();
}

class _AuthenticatedNetworkImageState extends State<AuthenticatedNetworkImage> {
  String? _resolvedUrl;
  Map<String, String>? _headers;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _prepare();
    }
  }

  String _absoluteUrl(String pathOrUrl) {
    final trimmed = pathOrUrl.trim();
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    final base = AppConfig.instance.apiBaseUrl;
    final normalized = base.endsWith('/') ? base : '$base/';
    if (trimmed.startsWith('/')) {
      final origin = Uri.parse(normalized);
      return origin.replace(path: trimmed).toString();
    }
    return '$normalized$trimmed';
  }

  Future<void> _prepare() async {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) {
      if (!mounted) return;
      setState(() {
        _resolvedUrl = null;
        _headers = null;
        _ready = true;
        _failed = true;
      });
      return;
    }

    setState(() {
      _ready = false;
      _failed = false;
    });

    String absolute;
    try {
      absolute = _absoluteUrl(raw);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedUrl = null;
        _headers = null;
        _ready = true;
        _failed = true;
      });
      return;
    }

    final token = await SessionManager().getAccessToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      setState(() {
        _resolvedUrl = null;
        _headers = null;
        _ready = true;
        _failed = true;
      });
      return;
    }

    setState(() {
      _resolvedUrl = absolute;
      _headers = {'Authorization': 'Bearer $token'};
      _ready = true;
      _failed = false;
    });
  }

  Widget _quietEmpty(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context);
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
    );
  }

  Widget _loadingBox() {
    return widget.placeholder ??
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!_ready) {
      child = _loadingBox();
    } else if (_failed || _resolvedUrl == null) {
      child = _quietEmpty(context);
    } else {
      child = Image.network(
        _resolvedUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        headers: _headers,
        errorBuilder: (context, error, stackTrace) {
          // Defer setState — errorBuilder may run during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_failed) {
              setState(() => _failed = true);
            }
          });
          return _quietEmpty(context);
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loadingBox();
        },
      );
    }

    final clipped = widget.borderRadius != null
        ? ClipRRect(borderRadius: widget.borderRadius!, child: child)
        : child;

    final canTap = widget.onTap != null && !_failed && _resolvedUrl != null;
    if (!canTap) {
      return clipped;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.borderRadius,
        child: clipped,
      ),
    );
  }
}

/// Full-screen dialog showing an authenticated odometer photo with a close
/// control.
Future<void> showAuthenticatedPhotoViewer(
  BuildContext context, {
  required String? url,
  String title = 'Odometer photo',
}) {
  if (url == null || url.trim().isEmpty) {
    return Future.value();
  }
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (dialogContext) {
      return Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: AuthenticatedNetworkImage(
                    url: url,
                    fit: BoxFit.contain,
                    width: MediaQuery.sizeOf(dialogContext).width,
                    height: MediaQuery.sizeOf(dialogContext).height * 0.85,
                    errorBuilder: (_) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
