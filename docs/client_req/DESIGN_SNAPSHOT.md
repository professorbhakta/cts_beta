> **Doc:** docs/client_req/DESIGN_SNAPSHOT.md
> **Updated:** 2026-08-26 07:58 IST
> **Session:** Option B — thin design snapshot replacing deleted 00–04 / 06

# Client pack — design snapshot

**Why this file exists:** Design MDs `00–04` and `06` were removed during the build chat. This **one** snapshot keeps the durable inventorable (tables, APIs, DT↔API, safety) without restoring the full diary.

| Need | Go here instead |
|------|-----------------|
| Product story + D1–D10 | [05-open-decisions.md](05-open-decisions.md) |
| Click-paths / smoke table | [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) |
| Live wire errors | [API_CONTRACTS.md](../API_CONTRACTS.md) § Client pack |
| Where we left off | [DISCUSSION_LOG.md](DISCUSSION_LOG.md) |
| STEP 8 script | [07-NEXT-AGENT-PROMPT.md](07-NEXT-AGENT-PROMPT.md) |

---

## 1. Problem → solution (one screen)

| Pain | Solution |
|------|----------|
| Driver cannot swipe ~50+ pickups while driving | **Commuter scans** cab QR → boarded (`CList` / Already IN); swipe = fallback |
| Need daily cab run KM with optional proof | Driver enters **start/end KM** (± camera photo); Close/Skip allowed |

**Repos:** `cts-docker` (`d2d_log`) first → Flutter → device smoke.

---

## 2. Data safety (locked)

- Prefer **existing** `DTODLOG` + **nullable** new columns (old rows stay NULL).
- **No** `CabTripOdometer` table (unless later required).
- **No** `BoardingEvent` table — **SKIP**; who boarded = `CList` only.
- Never `NOT NULL` without default on populated tables; no drop/type-rewrite of old columns.
- Redis live / return key formats and WS ACTION names unchanged.
- Media: files on disk (`MEDIA` + volume); DB stores **paths** only (not BYTEA).

---

## 3. Schema — `DTODLOG` additive columns

Existing unchanged: `CList`, `batchId`, `tripDate`, `startTime`, `endTime`, `isActive`, unused `return_*_time`.

| New column (all null/blank OK) | Use |
|--------------------------------|-----|
| `morning_start_km` / `morning_end_km` | Morning odometer |
| `morning_start_photo` / `morning_end_photo` | Optional FileFields |
| `morning_start_recorded_at` / `morning_end_recorded_at` | Timestamps |
| `return_start_km` / `return_end_km` | Return leg (API ready; Flutter UI parked) |
| `return_*_photo` / `return_*_recorded_at` | Same |

**Submit rules:** KM **required** on Confirm; photo **optional**. Close/Skip = no write.

**Not a table:** boarding QR = signed short-lived token; invalid when trip not `isActive`.

---

## 4. APIs (7 REST + shared board)

All under `/d2d/`, session cookie. Detail + errors: API_CONTRACTS.

| # | Method | Path | Who | Writes / reads |
|---|--------|------|-----|----------------|
| 1 | POST | `/d2d/odometer/start/` | Driver/Admin | DTODLOG start KM ± photo |
| 2 | POST | `/d2d/odometer/end/` | Driver/Admin | DTODLOG end KM ± photo |
| 3 | GET | `/d2d/odometer/<batch_id>/` | Driver/Admin | Read odo snapshot |
| 4 | GET | `/d2d/odometer/org/<admin_code>/` | Admin | Org list (UI parked) |
| 5 | GET | `/d2d/boarding_qr/<batch_id>/` | Driver/Admin | Token (no DB write) |
| 6 | POST | `/d2d/boarding_scan/` | Commuter | CList + Redis + broadcast |
| 7 | POST | `/d2d/boarding_unboard/` | Driver/Admin | Reverse board (UI parked) |
| — | GET | `/d2d/odometer/photo/…` | Driver/Admin | Auth download (D6) |

**WS (unchanged wire):** `connect` / `REMOVE` / `DELETE` / `ADD` / `STOP`.  
`REMOVE` + `boarding_scan` → shared `board_commuter()` + `group_send`.

**Eligibility (scan):** Coming / in live queue; home batch; capacity; idempotent if already in CList.

---

## 5. DT ↔ API map

```text
DTODLOG + Redis live     ← who is waiting / Already IN (CList)
DTODLOG odo columns      ← morning/return KM + optional photo paths
Media files              ← photo bytes (auth URL on GET odometer)
Signed QR token          ← issued by boarding_qr; consumed by boarding_scan
```

| Store | Written by | Read by |
|-------|------------|---------|
| DTODLOG CList + Redis | WS REMOVE, boarding_scan, unboard | WS clients, status |
| DTODLOG odo cols + files | odometer start/end | odometer GET / photo |
| Token (not stored) | boarding_qr | boarding_scan |

---

## 6. Flutter surfaces (shipped)

| Surface | Behavior |
|---------|----------|
| `OdometerKmSheet` | Close (top) / Skip (bottom) / Confirm; no swipe-dismiss; KM required; photo optional |
| `boarding_qr_panel` | Driver live log; wakelock + refresh |
| `boarding_scan_screen` | Commuter route `boardingScan` |
| Admin channel | Watch only — no QR |

**Parked UI:** return-leg KM sheet, org odometer list, unboard UI.

---

## 7. Build order (done → left)

1. MEDIA + volume + nginx body size — **done**  
2. Null cols on DTODLOG — **done**  
3. Odometer REST — **done**  
4. `board_commuter` + REMOVE — **done**  
5. QR + scan (+ unboard BE) — **done**  
6. Flutter UI 1–7 — **done** (photo Close/Skip fix 2026-08-26)  
7. Device smoke STEP 8 — **await user go**  
8. Optional more `test/features/d2d/` — open  

---

## 8. Example day (tests / QA)

| Leg | Start KM | End KM |
|-----|----------|--------|
| Morning | 25678 | 25702 |
| Return | 25707 | 25735 |

Photos optional on each reading.
