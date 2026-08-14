> **Doc:** docs/backend/06-planned-fixes.md
> **Updated:** 2026-08-14 19:55 IST
> **Session:** Pointer to later WS connect auth (security wave)

# Backend — Planned Fixes (Sprint) — Morning D2D

**Target repo:** `D:\cts-docker\django\`

**Scope:** Fixes 1, 2, 4 from audit. **No auth in this sprint.**

**Status:** ✅ Implemented (Aug 2026). Verify: `d2d_log/test_d2d_fixes.py`

Connect-time WebSocket auth (cookie, 4401/4403) landed later in the **auth security wave** — see [05-audit-and-gaps.md](./05-audit-and-gaps.md) and [CHANGELOG_SPRINTS.md](../CHANGELOG_SPRINTS.md).

---

## Fix 1: Ended-trip guard on connect ✅

### Problem

After STOP, reconnect same day reactivates live queue on ended DTODLOG while `isActive=False`.

### Implementation (done)

`d2d_log/consumers.py` — after `create_d2d_Data`:

```python
if logExsists and (not D2D.isActive or D2D.endTime is not None):
    await self.channel_layer.group_discard(...)
    await self.close(code=4001)
    return
```

### Acceptance tests

- [x] STOP → reconnect same batch same day → connection rejected (4001)
- [x] Next calendar day → new DTODLOG, normal connect
- [x] `running_batches` and WS state stay consistent

### Flutter follow-up ✅

`D2dChannelProvider` handles close code 4001 — "Trip already ended" (no retry).

---

## Fix 2: Redis-backed live state ✅

### Problem

`setattr(channel_layer, batch_name, DS)` — fragile, lost on restart, not multi-worker safe.

### Implementation (done)

**Module:** `d2d_log/live_state.py`

- Key: `d2d:live:{YYYY-MM-DD}:{batch_id}`
- Value: JSON-serialized DS dict
- `get_live_state` / `set_live_state` / `delete_live_state`

**`consumers.py`:** connect/receive/STOP use Redis; InMemoryChannelLayer for broadcast only.

### Acceptance tests

- [x] Mid-trip `docker restart C2S-Django` → reconnect → queue restored
- [x] STOP → Redis key deleted
- [x] Admin + driver still receive broadcasts
- [x] No `setattr(channel_layer, …)` for DS

---

## Fix 4: get_d2d_log_data + unique constraint ✅

### Implementation (done)

- **`utils.py`:** `get_d2d_log_data(batch_id, trip_date=None, active_only=False)`
- **`models.py`:** `UniqueConstraint(batchId, tripDate)` — migration `0002_unique_batch_trip_date`
- **`create_d2d_Data`:** `get_or_create(batchId, tripDate)`
- **`CheckD2dLogStatus`:** structured JSON with `status: active|ended`

### Acceptance tests

- [x] Only one DTODLOG per batch per day
- [x] `GET /d2d/get_d2d_log_status/<batch_id>` returns correct today's log
- [x] Concurrent connect does not create duplicates

---

## Files touched

| File | Fix |
|------|-----|
| `d2d_log/consumers.py` | 1, 2 |
| `d2d_log/live_state.py` | 2 (new) |
| `d2d_log/utils.py` | 4 |
| `d2d_log/models.py` | 4 |
| `d2d_log/migrations/0002_unique_batch_trip_date.py` | 4 |
| `d2d_log/views.py` | 4 |
| `d2d_log/test_d2d_fixes.py` | verification |

---

## Out of scope (unchanged)

- WebSocket / REST authentication
- Role-based action guards
- channels_redis migration
- Return batch (see [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md))
- Capacity check on WS ADD

---

## Related

- [05-audit-and-gaps.md](./05-audit-and-gaps.md)
- [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md)
