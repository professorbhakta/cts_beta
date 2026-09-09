# Branch notes — keep-5 remotes (docs-first)

Updated: 2026-09-09 20:30 IST
Owner: F&D
Session: tip SHAs — FE `0524868` · BE `98ebc66`

## This-machine auto-sync (locked)

On this PC, day lanes are the **online ↔ offline sync hub**:

| Repo | Day branch | Remote |
|------|------------|--------|
| `D:\cts-docker` | `professor-dock` | https://github.com/professorbhakta/cts-docker/tree/professor-dock |
| `D:\cts_beta` | `professor-cts` | https://github.com/professorbhakta/cts_beta/tree/professor-cts |

**Loop:** `sessionStart` → pull (ff-only, if clean) · work/commit · `stop` → push unpushed commits. Offline keeps local commits; sync resumes when network is back.

Enforced by: user rule `machine-day-lane-auto-push.mdc` · project `.cursor/rules/day_lane_auto_push.mdc` · `.cursor/hooks/day-lane-sync.ps1` + `hooks.json`.  
Still never auto-push `main`. No force-push.

## cts_beta — keep only these 5 remotes

| Branch | Role |
|--------|------|
| `main` | Default / do not day-work |
| `professor-cts` | PC day tip (sync hub) @ `0524868` |
| `gb-f&d` | Cloud Cursor lane |
| `p&gb-merger` | Integrate desk |
| `beta-ver` | **Dormant** recovery — do not day-work; local checkout drift OK; tip is `professor-cts` |

**Cleared into `professor-cts` (2026-09-09):**
- `feat/admin-bootstrap` — merged (FF)
- `cursor/return-qr-ui-prep-6f9b` — merged (return QR Phase 2)
- `cursor/setup-dev-environment-96cd` — merged (`AGENTS.md`)
- `cursor/commuter-driver-ui-redesign-1fbd` — lineage absorbed with `-s ours` (**cream UI kept**; navy not applied)
- `cursor/role-ui-login-routing-a855` — already in tip via PR #5 (delete only)

Remote list: [cts_beta/branches](https://github.com/professorbhakta/cts_beta/branches)

## cts-docker (backend) — keep only these 4 remotes

| Branch | Role |
|--------|------|
| `main` | VPS / release only (hold until fuller device smoke OK) |
| `professor-dock` | PC lab day tip (sync hub) @ `98ebc66` (SUPER_ADMIN) |
| `gb-dock` | Cloud Cursor lane — align when asked |
| `p-gb-merger` | Integrate desk — align when asked |

**Cleared into day tip + deleted (2026-09-09):**
- `cursor/phase-a-jwt-login-9a34` — JWT Phase A (already at tip)
- `feat/return-trip-log` — return tables / QR
- `cursor/cts-schema-org-migrate-d32b` — org schema migrations

Remote list: [cts-docker/branches](https://github.com/professorbhakta/cts-docker/branches)
