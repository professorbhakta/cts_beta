> **Doc:** docs/setup/DISCUSSION_STATUS.md
> **Updated:** 2026-09-09
> **Session:** Branch hygiene — beta-ver dormant; day-lane lock sync

# Dock / CTS discussion status (single path)

**Canonical folder:** `D:\cts_beta\docs` (+ root `DOC_REGISTRY.md`, `PROJECT_BRAIN.md`, `PROMPT_SCOPE.md`, `.cursorrules`).

## Live now (code)
| Piece | Branch / PR | Notes |
|-------|-------------|--------|
| Backend tip | `professor-dock` / `gb-dock` / `p-gb-merger` @ `46c413e` | Pushed; remotes = **4 lanes only** (+ day-lane hooks) |
| JWT Phase A | in tip | Lab smoked earlier; hardening deferred |
| Org schema | in tip | Migrations present; **lab migrate + smoke still open** |
| Return trip log | in tip | Tables, QR `?trip=return`, archives, DTODLOG `return_*` stripped |
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
- Lab `migrate` + smoke on consolidated BE tip
- Phase B: fill login/bootstrap `organizations` from DB (after migrate OK)
- VPS deploy of tip → `main` (only after lab OK)
- Senior JWT hardening (see above)
- Client pack STEP 8 device smoke (on **go**)

## Next
- **FE match pass** — paste [FE_MATCH_BE_TIP_CONTINUE_PROMPT.txt](./FE_MATCH_BE_TIP_CONTINUE_PROMPT.txt)
- Lab migrate org + return-trip migrations on `professor-dock`
- Device smoke JWT + admin-bootstrap + return QR
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
