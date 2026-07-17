import 'package:cts/app/cts_app.dart';
import 'package:cts/app/di/app_providers.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/data/local/database/app_database.dart';
import 'package:cts/offline_temp/data/offline_temp_database.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  await AppDatabase.initialize();
  await OfflineTempDatabase.initialize();

  final bootstrap = await AppProviders.bootstrapServices();

  runApp(
    CtsApp(
      apiService: bootstrap.apiService,
      connectivityService: bootstrap.connectivityService,
      syncManager: bootstrap.syncManager,
      offlineFirstBatchRepository: bootstrap.offlineFirstBatchRepository,
      sessionAuthNotifier: bootstrap.sessionAuthNotifier,
    ),
  );
}
