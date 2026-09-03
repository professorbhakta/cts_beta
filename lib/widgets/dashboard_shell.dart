import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.title,
    required this.child,
    this.titleWidget,
    this.actions,
    this.fab,
    this.showDrawer = true,
    this.quietBrandAppBar = false,
    super.key,
  });

  final String title;
  final Widget? titleWidget;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;
  final bool showDrawer;

  /// Cream bar + navy mark (admin home). Other admin screens keep the default bar.
  final bool quietBrandAppBar;

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= desktopBreakpoint;
    final isTablet = width >= tabletBreakpoint && width < desktopBreakpoint;
    final showNavigation = showDrawer;
    final navigation = const SafeArea(child: AdminNavList());

    final Color? barBg = quietBrandAppBar ? theme.scaffoldBackgroundColor : null;
    final Color? barFg = quietBrandAppBar ? cts.navy : null;

    final appBar = AppBar(
      title: titleWidget ??
          Text(
            title,
            style: quietBrandAppBar
                ? theme.textTheme.titleLarge?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1,
                  )
                : null,
          ),
      actions: actions,
      backgroundColor: barBg,
      foregroundColor: barFg,
      surfaceTintColor: quietBrandAppBar ? Colors.transparent : null,
      elevation: quietBrandAppBar ? 0 : null,
      scrolledUnderElevation: quietBrandAppBar ? 0 : null,
      iconTheme: quietBrandAppBar
          ? IconThemeData(color: cts.navy)
          : null,
      systemOverlayStyle: quietBrandAppBar
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )
          : null,
    );

    final horizontalPadding = isDesktop ? 16.0 : (isTablet ? 12.0 : 0.0);

    final body = ColoredBox(
      color: quietBrandAppBar
          ? theme.scaffoldBackgroundColor
          : theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 2,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Row(
          children: [
            if (showNavigation) ...[
              SizedBox(width: 250, child: navigation),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            ],
            Expanded(
              child: Scaffold(
                appBar: appBar,
                body: body,
                floatingActionButton: fab,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ],
        ),
      );
    }

    // Tablet: drawer is fine; AppBar provides top inset.
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: appBar,
      drawer: showNavigation ? Drawer(child: navigation) : null,
      body: body,
      floatingActionButton: fab,
    );
  }
}
