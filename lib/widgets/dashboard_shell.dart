import 'package:cts/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.title,
    required this.child,
    this.actions,
    this.fab,
    this.showDrawer = true,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;
  final bool showDrawer;

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= desktopBreakpoint;
    final isTablet = width >= tabletBreakpoint && width < desktopBreakpoint;
    final navigation = const SafeArea(child: AdminNavList());

    final appBar = AppBar(
      title: Text(title),
      actions: actions,
    );

    final horizontalPadding = isDesktop ? 16.0 : (isTablet ? 12.0 : 2.0);

    final body = ColoredBox(
      color: theme.colorScheme.surface,
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
            SizedBox(width: 250, child: navigation),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant,
            ),
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
      drawer: showDrawer ? Drawer(child: navigation) : null,
      body: body,
      floatingActionButton: fab,
    );
  }
}
