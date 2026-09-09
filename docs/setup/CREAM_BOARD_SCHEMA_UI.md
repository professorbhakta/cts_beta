# Cream-board UI × schema draft

> **Doc:** docs/setup/CREAM_BOARD_SCHEMA_UI.md
> **Updated:** 2026-09-08 IST
> **Owner:** Sat (UI) · schema source: Dock
> **Status:** MOCKS READY — columns NOT on lab API yet (JWT Phase A only live)

## Source of truth

- Schema draft: [SCHEMA_FINAL_DRAFT.txt](./SCHEMA_FINAL_DRAFT.txt)
- Discussion status: [DISCUSSION_STATUS.md](./DISCUSSION_STATUS.md) (if present)
- Cream / brand language: cream `#F7F4EE`, yellow `#F5C400` (primary only), navy `#0B1F4A`, black `#0A0A0A`
- Wire **camelCase** in Flutter; backend SQLite may be snake_case
- **No `personType`** — Student/Staff rider = `User.userType` `COMMUTER` | `STAFF`

## List cards (slim)

| Screen | Show | Do not put on card |
|--------|------|--------------------|
| Routes | `routeName`, `routeCode`, Active (`isActive`) | org internals |
| Pick-up Points | name, `area`, stop `#` (`inLine`), route, Active | lat/long until GPS |
| Batches | name, driver, start/return times, Active | duplicate In/Out labels |
| Cabs | `regNumber`, capacity, `acType` (AC\|NON_AC), route, Active | thumbnail dump |
| Drivers | name, mobile, batch, cab, Active | — |
| Commuters | name/mobile, batch, POP, cab, Coming, `busPassNo`, Staff/Commuter chip | Area, Vehicle, AC, Shift (those live on PoP/Cab/Batch) |

## Forms / detail (full)

- **Route:** name, code, Active
- **PoP:** name, area, inLine, route, optional lat/long, Active
- **Batch:** name, start/return times, start/end dates, Active
- **Cab:** regNumber, capacity, acType, route, trackingVehicleId, Active
- **Driver:** user/name/mobile, batch, cab, Active
- **Commuter:** role (COMMUTER\|STAFF), identity, campus **or** staff block, pass (`busPassNo`, validFrom/To, isFreeOfCharge…), fees (optional Phase A), batch/POP/cab, Active, Coming
- Keep **`adminCode` + `organizationId`** on org-scoped rows (org picker later)

## Branch / merge notes

- Cream board UI lived on `cursor/commuter-driver-ui-mockups-8037` (PR 2)
- Merged into JWT Flutter branch `cursor/jwt-login-phase-a-a033` (PR 4) — cream UI wins, JWT auth wins
- **Do not wire new columns** until Dock migrates + contracts update in `docs/API_CONTRACTS.md`

## After Dock migrates

1. Update models/forms/lists to match this map
2. Refresh `docs/API_CONTRACTS.md` + this file’s Status line
3. Device-smoke each admin list + form


## Role homes (Phase A — PR #5)

**User lock:** STAFF → commuter home (same UX as COMMUTER). SUPERVISOR → admin home shell with AdminService allow-list (batch, cab, route, pop, driver, d2d, commuter). **No parallel supervisor UI** to maintain.

| Role | Home | Drawer | Cream notes |
|------|------|--------|-------------|
| ADMIN | Admin dashboard | Full MANAGEMENT + Offline (admin only) | Username title, yellow only on Add Batch |
| SUPERVISOR | **Same** admin shell | MANAGEMENT filtered by `AdminCapabilities.supervisorAllowList` | Shared shell — not a separate app. Phase A allow-list = batch/cab/route/pop/driver/d2d/commuter (looks like full admin until allow-list shrinks). Offline **hidden**. |
| STAFF | Commuter home | Commuter nav (Home / Profile / Track cab) | Same cream as COMMUTER; `isCommuterLike` |
| DRIVER / COMMUTER | unchanged | role drawers | — |

Source: `lib/app/router/admin_service.dart`, `docs/ROUTING_AND_AUTH.md`. **Lock:** Do NOT build a separate Supervisor screen/app — filter the shared admin shell only. Optional polish (same drawer): quiet role label under name (`SessionRole.roleLabel`), not a new route.


## Return boarding QR (prep)

See [RETURN_QR_UI_PREP.md](./RETURN_QR_UI_PREP.md) — same morning QR UX; stubs until Dock. Cream-pass notes live there.

