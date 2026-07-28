import 'package:cts/appManager/app_class.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/data/offline_temp_database.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/offline_temp/screens/offline_batch_commuters_screen.dart';
import 'package:cts/offline_temp/screens/offline_home_screen.dart';
import 'package:cts/offline_temp/screens/offline_route_pops_screen.dart';
import 'package:cts/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Debug entry point — loads only the offline temp module (no API/sync stack).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppManager.initialize();
  await OfflineTempDatabase.initialize();

  // Pretend an admin session so offline-only UI behaves like production.
  AppManager.instance.setString(ManagerKey.userType, 'ADMIN');
  AppClass.userType = 1;

  runApp(const OfflineDebugApp());
}

class OfflineDebugApp extends StatelessWidget {
  const OfflineDebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfflineTempProvider(),
      child: MaterialApp(
        title: 'CTS Offline (Debug)',
        theme: AppTheme.light(),
        debugShowCheckedModeBanner: false,
        initialRoute: RouteName.offlineTempHome,
        routes: {
          RouteName.offlineTempHome: (context) => const OfflineHomeScreen(),
          RouteName.offlineBatchCommuters: (context) {
            final batchId = ModalRoute.of(context)?.settings.arguments as int?;
            if (batchId == null) {
              return const OfflineHomeScreen();
            }
            return OfflineBatchCommutersScreen(batchId: batchId);
          },
          RouteName.offlineRoutePops: (context) {
            final routeId = ModalRoute.of(context)?.settings.arguments as int?;
            if (routeId == null) {
              return const OfflineHomeScreen();
            }
            return OfflineRoutePopsScreen(routeId: routeId);
          },
        },
      ),
    );
  }
}
