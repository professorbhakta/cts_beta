> **Doc:** docs/client_req/05-open-decisions.md
> **Updated:** 2026-08-26 07:53 IST
> **Session:** Photo optional; Close + Skip on odometer sheet

# Open decisions & product story

**Journeys / click-paths:** [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) (incl. QR + KM).  
**Schema / APIs / DT↔API:** [DESIGN_SNAPSHOT.md](DESIGN_SNAPSHOT.md).  
**Handoff pointer only:** [DISCUSSION_LOG.md](DISCUSSION_LOG.md) — do not put product rules there.  
**Smoke script:** [07-NEXT-AGENT-PROMPT.md](07-NEXT-AGENT-PROMPT.md).  
**Wire / UI detail:** [API_CONTRACTS.md](../API_CONTRACTS.md) · [d2d/README.md](../../lib/features/d2d/README.md).

---

## Product story (durable)

**Problem:** Driver cannot swipe-confirm ~50+ pickups while driving; also need daily cab run KM with proof.

**Morning solution (shipped UI):**
1. Driver **START TRIP** → odometer sheet: **KM required**, **photo optional**. **Close** (top) / **Skip** (bottom) leave without recording (no swipe-dismiss). Confirm submits KM (± photo).
2. Driver shows **cab QR** on the live screen (admin watches channel — no QR).
3. Commuter turns **Coming** ON → **scans** QR → **boarded** (same as WS REMOVE / Already IN).
4. Swipe “Picked up” stays as **fallback**.
5. Driver **end KM** (± photo) → **STOP TRIP** (soft if odometer skipped via Close/Skip).

**Roles:** Admin creates accounts + watches live; Driver runs trip + QR + KM; Commuter Coming + Scan.

**Out of MVP / parked:** return-trip QR boarding; return-leg KM UI; admin org odometer list; unboard UI; `BoardingEvent` table (CList only).

---

## Implementation gate

Pack started with `let's start client feature`. Remaining: **STEP 8 device smoke** (user says **go**).

Discuss / refine: update DISCUSSION_LOG pointer. Do not reopen D1–D10 unless user asks.

---

## Recommended defaults (accept unless overturned)

| # | Decision | Default |
|---|----------|---------|
| D1 | Hard-block WS STOP until morning odometer end? | **No** — soft `complete` flag |
| D2 | Must `isComing` / live queue before scan? | **Yes** |
| D3 | Scan only home batch? | **Yes** (v1) |
| D4 | `BoardingEvent` table in v1? | **No — SKIP (locked)** — CList only |
| D5 | Un-board API in v1? | **Yes** BE; Flutter UI parked |
| D6 | Media public nginx vs auth download? | **Auth download** for photos |
| D7 | Return odometer in same migration/APIs? | **Yes**; Flutter return UI later |
| D8 | Scan = boarded (not queue-only)? | **Yes** |
| D9 | Who scans? | **Commuter scans cab QR** |
| D10 | OCR for KM? | **No** (v1) |

---

## Topic agenda (closed design)

| ID | Topic | Status |
|----|--------|--------|
| T1-T7 | Product + APIs + media | **Done** (shipped) |
| T8 | Phased delivery & tests | **STEP 8 smoke left** |
| T9 | Risks / ops | Ongoing (backup/nginx done; TLS/CI later) |

---

## Queue ID (PROMPT_SCOPE)

`Q-client-qr-odo` — STEP 8 on user **go**.
