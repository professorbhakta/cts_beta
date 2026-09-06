import 'dart:async';

import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared cream-board chrome for admin catalog list screens.
class CatalogHairlineSearch extends StatefulWidget {
  const CatalogHairlineSearch({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
  });

  final String hintText;
  final ValueChanged<String> onSearchChanged;

  @override
  State<CatalogHairlineSearch> createState() => _CatalogHairlineSearchState();
}

class _CatalogHairlineSearchState extends State<CatalogHairlineSearch> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _emit(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return TextField(
      controller: _controller,
      onChanged: (value) {
        setState(() {});
        _emit(value);
      },
      style: theme.textTheme.bodyMedium?.copyWith(color: cts.navy),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cts.navy.withValues(alpha: 0.45),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: cts.navy.withValues(alpha: 0.55),
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: cts.navy.withValues(alpha: 0.55),
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cts.navy.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}

class CatalogYellowAddButton extends StatelessWidget {
  const CatalogYellowAddButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: cts.yellow,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogPageTitle extends StatelessWidget {
  const CatalogPageTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class CatalogCard extends StatelessWidget {
  const CatalogCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.children = const [],
    this.onTap,
    this.onLongPress,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cts.navy,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cts.navy.withValues(alpha: 0.65),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing!,
                    ],
                  ],
                ),
                if (children.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...children,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogField extends StatelessWidget {
  const CatalogField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogFooterHint extends StatelessWidget {
  const CatalogFooterHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cts.navy.withValues(alpha: 0.55),
            ),
      ),
    );
  }
}

class CatalogListSkeleton extends StatelessWidget {
  const CatalogListSkeleton({
    super.key,
    required this.title,
    this.itemCount = 6,
    this.itemHeight = 72,
  });

  final String title;
  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cts.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: cts.navy.withValues(alpha: 0.08),
            highlightColor: cts.navy.withValues(alpha: 0.03),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => Container(
                height: itemHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
