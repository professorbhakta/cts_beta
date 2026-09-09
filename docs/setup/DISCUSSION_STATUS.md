> **Doc:** docs/setup/DISCUSSION_STATUS.md
> **Updated:** 2026-09-09 19:50 IST
> **Session:** SUPER_ADMIN web portal + FE null-safe + SQLite v3

# Dock / CTS discussion status (single path)

**Canonical folder:** `D:\cts_beta\docs` (+ root `DOC_REGISTRY.md`, `PROJECT_BRAIN.md`, `PROMPT_SCOPE.md`, `.cursorrules`).

## Live now (code)
| Piece | Branch / PR | Notes |
|-------|-------------|--------|
| Backend tip | `professor-dock` / `gb-dock` / `p-gb-merger` @ `46c413e` | Pushed; remotes = **4 lanes only** (+ day-lane hooks) |
| JWT Phase A | in tip | Lab smoked earlier; hardening deferred |
| Org schema | in tip | Migrations **applied** on lab; `Organization` table empty (Phase B fill still open) |
| Return trip log | in tip | Tables applied; QR `?trip=return` probed OK (`return_trip_id`) |
| Admin bootstrap BE | in tip (`admin_bootstrap.py`) | `GET /user/admin-bootstrap/` |
| Flutter tip | `professor-cts` (= `gb-f&d` / `p&gb-merger`) | Admin-bootstrap + return QR Phase 2 merged; remotes = **5 lanes only** |

## Backend git lanes (cts-docker)
| Lane | Role | Status |
|------|------|--------|
| `main` | VPS / release only | **Hold** — do not FF until lab migrate OK (`ef632cd`) |
| `professor-dock` | PC lab day tip | = tip `46c413e` |
| `gb-dock` | Cloud Cursor | = tip `46c413e` |
| `p-gb-merger` | Integrate desk → later PR to main | = tip `46c413e` |

**Cleared + deleted:** `cursor/phase-a-jwt-login-9a34`, `feat/return-trip-log`, `cursor/cts-schema-org-migrate-d32b`.

## Frontend git lanes (cts_beta)
| Lane | Role |
|------|------|
| `main` | Default / no day-work |
| `professor-cts` | PC day tip (sync hub) |
| `gb-f&d` | Cloud Cursor |
| `p&gb-merger` | Integrate desk |
| `beta-ver` | **Dormant** recovery — no day-work; leave local/remote as-is |

**Cleared + deleted:** `feat/admin-bootstrap`, `cursor/return-qr-ui-prep-6f9b`, `cursor/setup-dev-environment-96cd`, `cursor/role-ui-login-routing-a855`, `cursor/commuter-driver-ui-redesign-1fbd` (navy lineage ours-merged; cream kept).

Branch map: [BRANCH_HOLD_NOTES.md](./BRANCH_HOLD_NOTES.md)

## Endpoints (Phase A + bootstrap)
- `POST /user/login` `{mobileNumber,password}` → access, refresh, user, adminCode, organizations[], supervisorOrgs[], profile
- `POST /user/refresh` `{refresh}` → `{access}`
- `GET /user/admin-bootstrap/` — Admin/Supervisor one-shot sync (Bearer)
- Header: `Authorization: Bearer <access>`
- CSRF: web/admin only; Flutter uses JWT
- Lab host: `http://127.0.0.1/` — phone/emulator: confirm current LAN IP

## Senior review (2026-09-08) — DEFERRED
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
- VPS deploy of tip → `main` (only after fuller device smoke OK)
- Senior JWT hardening (see above)
- Client pack STEP 8 device smoke (on **go**)
- Return-leg KM / org odometer / unboard UI (parked)
- Persist login orgs / SUPERVISOR `allowList` into SQLite (Phase B)
- SUPERVISOR / STAFF lab seed users (none in DB yet)

## FE match (2026-09-09)
Cloud: gap table + FE_FIX (flat/nested profile, bootstrap soft-fail) — merged to `professor-cts` via `cursor/fe-match-be-tip-e750`.
Local re-verify vs live `professor-dock` source (`46c413e`): login/refresh/bootstrap/return QR mint+scan **MATCH**. Extra **FE_FIX**: return scan disables `boarding_scan` `join_waiting` (BE return path boards only; waiting = `return_batch/add_commuter`).

## Lab migrate + API probe (2026-09-09 19:10)
- `migrate --plan` → **No planned migration operations** (org + return-trip already applied via tip/entrypoint).
- Admin login `7069036462` + refresh + `GET /user/admin-bootstrap/` → **ok** (10 batches / 10 drivers / 1500 commuters; orgs=0).
- Driver `9876544111` `GET /d2d/boarding_qr/1/?trip=return` → **ok** + `return_trip_id=1` (creates `return_trip_log`).
- Morning QR without active D2D → `trip_not_active` (expected; not a migrate fail).
- STEP 8 not run.

## SUPER_ADMIN + FE harden (2026-09-09 19:50)
- No Flutter web admin app yet → **Django `/void/`** is the web portal for org/schema ops.
- Lab **SUPER_ADMIN** `9000000000` / `password` (`is_staff` + `is_superuser`); FE treats like ADMIN (full shell).
- FE: null/empty wire fields tolerated; `return_trip_id`/`trip` stored on scan+odometer; SQLite schema **v3**.
- Stale DTODLOG `return_*` docs scrubbed.

## Next
- Device smoke JWT + admin-bootstrap + return QR (`flutter run`) when ready
- Client pack STEP 8 (only on **go**)
- Phase B org rows / fill bootstrap `organizations` from DB
- Client lock: return / evening trip **same QR boarding as morning** — see `CLIENT_RETURN_QR_NOTE.md`

## Rule
After every discussion or implementation: bump **Updated** + **Session** on touched `.md`, then DOC_REGISTRY / brain / scope before the next topic.

### RCLIST SHAPE
- User-ID list on return trip row (like morning CList), not per-rider rows.

### Live + archive
- Live: RCList user-ID list on trip.
- On End: archive table; trip keeps archive ID pointer.

### Column draft / DTODLOG return_*
- See `docs/setup/RETURN_TRIP_COLUMNS_DRAFT.md` — **done** and merged into tip.

### Admin bootstrap
- Draft: `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` — **BE + FE on day tips**.

## BHAKTA decisions (2026-09-09)
- Schema local: **green flag go** — Organization, SubAdminOrganization, Supervisor + organizationId (keep adminCode).
- Phase B: after tables exist + lab OK, fill login/bootstrap `organizations` from DB.
- Return trip: already discussed — **do not re-open**.
- JWT hardening: stay deferred.
- VPS JWT / STEP 8 / password: no new action until lab OK.
