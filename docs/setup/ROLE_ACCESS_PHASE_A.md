> **Doc:** docs/setup/ROLE_ACCESS_PHASE_A.md
> **Updated:** 2026-09-09 20:15 IST
> **Session:** + SUPER_ADMIN (full shell + web /void/)
> **Owner:** F&D (+ Sat docs eye)

# Role access (Phase A UI)

## Decision
**No separate Supervisor app/screen.** SUPERVISOR uses the **shared admin shell** with capability filtering.  
**No separate Flutter web admin yet** — SUPER_ADMIN uses Django `/void/` for web org/schema ops.

| userType | Home | Notes |
|----------|------|-------|
| ADMIN | Admin home | Full `AdminService` catalog |
| SUPER_ADMIN | Admin home | Same full catalog as ADMIN; **web** = Django `/void/` |
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
