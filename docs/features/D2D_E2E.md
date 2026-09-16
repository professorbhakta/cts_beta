> **Doc:** docs/features/D2D_E2E.md
> **Updated:** 2026-09-12 16:00 IST
> **Session:** Thinned — owners are FLOWS + API_CONTRACTS + d2d README

# Morning D2D — E2E pointer

Full phase tables lived here; **canonical owners** now:

| Need | Owner |
|------|--------|
| Click-paths / smoke | [FLOWS_BY_ROLE](../FLOWS_BY_ROLE.md) |
| REST + WS wire | [API_CONTRACTS](../API_CONTRACTS.md) |
| Flutter UI / files | [lib/features/d2d/README](../../lib/features/d2d/README.md) |
| Lab / Docker | [LOCAL_DEV](../LOCAL_DEV.md) |

## Flow (one screen)

1. Commuter Mark Coming → DB `isComing`
2. Driver WS connect → DTODLOG + Redis live → snapshot
3. Admin joins same WS group (monitor only)
4. REMOVE / DELETE / ADD → broadcast; QR scan boards via shared `board_commuter`
5. Driver STOP → finalize + 4001 on reconnect same day

**Close codes:** 4401 auth · 4403 role · 4001 ended.

Evening return: [RETURN_BATCH_E2E.md](./RETURN_BATCH_E2E.md) (also thinned).
