> **Doc:** docs/GLOSSARY.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Return available pool is not isComing

# Glossary

Terms used across backend and frontend docs.

| Term | Meaning |
|------|---------|
| **C2S / CTS** | Cab Transport System — project name |
| **D2D** | Door-to-Door — live pickup logging during a batch run |
| **Batch** | Time slot (e.g. morning 5:30); has `batchTime`, `end_time` (return time label) |
| **POP** | Pick-up Point — named stop with lat/long and `inLine` (queue order) |
| **adminCode** | UUID identifying a sub-admin tenant; scopes routes, batches, cabs |
| **DTODLOG** | Daily trip log row in Postgres — one per batch per day (target state) |
| **CList** | Postgres `ArrayField` on DTODLOG — **user IDs** of commuters picked up (confirmed) |
| **DS** | Live queue state object: `{ data, D2D_id, driver }` — stored in Redis `d2d:live:…` |
| **data** (in DS) | List of `{ "<user_id>": { pickUpPoint, inLine, mobile_number, username } }` |
| **isComing** | Commuter flag: riding **morning**; not used to gate the evening available pool |
| **Live D2D** | Morning outbound trip — WebSocket-driven |
| **Return batch** | Evening return trip — REST + Redis set (separate from live D2D) |
| **Available pool** | `GET /d2d/return_batch/view/` — org commuters not confirmed on any return trip today |
| **Confirmed (return)** | `GET /d2d/return_batch/get_commuter/` — Redis set of user IDs given a return seat |
| **Running batches** | REST list of active DTODLOG rows today (`isActive=True`) |
| **Ghost trip** | Was: reconnect after STOP reactivates queue — **fixed** (close 4001) |
| **4001** | WS close: trip already ended today (`isActive=false` or `endTime` set) — not a REST stop |
| **4401 / 4403** | WS close: no session / wrong role (not ADMIN or assigned DRIVER) |
| **Fly list / live queue** | Commuters still on the trip (not yet in CList) |

## WebSocket ACTION names (counter-intuitive)

| ACTION | Who sends | Meaning |
|--------|-----------|---------|
| `REMOVE` | Driver | **Confirm pickup** — add to CList, remove from live queue |
| `DELETE` | Admin/Driver | Remove from live queue only (no CList write) |
| `ADD` | Admin | Add commuter to live queue by **user ID** (any batch, must have POP) |
| `STOP` | Driver only | End trip — finalize DTODLOG, clear live state. Admin disconnect does not send STOP |

Flutter driver UI labels green swipe "Picked up" but sends `REMOVE`.

## Redis key patterns (same Redis server, different keys)

Morning and evening **do not share keys** — ending one trip does not clear the other.

| Key pattern | Used for |
|-------------|----------|
| `d2d:live:{YYYY-MM-DD}:{batch_id}` | Morning live DS JSON ✅ |
| `{dd-mm-yyyy}_{batch_id}` | Evening return confirmed user IDs (Redis set) ✅ |

See [backend/02-data-model.md](./backend/02-data-model.md).

## Channel group name (WebSocket)

`{YYYY-MM-DD}batch{batch_id}` e.g. `2026-08-04batch1`
