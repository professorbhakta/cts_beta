> **Doc:** docs/setup/ADMIN_BOOTSTRAP_DRAFT.md
> **Updated:** 2026-09-09 20:15 IST
> **Session:** + SUPER_ADMIN; SQLite schema v3; null fields OK

# GET /user/admin-bootstrap/ — draft body

**Auth:** `Authorization: Bearer <access>`  
**Who:** `userType` ADMIN, SUPER_ADMIN, or SUPERVISOR only (403 others)  
**Idea:** login = passport; this call = luggage (one sync for Admin app)

Scope today (Phase A on tip — org **migrations applied** on lab; org **rows may still be empty**):
- Filter by caller’s `adminCode` (subAdmin id) like existing APIs
- `organizations` / rich org fields may be `[]` until Phase B fill
- `routeCode` / `area` / `acType` / `organizationId` may be **null** — FE stores NULL, does not crash
- SUPERVISOR: same shape; only orgs/batches they may touch (when Supervisor rows exist; else same as admin for dummy)
- SUPER_ADMIN: same luggage as ADMIN; web org ops also via Django `/void/`

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
      "trackingVehicleId": null,
      "isActive": true
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
      "isActive": true
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
      "isActive": true
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

## FE wired (2026-09-09 IST)
- Feature: `lib/features/admin_bootstrap/` (models + repositories + providers; **no screens**)
- Endpoint const: `ApiUrl.adminBootstrapUrl` = `user/admin-bootstrap/`
- Flow: JWT login (ADMIN / SUPER_ADMIN / SUPERVISOR) → soft-fail `AdminBootstrapRepository.sync()` → SQLite snake_case (**schema v3**)
- Empty `organizations` / null `routeCode`/`area`/`acType`/`organizationId` tolerated Phase A
- Logout clears bootstrap tables via `AppDatabase.clearAll()`
