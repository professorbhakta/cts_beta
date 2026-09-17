> **Doc:** docs/setup/DISCUSSION_STATUS.md
> **Updated:** 2026-09-17 15:08 IST
> **Session:** enrichment live tip 934fb02; PR #9 → gb-f&d

# Dock / CTS discussion status (single path)

**Canonical folder:** `D:\cts_beta\docs` (+ root `DOC_REGISTRY.md`, `PROJECT_BRAIN.md`, `PROMPT_SCOPE.md`, `.cursorrules`).  
**Handoff pointer:** this file (ex–client_req/DISCUSSION_LOG). Product locks: [FLOWS_BY_ROLE](../FLOWS_BY_ROLE.md). Wire: [API_CONTRACTS](../API_CONTRACTS.md).


## Open-trip auto-close + daily report (LOCKED 2026-09-12) — green flag GO
- Remind driver + alert Admin/Supervisor if morning/return started and not ended.
- Auto-close Asia/Calcutta: **morning 12:00 PM**, **return 12:00 AM**.
- Auto-close: `end_km = start_km`, mark **incomplete**, `endTime` + `isActive=false`, archive like End.
- Admin + Supervisor may edit `end_km`; show status **edited**.
- Daily trip report (mobile + web) so they can check the day.
- **BE tip (lab smoke / photos + boarded + enrichment):** `professor-dock` @ `934fb02` — trip_report legs include `start_photo_url` / `end_photo_url` (**A**), **`boarded[]`** (`user_id`, `boarded_at`, `source`; `[]` if none), and **enrichment live** (`boarded[].name`/`mobile`, `boarded_count`, `driver_name`, `driver_user_id`). Do not wait on `gb-dock` merge.
- **FE:** Provider module `lib/features/trip_report/` — daily report + edit_end_km + **odometer thumbs** (prefer A; silent B) + **boarded riders list** per leg (uses enrichment when present). Contract [TRIP_AUTO_CLOSE_CONTRACT.md](./TRIP_AUTO_CLOSE_CONTRACT.md). No FCM/web UI this pass. PR → `gb-f&d`.

## Live now (code)
| Piece | Branch / PR | Notes |
|-------|-------------|--------|
| Backend tip | `professor-dock` day lane | SUPER_ADMIN; bootstrap emits **km** + **organizationId** + **organizations[]** |
| JWT Phase A | in tip | Lab API probed; hardening deferred |
| Org schema | in tip | Migrations applied; lab **org rows seeded** (bootstrap orgs=1 verified 2026-09-10) |
| Return trip log | in tip | Tables applied; QR `?trip=return` probed OK (wire `return_trip_id`) |
| Admin bootstrap BE | in tip | `GET /user/admin-bootstrap/` Ã¢â‚¬â€ ADMIN / SUPER_ADMIN / SUPERVISOR |
| Flutter tip | `professor-cts` + cloud → `gb-f&d` | Catalog SoT = bootstrap; trip report + **odo photo thumbs**; SQLite **v4** |

## Backend git lanes (cts-docker)
| Lane | Role | Status |
|------|------|--------|
| `main` | VPS / release only | **Hold** Ã¢â‚¬â€ do not FF until fuller device smoke OK |
| `professor-dock` | PC lab day tip | = tip `934fb02` (trip_report photos A + boarded + enrichment) |
| `gb-dock` | Cloud Cursor | align when asked |
| `p-gb-merger` | Integrate desk Ã¢â€ â€™ later PR to main | align when asked |

**Cleared + deleted:** `cursor/phase-a-jwt-login-9a34`, `feat/return-trip-log`, `cursor/cts-schema-org-migrate-d32b`.

## Frontend git lanes (cts_beta)
| Lane | Role |
|------|------|
| `main` | Default / no day-work |
| `professor-cts` | PC day tip (sync hub) |
| `gb-f&d` | Cloud Cursor |
| `p&gb-merger` | Integrate desk |
| `beta-ver` | **Dormant** recovery Ã¢â‚¬â€ no day-work; leave local/remote as-is |

**Cleared + deleted:** `feat/admin-bootstrap`, `cursor/return-qr-ui-prep-6f9b`, `cursor/setup-dev-environment-96cd`, `cursor/role-ui-login-routing-a855`, `cursor/commuter-driver-ui-redesign-1fbd` (navy lineage ours-merged; cream kept).

Branch map: [BRANCH_HOLD_NOTES.md](./BRANCH_HOLD_NOTES.md)

## Endpoints (Phase A + bootstrap)
- `POST /user/login` `{mobileNumber,password}` Ã¢â€ â€™ access, refresh, user, adminCode, organizations[], supervisorOrgs[], profile
- `POST /user/refresh` `{refresh}` Ã¢â€ â€™ `{access}`
- `GET /user/admin-bootstrap/` Ã¢â‚¬â€ ADMIN / SUPER_ADMIN / SUPERVISOR one-shot sync (Bearer)
- Header: `Authorization: Bearer <access>`
- CSRF: web/admin only; Flutter uses JWT
- Lab host: `http://127.0.0.1/` Ã¢â‚¬â€ phone/emulator: confirm current LAN IP
- Lab SUPER_ADMIN (web `/void/`): `9000000000` / `password`

## Senior review (2026-09-08) Ã¢â‚¬â€ DEFERRED
Verified on branch; BHAKTA chose keep current behavior for small audience + easy smoke:

| Sev | Finding | Decision |
|-----|---------|----------|
| High | `login_user` always Django `login()` + JWT (Flutter also gets session cookie) | **Defer** |
| High | Access 12h / refresh 7d, no rotate/blacklist | **Defer** |
| Med | `build_profile`: STAFF not explicit; leftover STUDENT | **Defer** |
| Med | Session `login()` errors only `print` | **Defer** |
| Low | Typo `serailizer`; logout session-only | **Defer** |

## Still open
- Phase B: fill login/bootstrap `organizations` from DB (tables exist; org rows still 0)
- VPS deploy of tip Ã¢â€ â€™ `main` (only after fuller device smoke OK)
- Senior JWT hardening (see above)
- Client pack STEP 8 device smoke (on **go**) Ã¢â‚¬â€ [FLOWS](../FLOWS_BY_ROLE.md) Ã‚Â· [STEP8 checklist](../STEP8_DEVICE_SMOKE_CHECKLIST.txt)
- Return-leg KM / org odometer / unboard UI (parked)
- Persist login orgs / SUPERVISOR `allowList` into SQLite (Phase B)
- SUPERVISOR / STAFF lab seed users (none in DB yet)

## FE match (2026-09-09)
Cloud: gap table + FE_FIX (flat/nested profile, bootstrap soft-fail) Ã¢â‚¬â€ merged to `professor-cts` via `cursor/fe-match-be-tip-e750`.
Local re-verify vs live `professor-dock` source (then `46c413e`; tip now `98ebc66` + SUPER_ADMIN): login/refresh/bootstrap/return QR mint+scan **MATCH**. Extra **FE_FIX**: return scan disables `boarding_scan` `join_waiting` (BE return path boards only; waiting = `return_batch/add_commuter`).

## Lab migrate + API probe (2026-09-09 19:10)
- `migrate --plan` Ã¢â€ â€™ **No planned migration operations** (org + return-trip already applied via tip/entrypoint).
- Admin login `7069036462` + refresh + `GET /user/admin-bootstrap/` Ã¢â€ â€™ **ok** (10 batches / 10 drivers / 1500 commuters; orgs=0).
- Driver `9876544111` `GET /d2d/boarding_qr/1/?trip=return` Ã¢â€ â€™ **ok** + `return_trip_id=1` (creates `return_trip_log`).
- Morning QR without active D2D Ã¢â€ â€™ `trip_not_active` (expected; not a migrate fail).
- STEP 8 not run.

## SUPER_ADMIN + FE harden (2026-09-09 19:50)
- No Flutter web admin app yet Ã¢â€ â€™ **Django `/void/`** is the web portal for org/schema ops.
- Lab **SUPER_ADMIN** `9000000000` / `password` (`is_staff` + `is_superuser`); FE treats like ADMIN (full shell).
- FE: null/empty wire fields tolerated; Dart **`returnTripLogId`** Ã¢â€ Â `return_trip_id`, **`tripLeg`** Ã¢â€ Â `trip` on mint/scan/odometer; SQLite schema **v3**.
- Stale DTODLOG `return_*` docs scrubbed.

## Next
- Device smoke JWT + admin-bootstrap + return QR (`flutter run`) when ready
- Client pack STEP 8 (only on **go**)
- Phase B org rows / fill bootstrap `organizations` from DB
- Client lock: return / evening trip **same QR boarding as morning** â€” [RETURN_QR_UI_PREP](./RETURN_QR_UI_PREP.md)

## Rule
After every discussion or implementation: bump **Updated** + **Session** on touched `.md`, then DOC_REGISTRY / brain / scope before the next topic.

### RCLIST SHAPE
- User-ID list on return trip row (like morning CList), not per-rider rows.

### Live + archive
- Live: RCList user-ID list on trip.
- On End: archive table; trip keeps archive ID pointer.

### Column draft / return odometer
- Return odo on `ReturnTripLog` â€” [SCHEMA_FINAL_DRAFT](./SCHEMA_FINAL_DRAFT.txt) (**done**). DTODLOG `return_*` **removed**.

### Admin bootstrap
- Draft: `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` Ã¢â‚¬â€ **BE + FE on day tips**
- **Required (LOCKED):** `organizationId` (not `collegeName`); cab `km` (baseline running); `username`+`mobileNumber` (not first/last name)
- Lab probe 2026-09-10: orgs=1, cabs include km, commuters include organizationId

## BHAKTA decisions (2026-09-09 + 2026-09-10)
- Schema local: **green flag go** Ã¢â‚¬â€ Organization, SubAdminOrganization, Supervisor + organizationId (keep adminCode).
- **App identity for Ã¢â‚¬Å“collegeÃ¢â‚¬Â = `organizationId`** Ã¢â‚¬â€ do not require `collegeName` / `first_name` / `last_name`.
- Phase B: richer org fill / login `organizations` from DB (lab already has Ã¢â€°Â¥1 org in bootstrap).
- Return trip: already discussed Ã¢â‚¬â€ **do not re-open**.
- JWT hardening: stay deferred.
- VPS JWT / STEP 8 / password: no new action until lab OK.
