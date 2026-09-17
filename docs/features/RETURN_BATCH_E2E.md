> **Doc:** docs/features/RETURN_BATCH_E2E.md
> **Updated:** 2026-09-12 16:00 IST
> **Session:** Thinned — owners are FLOWS + API_CONTRACTS + batches README

# Evening return — E2E pointer

Full phase tables lived here; **canonical owners** now:

| Need | Owner |
|------|--------|
| Click-paths | [FLOWS_BY_ROLE](../FLOWS_BY_ROLE.md) |
| REST wire | [API_CONTRACTS](../API_CONTRACTS.md) § Return batch |
| Flutter UI / files | [lib/features/batches/README](../../lib/features/batches/README.md) |
| Return QR | [setup/RETURN_QR_UI_PREP](../setup/RETURN_QR_UI_PREP.md) |

## Flow (one screen)

1. Admin/driver open return picker → `GET status` cards
2. Available = `GET view` (`home[]` + `overflow[]` from `isComing`)
3. Confirm → `POST add_commuter` (capacity); Remove → `remove_commuter`
4. Confirmed hydrate via `GET get_commuter`
5. Driver End → `POST end` clears Redis; riders Mark Coming again later

**Not WebSocket** — pull refresh. Morning D2D: [D2D_E2E.md](./D2D_E2E.md).
