// Isolated prototype offline CRUD module (Phase E / P9).
//
// Production offline-first sync for batches lives in
// features/batches/repositories/ via OfflineFirstBatchRepository.
// OfflineAutoRedirect no longer redirects here (P5 degraded mode).
//
// Entry points: admin drawer → offline home routes in app_router.dart.
// Alternate entry: main_offline.dart for standalone offline demo builds.
//
// Promotion path: merge into features/offline/ with standard
// screens/providers/models/repositories layout, or delete once
// entity coverage matches production SyncManager scope.

export 'offline_auto_redirect.dart';
export 'providers/offline_temp_provider.dart';
export 'screens/offline_home_screen.dart';
