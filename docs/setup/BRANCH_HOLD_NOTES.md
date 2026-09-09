# Branch notes — keep-5 remotes (docs-first)

Updated: 2026-09-09
Owner: F&D

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
| `professor-cts` | PC day tip (sync hub) |
| `gb-f&d` | Cloud Cursor lane |
| `p&gb-merger` | Integrate desk |
| `beta-ver` | Recovery |

**Cleared into `professor-cts` (2026-09-09):**
- `feat/admin-bootstrap` — merged (FF)
- `cursor/return-qr-ui-prep-6f9b` — merged (return QR Phase 2)
- `cursor/setup-dev-environment-96cd` — merged (`AGENTS.md`)
- `cursor/commuter-driver-ui-redesign-1fbd` — lineage absorbed with `-s ours` (**cream UI kept**; navy not applied)
- `cursor/role-ui-login-routing-a855` — already in tip via PR #5 (delete only)

Remote list: [cts_beta/branches](https://github.com/professorbhakta/cts_beta/branches)

## cts-docker (backend) — next clear pass

Still has feature/cursor branches; day tip local FF pending push. Keep target (mirror): `main`, `professor-dock`, `gb-dock`, `p-gb-merger`, + one recovery if needed.
