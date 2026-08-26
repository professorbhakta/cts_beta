> **Doc:** docs/TESTING.md
> **Updated:** 2026-08-25 22:05 IST
> **Session:** Smoke points at FLOWS QR/KM table

# Testing

How to verify the CTS app today and what to expand next.

**See also:** [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) · [API_CONTRACTS.md](./API_CONTRACTS.md) · [LOCAL_DEV.md](./LOCAL_DEV.md)

---

## Run

```bash
flutter test
flutter analyze
```

New tests: `test/features/<name>/` mirroring `lib/features/`.  
**Client pack (QR + odometer):** add under `test/features/d2d/` (existing: `client_pack_repository_test.dart`).

Default Flutter `widget_test.dart` was **removed** — do not restore a theme-only placeholder; write real feature tests instead.

---

## Automated suite (current)

| Area | Path |
|------|------|
| API contract | `test/api/api_response_contract_test.dart` |
| Auth / router | `test/app/router/`, `test/data/`, `test/domain/` |
| Core | `test/core/lifecycle/`, `network/`, `concurrency/` |
| D2D + client pack | `test/features/d2d/` |
| Batches / return | `test/features/batches/` |
| Commuters | `test/features/commuters/` |
| Network UX | `test/features/network/` |
| Utils | `test/utils/sort_utils_test.dart` |

---

## Pre-push gate (required before `git push`)

**Unit tests + analyze are necessary but not sufficient.** Before pushing any P-branch:

1. Backend reachable (`.env` LAN — see PROJECT_BRAIN §5).
2. `flutter devices` — **both** when plugged in: `emulator-5554` + phone `5f36af49`
3. `flutter run -d emulator-5554` — admin `7069036462` / `password` → Dashboard
4. `flutter run -d 5f36af49` — driver `9876544111` / `password` → driver home
5. Report pass/fail per device. If a device is unavailable, document the gap — do not push silently.

Prefer `flutter run` + manual login over `integration_test` for first build.

**Done** for a P session = code + doc sync + analyze + tests + **both-device smoke** + push.

---

## Client pack STEP 8 (device smoke)

Only after user says **go**. Click-path table: [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) § Morning QR+KM. Script: [client_req/07-NEXT-AGENT-PROMPT.md](./client_req/07-NEXT-AGENT-PROMPT.md).

Morning: Start → start KM+photo → QR scan + one swipe fallback → end KM → STOP.  
Accounts / LAN: PROJECT_BRAIN §5.

---

## Manual QA (high-signal leftovers)

Full historical checklist kept short — unchecked items only:

- [ ] Wrong password → error snackbar
- [ ] Create commuter email filled / address empty → address = email
- [ ] Commuter home / Track Cab stay on commuter UI when offline
- [ ] Admin End return then picker inactive
- [ ] Airplane: cached batches; offline queue → Sync now

Prior full-cycle smoke **PASS** 2026-08-23 (Batch-01 D2D + return). Client pack STEP 8 still open.

---

## Lab accounts

| Role | Mobile | Password | Device |
|------|--------|----------|--------|
| Admin | `7069036462` | `password` | `emulator-5554` |
| Driver 1 | `9876544111` | `password` | `5f36af49` (Batch-01) |
| Driver 2 | `9876544112` | `password` | Batch-02 |
| Commuter sample | `9876556704` | `password` | — |

Do **not** wipe dump admin `9898927941` (Parul org).
