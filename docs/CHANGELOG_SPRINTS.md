> **Doc:** docs/CHANGELOG_SPRINTS.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Merged sprint history from talk-guide backend + frontend gaps

# Changelog — Completed Sprints (Aug 2026)

Historical record of implemented fixes. Live backlog → [PROJECT_TODOS.md](../PROJECT_TODOS.md).

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

- WebSocket / REST authentication
- Role-based action guards
- `channels_redis` migration
- Capacity check on WS ADD (partially done in hardening)

---

## Related

- [backend/06-planned-fixes.md](./backend/06-planned-fixes.md) — morning fix detail
- [features/D2D_E2E.md](./features/D2D_E2E.md)
- [features/RETURN_BATCH_E2E.md](./features/RETURN_BATCH_E2E.md)
