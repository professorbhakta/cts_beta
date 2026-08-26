> **Doc:** docs/client_req/07-NEXT-AGENT-PROMPT.md
> **Updated:** 2026-08-25 22:05 IST
> **Session:** Smoke script; story→05; journeys→FLOWS

# Next-agent prompt — client QR + odometer

**Current:** STEP 8 device smoke — only after user **go**.  
**Shipped:** BE + Flutter UI STEPS 1–7 + nginx 8m + Postgres backup.

| Need | Read |
|------|------|
| Product story + D1–D10 | [05-open-decisions.md](05-open-decisions.md) |
| Where we left off | [DISCUSSION_LOG.md](DISCUSSION_LOG.md) |
| Click-paths / QA table | [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) § Morning QR+KM |
| Wire / UI detail | [API_CONTRACTS](../API_CONTRACTS.md) · [d2d/README](../../lib/features/d2d/README.md) |
| BE↔FE map | [PROJECT_BRAIN §10](../../PROJECT_BRAIN.md#10-deep-docs--stable-befe-map) |

**This file is the smoke script only** — not the design diary. Attach order LOCKED (brain §3).

---

## STEP 8 — COPY FROM HERE

```text
You are continuing CTS client pack — STEP 8 device smoke ONLY.

ATTACH (order):
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
@docs/client_req/DISCUSSION_LOG.md
@docs/client_req/07-NEXT-AGENT-PROMPT.md
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
@docs/FLOWS_BY_ROLE.md

REPOS: D:\cts_beta (beta-ver) · D:\cts-docker

RULES:
- Run smoke ONLY if user said go. Else update DISCUSSION_LOG and stop.
- Prefer keep live sessions. No commit/push unless asked. No merge to main.
- Do not reopen D1–D10 / BoardingEvent SKIP / schema.
- Journeys: FLOWS_BY_ROLE § Morning QR+KM. Story/locks: 05. Pointer: DISCUSSION_LOG.

SMOKE (morning Batch-01) — same table as FLOWS:
1. Emulator admin 7069036462 / password — watch channel
2. Phone driver 9876544111 / password — START TRIP
3. Start KM sheet — KM required, photo optional; Close/Skip leave without record (no swipe)
4. Driver QR visible; commuter Mark Coming → Scan boards (Already IN)
5. One swipe REMOVE fallback still works
6. End KM sheet (same Close/Skip/optional photo) → STOP
7. Report pass/fail; update DISCUSSION_LOG + PROJECT_BRAIN §5

LAN: PROJECT_BRAIN §5 / LOCAL_DEV.md
New unit tests (if adding): test/features/d2d/ — do not restore widget_test.dart
```

---

## Shipped (do not re-implement)

| Step | Result |
|------|--------|
| BE | MEDIA, DTODLOG null odo cols, 7 REST, board_commuter |
| UI 1–7 | pkgs+perms, helpers, odo sheet, wire start/end, driver QR, commuter scan, analyze |
| Ops | nginx `client_max_body_size 8m`, Postgres backup sidecar |
| Docs | 01–04 + guides retired; FLOWS owns QR/KM journeys |

**Parked:** return-leg KM UI, admin org odometer list, unboard UI.

---

## Short START

```text
@PROJECT_BRAIN.md @PROMPT_SCOPE.md @docs/client_req/DISCUSSION_LOG.md @docs/client_req/07-NEXT-AGENT-PROMPT.md @docs/FLOWS_BY_ROLE.md
CTS client pack STEP 8 smoke — only if user said go. Paste "STEP 8 — COPY FROM HERE".
```
