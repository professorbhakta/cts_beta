> **Doc:** docs/setup/ROLE_ACCESS_PHASE_A.md
> **Updated:** 2026-09-08
> **Session:** PR #5 role UI — no separate Supervisor screen
> **Owner:** F&D (+ Sat docs eye)

# Role access (Phase A UI)

## Decision
**No separate Supervisor app/screen.** SUPERVISOR uses the **shared admin shell** with capability filtering.

| userType | Home | Notes |
|----------|------|--------|
| ADMIN | Admin home | Full `AdminService` catalog |
| SUPERVISOR | Admin home (filtered) | Allow-list only |
| STAFF | Commuter home | Same UX as COMMUTER; **not** admin-like |
| COMMUTER | Commuter home | Unchanged |
| DRIVER | Driver home | Unchanged |

## SUPERVISOR allow-list (`AdminService`)
`batch`, `cab`, `route`, `pop`, `driver`, `d2d`, `commuter`

Gates: dashboard tiles, drawer MANAGEMENT, route redirects (`resolveAuthRedirect`).

## Code / PR
- Branch: `cursor/role-ui-login-routing-a855`
- PR: https://github.com/professorbhakta/cts_beta/pull/5 → `professor-cts`
- Enum: `lib/app/router/admin_service.dart`
- Wire docs: `docs/ROUTING_AND_AUTH.md`

## Cream / schema
List/form field maps stay in [CREAM_BOARD_SCHEMA_UI.md](./CREAM_BOARD_SCHEMA_UI.md). Role chips: Staff vs Commuter = `userType` only (no personType).
