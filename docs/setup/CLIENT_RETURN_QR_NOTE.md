> **Doc:** docs/setup/CLIENT_RETURN_QR_NOTE.md
> **Updated:** 2026-09-08
> **Session:** Live RCList + archive-on-end pointer lock

# Client update — return / evening QR

**Source:** BHAKTA (client), 2026-09-08  
**Status:** Discuss / locked as product ask — **no code** until green flag go

## Ask
Return (evening) trip should use the **same QR boarding flow** as the morning trip.

## Scope
- That is the only client ask from this batch.
- Do not invent extra return features beyond mirroring morning QR boarding.

## Next (when building)
1. Compare morning QR/boarding APIs + Flutter screens to return trip path.
2. Gap list in API_CONTRACTS + FLOWS_BY_ROLE.
3. Implement only after BHAKTA says green flag go.

## Also update
- `docs/setup/DISCUSSION_STATUS.md` — add under Next / client
- `docs/FLOWS_BY_ROLE.md` — return boarding = morning QR parity (pointer)

## STORAGE LOCK (BHAKTA 2026-09-08) — discuss only, no green flag

Chosen:
1. **Full return trip log** — same idea as morning `DTODLOG` (start / end / odometer-style history).
2. **`RCList`** — return boarding list in DB (like morning CList).

Why: return QR needs a real `trip is running` shell + saved who boarded; history needed later.

Not chosen: Redis-only for boarding truth.

Next (after green flag): design columns (reuse vs new table names), then API_CONTRACTS gap-list, then code on feature branch.

## RCLIST SHAPE LOCK (BHAKTA 2026-09-08)

- `RCList` = **user-ID list on the return trip log row** (same pattern as morning `CList`)
- Not one DB row per boarded rider (keeps DB smaller / one-read API on VPS)
- Tradeoff noted: concurrent QR scans can race on list write — OK for small audience for now
- Suggestions must also weigh VPS/VM design (size, load, backups), not only app ease

## LIVE + ARCHIVE LOCK (BHAKTA 2026-09-08)

1. **Live trip:** `RCList` = user-ID list on return trip log row (fast one API/socket).
2. **After End:** move that list into an **archive table**; trip row keeps only an **archive ID pointer** (not the full list forever).
3. Concurrent live QR race: rare on small buses; handle in code later, not extra tables.
4. VPS: live stays light; history not bloating active trip rows.

Still discuss-only — column draft next; no migrations until green flag.