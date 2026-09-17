> **Doc:** docs/setup/ADMIN_BOOTSTRAP_DRAFT.md
> **Updated:** 2026-09-10 19:20 IST
> **Session:** Required fields locked — organizationId + cab km; no collegeName/first_name

# GET /user/admin-bootstrap/ — draft body

**Auth:** `Authorization: Bearer <access>`  
**Who:** `userType` ADMIN, SUPER_ADMIN, or SUPERVISOR only (403 others)  
**Idea:** login = passport; this call = luggage (one sync for Admin app)

## Required field knowledge (LOCKED 2026-09-10)

| Need | Field | Notes |
|------|--------|------|
| Which org / “college” | **`organizationId`** | Organization table; do **not** require `collegeName` |
| Cab running baseline | **`km`** | Starting odometer / cab status entry point (not trip-leg odo photos) |
| Person display | **`username` + `mobileNumber`** | Do **not** require `first_name` / `last_name` |
| Identity | `userId`, role FKs (`batchId`, `popId`, `cabId`) | Flat IDs in bootstrap; nest on FE mapper |

Optional / when present: `routeCode`, `area`, `acType`, `isActive`, `organizations[]`.
Omit: binary thumbnails, live trip queues, passwords.

---

## Response (camelCase)

```json
{
  "status": "ok",
  "generatedAt": "2026-09-09T12:00:00+05:30",
  "adminCode": "<uuid>|null",
  "organizations": [],
  "enums": {
    "userType": ["ADMIN", "SUPER_ADMIN", "SUPERVISOR", "DRIVER", "COMMUTER", "STAFF"],
    "acType": ["AC", "NON_AC"]
  },
  "routes": [
    { "id": 1, "routeName": "", "routeCode": null, "isActive": true }
  ],
  "pickUpPoints": [
    {
      "id": 1,
      "pickUpPointName": "",
      "routeId": 1,
      "lat": null,
      "longitude": null,
      "inLine": null,
      "area": null,
      "isActive": true
    }
  ],
  "batches": [
    {
      "id": "uuid",
      "batchName": "",
      "batchTime": null,
      "endTime": null,
      "startDate": null,
      "endDate": null,
      "isActive": true
    }
  ],
  "cabs": [
    {
      "id": 1,
      "regNumber": "",
      "capacity": 0,
      "routeId": null,
      "acType": null,
      "km": 0,
      "trackingVehicleId": null,
      "isActive": true,
      "organizationId": null
    }
  ],
  "drivers": [
    {
      "driverId": 1,
      "userId": 1,
      "username": "",
      "mobileNumber": "",
      "batchId": null,
      "cabId": null,
      "isActive": true,
      "organizationId": null
    }
  ],
  "commuters": [
    {
      "commuterId": 1,
      "userId": 1,
      "username": "",
      "mobileNumber": "",
      "userType": "COMMUTER",
      "batchId": null,
      "popId": null,
      "cabId": null,
      "isComing": false,
      "hasPaid": null,
      "isActive": true,
      "organizationId": null
    }
  ],
  "today": {
    "tripDate": "2026-09-09",
    "activeMorningBatchIds": [],
    "activeReturnBatchIds": []
  }
}
```

---

## Rules
- One round-trip; FE stores into SQLite (snake_case tables already mapped)
- Omit huge photo/binary fields here (odometer photos stay on detail APIs)
- Empty arrays OK in Phase A
- Phase B: fill `organizations[]`, add `organizationId` on child rows after migrate

## Not in bootstrap
- Full DTODLOG history
- Live Redis queue contents (use sockets / live APIs)
- Password / tokens (login only)

## Implement next
- BE on JWT feature branch (auth already there)
- `GET /user/admin-bootstrap/`
- Update `API_CONTRACTS.md`
- Tell F&D keys for device tables

## FE wired (2026-09-10 IST)
- Feature: `lib/features/admin_bootstrap/` (models + repositories + providers + cache/mapper; **no screens**)
- Endpoint const: `ApiUrl.adminBootstrapUrl` = `user/admin-bootstrap/`
- Flow: JWT login / cold-start session → soft `sync()` → memory (+ SQLite on mobile)
- **Catalog SoT:** admin home counts + all list `get*` use luggage only (`ensureLuggage`). Legacy `admin*Url` list GETs are **not** called from FE catalog paths.
- Mutations: CRUD still hits entity APIs; then `refreshInBackground()` refills luggage (stale-while-revalidate; coalesced sync). Pull-to-refresh still awaits full `sync()`.
- Pull-to-refresh on admin home re-runs bootstrap; live running batches stay on `dtotLogUrl`
- Commuter form sends **`organizationId`** (not `collegeName`); display via org name
- Logout clears memory + bootstrap tables
- Cab luggage includes **`km`** (baseline running status) when BE sends it
