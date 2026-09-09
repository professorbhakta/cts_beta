> **Doc:** docs/setup/DISCUSSION_STATUS.md
> **Updated:** 2026-09-09
> **Session:** BE tip consolidated — JWT + return-trip + org schema + admin-bootstrap on day lanes (local)

# Dock / CTS discussion status (single path)

**Canonical folder:** `D:\cts_beta\docs` (+ root `DOC_REGISTRY.md`, `PROJECT_BRAIN.md`, `PROMPT_SCOPE.md`, `.cursorrules`).

## Live now (code)
| Piece | Branch / PR | Notes |
|-------|-------------|--------|
| Backend tip | `professor-dock` / `gb-dock` / `p-gb-merger` = `cursor/phase-a-jwt-login-9a34` @ `6311e9a` | Local FF 2026-09-09; **push pending**; `main` still 9 behind (VPS hold) |
| JWT Phase A | in tip · [cts-docker#1](https://github.com/professorbhakta/cts-docker/pull/1) | Lab smoked earlier; hardening deferred |
| Org schema | in tip · [cts-docker#2](https://github.com/professorbhakta/cts-docker/pull/2) | Migrations present; **lab migrate + smoke still open** |
| Return trip log | in tip (was `feat/return-trip-log`) | Tables, QR `?trip=return`, archives, DTODLOG `return_*` stripped |
| Admin bootstrap BE | in tip (`admin_bootstrap.py`) | `GET /user/admin-bootstrap/` |
| Flutter JWT + cream | `professor-cts` | Active FE tip |
| Flutter admin-bootstrap | `feat/admin-bootstrap` (+1 vs professor) | FE wired; merge into professor-cts next |

## Backend git lanes (cts-docker)
| Lane | Role | Status 2026-09-09 |
|------|------|-------------------|
| `main` | VPS / release only | **Hold** — do not FF until lab migrate OK |
| `professor-dock` | PC lab day-to-day | Local = tip; push pending |
| `gb-dock` | Cloud Cursor / heavy agent | Local = tip; push pending |
| `p-gb-merger` | Integrate desk → later PR to main | Local = tip; push pending |
| `feat/return-trip-log` | feature (now ancestor) | Fully inside tip |
| `cursor/cts-schema-org-migrate-d32b` | one-shot (now ancestor) | Fully inside tip |
| `cursor/phase-a-jwt-login-9a34` | JWT lab lineage | Same commit as day lanes |

Branch map detail: [BRANCH_HOLD_NOTES.md](./BRANCH_HOLD_NOTES.md)

## Endpoints (Phase A + bootstrap)
- `POST /user/login` `{mobileNumber,password}` → access, refresh, user, adminCode, organizations[], supervisorOrgs[], profile
- `POST /user/refresh` `{refresh}` → `{access}`
- `GET /user/admin-bootstrap/` — Admin/Supervisor one-shot sync (Bearer)
- Header: `Authorization: Bearer <access>`
- CSRF: web/admin only; Flutter uses JWT
- Lab host: `http://127.0.0.1/` — phone/emulator: confirm current LAN IP

## Senior review (2026-09-08) - DEFERRED (no code change)
Verified on branch; BHAKTA chose keep current behavior for small audience + easy smoke:

| Sev | Finding | Decision |
|-----|---------|----------|
| High | `login_user` always Django `login()` + JWT (Flutter also gets session cookie) | **Defer** - keep dual bridge |
| High | Access 12h / refresh 7d, no rotate/blacklist | **Defer** - keep TTLs |
| Med | `build_profile`: STAFF not explicit; leftover STUDENT | **Defer** |
| Med | Session `login()` errors only `print` | **Defer** |
| Low | Typo `serailizer`; logout session-only | **Defer** |
| Low | Cleanup commit `076abd7` not on PR #1 | Optional push later (hygiene only) |

Revisit hardening after smoke + larger audience / prod push.

## Draft / UI only
- `docs/setup/SCHEMA_FINAL_DRAFT.txt` (migrations now exist on tip — draft may lag)
- Slim schema / roles / JWT notes in `docs/setup/`
- UI map: `docs/setup/CREAM_BOARD_SCHEMA_UI.md` (Sat; mocks until migrate)

## Still open
- Lab `migrate` + smoke on consolidated tip
- Phase B: fill login/bootstrap `organizations` from DB (after migrate OK)
- VPS deploy of tip → `main` (only after lab OK)
- Senior JWT hardening (see above)
- FE: merge `feat/admin-bootstrap` → `professor-cts`; review `cursor/return-qr-ui-prep-6f9b`

## Next
- Push cts-docker day lanes (`professor-dock`, `gb-dock`, `p-gb-merger`) when BHAKTA says go
- Lab migrate org + return-trip migrations
- FE merge admin-bootstrap; then return QR branch review
- Client lock: return / evening trip **same QR boarding as morning** — see `CLIENT_RETURN_QR_NOTE.md`

## Rule
After every discussion or implementation: bump **Updated** + **Session** on touched `.md`, then DOC_REGISTRY / API_CONTRACTS / brain / scope before the next topic.

### RCLIST SHAPE
- User-ID list on return trip row (like morning CList), not per-rider rows.

### Live + archive
- Live: RCList user-ID list on trip.
- On End: archive table; trip keeps archive ID pointer.

### Column draft / DTODLOG return_*
- See `docs/setup/RETURN_TRIP_COLUMNS_DRAFT.md` — **done 2026-09-09** and **merged into tip**.

### Admin bootstrap
- Draft: `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` — **BE + FE code present**; FE still on feature branch until merge.

## BHAKTA decisions (2026-09-09)
- Schema local: **green flag go** — Organization, SubAdminOrganization, Supervisor + organizationId on resources (keep adminCode).
- Phase B: after tables exist + lab OK, fill login/bootstrap `organizations` from DB.
- Return trip: already discussed — **do not re-open**.
- JWT hardening: stay deferred.
- VPS JWT / STEP 8 / password: no new action from BHAKTA until lab OK.
