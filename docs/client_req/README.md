> **Doc:** docs/client_req/README.md
> **Updated:** 2026-08-26 07:58 IST
> **Session:** Option B — DESIGN_SNAPSHOT added to read order

# Client requirements — D2D QR boarding + cab KM log

**Status:** BUILD UI STEPS 1–7 + ops shipped. **STEP 8 device smoke** awaits user **go**.

---

## Read order (smooth path)

| Order | File | Job |
|------:|------|-----|
| 1 | [DISCUSSION_LOG.md](DISCUSSION_LOG.md) | Where we left off (pointer only) |
| 2 | [05-open-decisions.md](05-open-decisions.md) | Product story + D1–D10 |
| 3 | [DESIGN_SNAPSHOT.md](DESIGN_SNAPSHOT.md) | Tables, APIs, DT↔API, safety (replaces deleted 00–04/06) |
| 4 | [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) | Click-paths incl. QR + KM + smoke table |
| 5 | [API_CONTRACTS.md](../API_CONTRACTS.md) · [d2d/README.md](../../lib/features/d2d/README.md) | Live wire + UI detail |
| 6 | [07-NEXT-AGENT-PROMPT.md](07-NEXT-AGENT-PROMPT.md) | STEP 8 smoke script only |

---

## Attach (LOCKED — brain §3)

```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
@docs/client_req/DISCUSSION_LOG.md
@docs/client_req/07-NEXT-AGENT-PROMPT.md
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
```

Add `@docs/FLOWS_BY_ROLE.md` for QA/smoke. Optional: `@docs/client_req/05-open-decisions.md` · `@docs/client_req/DESIGN_SNAPSHOT.md`.

Discuss turns: update DISCUSSION_LOG + footer. Coding: update log at milestones only.

---

## Files here

| File | Purpose |
|------|---------|
| DISCUSSION_LOG | Live pointer + short log |
| 05-open-decisions | Durable story + locks |
| **DESIGN_SNAPSHOT** | Inventory snapshot (schema / APIs / DT↔API) |
| 07-NEXT-AGENT-PROMPT | Smoke copy block |
| README | This index |

**Not restored:** full design MDs `00–04`, `06` (never in git on this branch). Use **DESIGN_SNAPSHOT** instead. Journeys → FLOWS (no `guides/`).

---

## Shipped vs left

| Area | Status |
|------|--------|
| BE + Flutter UI 1–7 | Done |
| Odometer Close/Skip + photo optional | Done (2026-08-26) |
| nginx 8m + Postgres backup | Done |
| FLOWS QR/KM journeys | Done |
| DESIGN_SNAPSHOT (docs option B) | Done |
| Device smoke STEP 8 | **Await go** |
| New tests `test/features/d2d/` | Open |
| Return KM / org odo / unboard UI | Parked |
