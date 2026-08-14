> **Doc:** docs/CHANGELOG_SPRINTS.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver return ADD sprint section

# Changelog — Completed Sprints (Aug 2026)

Historical record of implemented fixes. Live backlog → [PROJECT_TODOS.md](../PROJECT_TODOS.md).

---

## Driver return ADD (Flutter + Django) — 2026-08-14 ✅

**Target repos:** `D:\cts_beta` + `D:\cts-docker`

| Issue | Fix |
|-------|-----|
| Driver return list was read-only | Confirm/Remove on `/driverReturnCommuter` via `POST add_commuter` / `remove_commuter`. End FAB stays admin |
| Available pool was this morning batch + `isComing=True` | Org-wide pool; hide anyone confirmed today (any return batch). Add looks up by user ID |
| Confirmed cross-batch riders missing from Confirmed tab | `get_commuter` hydrates by user ID, not `batchId` |

Verify: `test_return_batch_fixes.py` 14/14. See [API_CONTRACTS.md](./API_CONTRACTS.md) · [lib/features/batches/README.md](../lib/features/batches/README.md)

---

## Admin D2D + isComing (Flutter + Django) — 2026-08-14 ✅

**Target repos:** `D:\cts_beta` + `D:\cts-docker`

| Issue | Fix |
|-------|-----|
| Nested batch Coming switch was display-only; card stole taps | `ComingTodaySwitch` + `PATCH /user/commuter/<userId>` `{isComing}`; Django returns `{status, isComing}` |
| Morning trip looked “ended” after leaving the channel | Only driver `{ACTION: STOP}` sets `endTime`. Connect creates `DTODLOG`. Same-day reconnect after STOP is **4001** |
| Admin ADD toast with no live-list update | Sheet listed all commuters; WS ADD 404 on `userId+batchId` crashed the socket. Lookup by user ID; toast after list updates |

See [API_CONTRACTS.md](./API_CONTRACTS.md) · [lib/features/d2d/README.md](../lib/features/d2d/README.md)

---

## Auth security wave (Flutter + Django) — S1–S5 ✅

**Target repos:** `D:\cts_beta` + `D:\cts-docker` · **Status:** Done (connect-time only; no session ping)

| ID | Issue | Fix |
|----|--------|-----|
| **S1** | Public sign-up posted `userType: ADMIN` | `/signUp` redirects to sign-in; repository refuses public ADMIN. Backend `POST /user/` still trusts `userType` |
| **S2** | HTTPS/WSS rewritten to HTTP/WS; Android cleartext in release | Scheme kept; cleartext **debug/profile only** |
| **S3** | D2D WS with no cookie | Flutter `IOWebSocketChannel` Cookie header; Django 4401/4403 on connect; actions not re-authorized per message |
| **S4+S5** | Logout skipped cookies; `isLogin` only; no 401 sign-out | Always `clearLocalSession()`; logged-in = flag + sessionid; Dio 401 → sign-in |
| **Follow-up** | Auth/connectivity “again and again” | Session cookies + `isOnline` cached in memory; one Connectivity listener |

Verify: `test_d2d_fixes.py` (anonymous 4401). See [API_CONTRACTS.md](./API_CONTRACTS.md) · [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md)

---

## Application wave (Flutter CRUD) — A2, A3, A4 ✅

**Target repo:** `D:\cts_beta` · **Status:** Slices 1–3 done. A5 closed in the follow-up wave below.

| ID | Issue | Fix |
|----|--------|-----|
| **A2** | Batch commuter swipe-edit used the sorted index on the unsorted list | Pass `CommuterModel`. Same for route edit/delete (`RouteModel`) |
| **A3** | Commuter update always PATCHed `mail@email.com` / `"address"` | Restored Email + Address fields; empty create address → email; update uses last saved from `GET /user/<pk>` |
| **A4** | Dashboard Add skipped `clearAll()` | All six Add quick actions call matching `*FormProvider.clearAll()` |

See [API_CONTRACTS.md](./API_CONTRACTS.md) (admin commuter CRUD) · [FEATURES.md](./FEATURES.md)

---

## Same-class wave — A5, A10, R6 ✅

**Target repo:** `D:\cts_beta` · **Status:** Done 2026-08-14

| ID | Issue | Fix |
|----|--------|-----|
| **A5** | Leaving commuter form reloaded the full admin list into a batch screen | `CommuterController.refreshCurrentList()`; generation-based fetch so by-batch is not dropped |
| **A10** | Commuter home / Track Cab wrapped in `OfflineAutoRedirect`; fallback treated COMMUTER as offline | Unwrap those screens; `isOfflineRole()` is admin or driver via `SessionRole` |
| **R6** | Unknown sync types skipped forever; ConnectivityService never disposed | Mark unknown types failed at `maxRetries`; `CtsApp.dispose` stops SyncManager then disposes connectivity |

R1–R3 were already in sources (mounted return, Wi-Fi cancel, running-list snapshot).

---

## Morning D2D backend (Fixes 1, 2, 4)

**Target repo:** `D:\cts-docker\django\` · **Status:** ✅ Implemented

### Fix 1: Ended-trip guard on connect ✅

After STOP, reconnect same day no longer reactivates live queue. `consumers.py` closes with code **4001** when `not isActive` or `endTime` set.

**Flutter follow-up ✅:** `D2dChannelProvider.isTripEnded` — "Trip already ended", no retry.

### Fix 2: Redis-backed live state ✅

**Module:** `d2d_log/live_state.py` — key `d2d:live:{YYYY-MM-DD}:{batch_id}`. Mid-trip Django restart restores queue from Redis.

### Fix 4: get_d2d_log_data + unique constraint ✅

- `UniqueConstraint(batchId, tripDate)` — migration `0002_unique_batch_trip_date`
- `GET /d2d/get_d2d_log_status/<batch_id>` returns structured JSON

**Verify:** `docker exec -w /app/django C2S-Django python d2d_log/test_d2d_fixes.py`

---

## Return batch backend (R1–R6) ✅

Evening REST + Redis with user ID convention, structured JSON, capacity checks, remove restores `isComing=True`.

**Verify:** `docker exec -w /app/django C2S-Django python d2d_log/test_return_batch_fixes.py`

See [backend/04-return-batch-lifecycle.md](./backend/04-return-batch-lifecycle.md).

---

## Flutter sprint plan (Aug 2026) — all ✅

| Phase | Focus | Status |
|-------|-------|--------|
| **1** | WS action error handling | ✅ |
| **2** | Driver return read-only screen | ✅ |
| **3** | UX polish (labels, badges, cards) | ✅ |

### Phase 1 — WS error handling

- Provider checks `error` key before `result`; `actionErrorMessage` without disconnect
- Admin + driver SnackBar on capacity_full, no_live_state, etc.

### Phase 2 — Driver return screen

- Route `/driverReturnCommuter/:batchId`; read-only `ReturnCommuterListScreen`
- Entry from driver home **VIEW RETURN LIST**

### Phase 3 — UX polish

| Item | Change |
|------|--------|
| Swipe label | Green label → "Picked up" in `d2d_live_widgets.dart` |
| Pre-connect badge | `GET get_d2d_log_status` chip on driver log |
| Driver name on return cards | `returning_batch_screen.dart` shows assigned driver |

---

## Return batch Flutter — resolved (Aug 2026)

| Was | Now |
|-----|-----|
| Wrong endpoint for available list | `GET d2d/return_batch/view/{id}` |
| Invalid confirmed endpoint | `GET get_commuter/{id}` + hydrated `commuters` |
| Remove / End not wired | Swipe Remove + End return FAB |
| No confirm UI | Swipe Confirm on Available tab |
| N/A on batch cards | `GET status/{id}` per batch |
| Navigator.push | go_router `/returnCommuterScreen/:batchId` |

---

## Live D2D Flutter — resolved

| Gap | Status |
|-----|--------|
| Ended trip reconnect UI | ✅ |
| WS action errors not shown | ✅ |
| Confusing swipe labels | ✅ "Picked up" |
| Pre-connect status via `get_d2d_log_status` | ✅ |

---

## Backend hardening sprint ✅

Date/time consistency (`get_trip_date()`), structured WS errors, CList dedup, STOP scope, WS ADD capacity guard, return capacity race (Lua), live DS WATCH/MULTI, 24h TTL on live keys.

See [backend/05-audit-and-gaps.md](./backend/05-audit-and-gaps.md).

---

## Out of scope (unchanged / deferred)

- REST permissions on d2d views (still open in dev)
- Backend `POST /user/` still trusts client `userType`
- `channels_redis` migration

---

## Related

- [backend/06-planned-fixes.md](./backend/06-planned-fixes.md) — morning fix detail
- [features/D2D_E2E.md](./features/D2D_E2E.md)
- [features/RETURN_BATCH_E2E.md](./features/RETURN_BATCH_E2E.md)
