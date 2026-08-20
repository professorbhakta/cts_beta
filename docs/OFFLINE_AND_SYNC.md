> **Doc:** docs/OFFLINE_AND_SYNC.md
> **Updated:** 2026-08-20 22:15 IST
> **Session:** Verified unchanged

# Offline and sync

How offline behavior works today: **production batch sync** vs **offline_temp** prototype.

**See also:** [ARCHITECTURE.md](./ARCHITECTURE.md) · [FEATURES.md](./FEATURES.md)

---

## Two systems (do not confuse)

| System | Location | Status |
|--------|----------|--------|
| **Production offline-first** | `OfflineFirstBatchRepository`, `SyncManager`, `AppDatabase` | Batches only |
| **Offline temp module** | `lib/offline_temp/` | Prototype UI + separate DB; admin drawer entry |

---

## Degraded network (P5 — production app)

Full offline queue/replay for live trips and return batches is **deferred**. Current behavior:

| Component | Role |
|-----------|------|
| `NetworkActionGuard` | Pre-check before D2D connect/WS actions and return batch confirm/remove/end |
| `NetworkDegradedBanner` | App-wide offline banner (MaterialApp builder) |
| `OfflineAutoRedirect` | **Passthrough** — no auto-jump to `/offlineTempHome` (P5); drawer entry still available |
| `ConnectivityService.isOnlineCached` | Fast path for sync UI guards without re-probing |

**Extension point:** `NetworkActionPolicy.queueWhenOffline` reserved for future per-entity queue handlers (see `SyncManager` + batch registration today).

**Future offline scope (not P5):** queue/replay for return batch POSTs, D2D WS action replay, commuter intents, full admin CRUD offline beyond batches.

---

## Production: batch offline-first

```mermaid
flowchart LR
  UI[BatchScreen / BatchForm] --> Repo[OfflineFirstBatchRepository]
  Repo --> Online{Online?}
  Online -->|Yes| API[BatchRepositoryImpl Dio]
  Online -->|No| Cache[SQLite CacheService]
  Repo --> Queue[SyncQueueDao]
  Queue --> Sync[SyncManager]
  Sync --> API
```

**Read path:** Online → API + refresh cache. Offline → read cached batches for current admin code.

**Write path:** Online → API immediately. Offline → enqueue `SyncQueueRecord` + optimistic local update where applicable.

**Registration:** `offlineFirstBatchRepository.registerSyncHandlers(syncManager)` in bootstrap.

---

## SyncManager

File: `lib/core/sync/sync_manager.dart`

| Behavior | Detail |
|----------|--------|
| Listens | App-scoped `ConnectivityService` (one plugin listener; `isOnline` cached; events only on state change) |
| On online | `syncPending()` processes queue |
| Handlers | Per `EntityType` — batches registered at startup |
| Retries | `maxRetries` (default 5); failed count tracked |
| Unknown entity | No handler → mark failed at `maxRetries` (does not retry forever) |
| Dispose | `CtsApp.dispose` stops SyncManager then disposes `ConnectivityService`. SyncManager disposes connectivity only if it created it |

---

## Admin drawer sync UI

`AppDrawer` → `_syncStatusBanner`:

- Shows pending/failed counts when `SyncManager.hasPendingWork`
- **Sync now** triggers manual sync

---

## Local storage (production)

| Component | Role |
|-----------|------|
| `AppDatabase` | SQLite singleton |
| `CacheService` | Entity cache by admin code |
| `SyncQueueDao` | Pending mutations |

Initialized in `main.dart` before `runApp`.

---

## Offline temp module

**Route:** `/offlineTempHome`

**UI:** Bottom tabs — Routes, Batches, Commuters, Output; FAB per tab; optional seed import / dump all.

**Data:** `OfflineTempDatabase`, `OfflineTempProvider` — local-only prototype for demos and planning (Phase 9: promote to production patterns).

**Redirect:** `OfflineAutoRedirect` on **admin home, driver home, and offline screens** only. Commuter home and Track Cab are not wrapped. Uses the app-scoped `ConnectivityService` (no second plugin listener). `isOfflineRole()` is admin or driver via `SessionRole`. Do not add extra connectivity probes or a session ping.

---

## Roadmap (from PROJECT_TODOS)

- Phase 9: Promote `offline_temp` patterns or merge into feature repositories
- Expand `EntityType` handlers beyond batches for full admin CRUD offline

---

## Developer checklist (offline change)

1. If touching batches: test airplane mode → create/edit → reconnect → drawer sync
2. Update sync handler registration if new entity types added
3. Document entity in this file and [FEATURES.md](./FEATURES.md)
