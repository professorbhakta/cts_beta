> **Doc:** docs/backend/05-audit-and-gaps.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Migrated from project-talk-guide/backend/05-audit-and-gaps.md

# Backend — D2D Audit & Gaps

Audit from session analysis (Aug 2026). Updated after Fixes 1, 2, 4, return batch R1–R6, and hardening sprint (Aug 2026).

**Current verdict:** Dev happy paths for morning D2D + evening return are **stable**. Production auth still deferred.

See [../../PROJECT_BRAIN.md](../../PROJECT_BRAIN.md#6-status-snapshot) for short checklist.

---

## What works (happy path)

- ASGI + Uvicorn + Channels routing
- Nginx WebSocket proxy
- Connect → queue from Redis or DB rebuild
- REMOVE → CList + live queue (deduped)
- STOP → finalize DTODLOG, clear isComing for CList + queue, delete live Redis key
- Reconnect after STOP → **rejected 4001**
- Django restart mid-trip → live queue from Redis (24h TTL safety net)
- `running_batches` REST when `isActive=True` (uses `timezone.localdate()`)
- WS ADD capacity guard (shared with return batch via `capacity.py`)
- WS structured error responses (invalid JSON, no live state, capacity_full)
- Return batch: view / status / add / remove / end with user ID + atomic capacity
- Return end restores `isComing=True` for confirmed commuters
- Flutter return batch + D2D ended-trip UI

---

## Resolved (was critical)

| Issue | Fix | Status |
|-------|-----|--------|
| Ghost trip after STOP | Fix 1 — connect guard | ✅ |
| In-memory DS on channel_layer | Fix 2 — `live_state.py` | ✅ |
| Wrong `get_d2d_log_data` row | Fix 4 — tripDate filter | ✅ |
| Duplicate DTODLOG per day | Fix 4 — unique constraint | ✅ |
| Return batch user ID mismatch | R1 — lookup by userId + batchId | ✅ |
| Return remove not restoring pool | R5 — `isComing=True` on remove | ✅ |
| Return Redis leaks | R3 — `redis_connection()` | ✅ |
| Return unstructured responses | R2 — JSON contract | ✅ |

---

## Resolved (hardening sprint — Aug 2026)

| Issue | Fix | Files |
|-------|-----|-------|
| `date.today()` vs `localdate()` on WS | `get_trip_date()` everywhere | `consumers.py`, `utils.py`, `views.py` |
| `receive()` error handling | Structured `{"error": code}` responses | `consumers.py` |
| Null-safety (popId, commuter lookup) | Guards + batch-scoped filter | `consumers.py` |
| CList duplicates | Dedup before extend + DB transaction | `consumers.py` |
| STOP isComing scope | CList ∪ queue user IDs | `consumers.py` |
| No capacity on WS ADD | `get_cab_capacity` + occupied check | `capacity.py`, `consumers.py` |
| Return capacity race | Atomic Lua SADD | `return_batch_utils.py` |
| Return end isComing leak | Restore confirmed on end | `return_batch_utils.py` |
| Live DS race (single worker) | Redis WATCH/MULTI `mutate_live_state` | `live_state.py` |
| Orphan Redis keys | 24h TTL on live keys | `live_state.py` |
| Manual tests only | `tests.py` + extended scripts | `test_*.py`, `tests.py` |

---

## Still open — deferred

| Issue | Detail |
|-------|--------|
| No WebSocket auth | **Deferred** — dev/debugging |
| REST auth / permissions | All d2d views open in dev |
| InMemoryChannelLayer | OK for single worker; migrate when scaling |
| `return_start_time` / `return_end_time` | Unused on DTODLOG — product decision |
| Driver return screen | Admin only today (Flutter backlog) |
| Wire `get_d2d_log_status` in Flutter | Optional pre-connect check |

---

## Completed sprint docs

- [06-planned-fixes.md](./06-planned-fixes.md) — morning D2D ✅
- [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md) — evening return ✅

---

## Related

- [../CHANGELOG_SPRINTS.md](../CHANGELOG_SPRINTS.md)
