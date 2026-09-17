> **Doc:** PROMPT_SCOPE.md
> **Updated:** 2026-09-17 12:30 IST
> **Session:** Trip report odometer photo thumbnails

# PROMPT SCOPE — CTS

## Attach order (LOCKED — same as PROJECT_BRAIN §3)

**Every chat:**
```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

**Client pack / STEP 8 (append — only on go):**
```
@docs/setup/DISCUSSION_STATUS.md
@docs/FLOWS_BY_ROLE.md
@docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
```

**Setup drafts (append after Always when doing JWT/bootstrap/schema — same as brain §3):**
```
@CHAT_PROMPTS.txt
@docs/setup/DISCUSSION_STATUS.md
@docs/setup/BRANCH_HOLD_NOTES.md
@docs/API_CONTRACTS.md
@docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt
@docs/setup/ADMIN_BOOTSTRAP_DRAFT.md
@docs/setup/LOGIN_JSON_FIELDS.txt
@docs/setup/SQLITE_TABLES_COLUMNS.txt
@docs/setup/SCHEMA_FINAL_DRAFT.txt
@docs/setup/RETURN_TRIP_API_GAP.md
@docs/setup/RETURN_QR_UI_PREP.md
@docs/ROUTING_AND_AUTH.md
@lib/features/batches/README.md
@lib/features/d2d/README.md
@docs/LOCAL_DEV.md
@docs/TESTING.md
```

Add for journeys/QA: already in STEP 8 pack via FLOWS.  

| File | Owns |
|------|------|
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | Product + devices + §5/§9 + BE↔FE §10 |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | Long-lived backlog |
| **This file** | Prompt gate, ordered queue, change log |

**Story split:** FLOWS = journeys + D1–D10 · API_CONTRACTS = wire/schema · DISCUSSION_STATUS = handoff · STEP8 checklist = smoke.

---

## 1. Prompt check

| # | Check | Pass? | Note |
|---|--------|-------|------|
| P1 | Goal clear? | yes | Trip report odometer start/end photo thumbnails |
| P2 | Role / surface? | yes | Admin/Supervisor trip report (cream) |
| P3 | Non-negotiables? | yes | Provider only; PR base gb-f&d |
| P4 | Both ends? | yes | FE A+B; Dock additive A preferred |
| P5 | R10 isComing? | n/a | |
| P6 | Git branch? | yes | cursor/… → gb-f&d |
| P7 | Docs policy? | yes | TRIP_AUTO_CLOSE + API_CONTRACTS |
| P8 | Out of scope? | yes | No FCM/web trip report UI |

**This prompt:** Add odometer photo thumbnails to daily trip report (A-over-B URLs, Bearer image load, fullscreen close).

**Gate (locked):** Device smoke stays human post-push.

---

## 2. Ordered work queue

| Order | ID | Item | Status | Owner |
|------:|----|------|--------|-------|
| 0 | Q-trip-odo-thumbs | Trip report start/end odometer photo thumbnails (A+B) | **done** (code+docs) · smoke human | [TRIP_AUTO_CLOSE](docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md) |
| 0 | Q-d2d-cream-beep | Shared cream D2D + other-batch red + board beeps + WS `batchId` | **done** (code+docs) · smoke human · BE restart | [d2d README](lib/features/d2d/README.md) · [API_CONTRACTS](docs/API_CONTRACTS.md) |
| 0 | Q-play-aab | Play Store signed AAB — Gradle release signing wired; user creates keystore + builds | **parked** (user) | [BUILD_AND_RELEASE](docs/BUILD_AND_RELEASE.md) |
| 0 | Q-fe-match-be | FE match pass vs BE tip (schema/API/bootstrap/return QR) | **done** | prompt deleted 2026-09-10; SoT = DISCUSSION_STATUS + API_CONTRACTS |
| 0y | Q-platform-lean | Platform: store less + smooth flow (bg catalog refresh, non-block login/boot) | **in progress** | OFFLINE_AND_SYNC · admin_bootstrap · FIND-011 |
| 0z | Q-fe-prod-inspect | P0–P7 **PASS**; P8 device = **human post-push** (not agent) | **parked** (human) | [CONTINUE](docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt) |
| 0a | Q-jwt-phase-a | JWT Phase A FE smoke — **human + devices after push** | **parked** (human) | [DISCUSSION_STATUS](docs/setup/DISCUSSION_STATUS.md) · [API_CONTRACTS](docs/API_CONTRACTS.md) |
| 0b | Q-admin-bootstrap | FE admin-bootstrap consumed for lists/home; device smoke = human post-push | **parked** (smoke) | [ADMIN_BOOTSTRAP_DRAFT](docs/setup/ADMIN_BOOTSTRAP_DRAFT.md) · API_CONTRACTS |
| 0c | Q-docs-setup | Keep-lane map + brain/scope/registry | open | [BRANCH_HOLD_NOTES](docs/setup/BRANCH_HOLD_NOTES.md) |
| 0c2 | Q-docs-hygiene | Prune junk + merge redundant md | **done** | DOC_REGISTRY |
| 0d | Q-lab-migrate | Org + return-trip migrations on professor-dock lab | **done** | DISCUSSION_STATUS · LOCAL_DEV |
| 1 | Q-client-qr-odo | Client pack STEP 8 device smoke — **human + devices after push** | **parked** (human) | [FLOWS](docs/FLOWS_BY_ROLE.md) · [STEP8](docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt) · [LAB_SMOKE_ISSUES](docs/LAB_SMOKE_ISSUES.txt) |
| 2 | Q-client-tests | New tests under `test/features/d2d/` | open | TESTING |
| 3 | Q-26d | Confirm “API every time” discuss | pending | return add UI |
| 4 | Q-return-qr-dock | Return QR Phase 2 wire (`?trip=return` + boarding_scan) | **done** | [RETURN_QR_UI_PREP](docs/setup/RETURN_QR_UI_PREP.md) · [GAP](docs/setup/RETURN_TRIP_API_GAP.md) |
| 5 | Q-batch-coming | Mark all coming **per batch** | future | `CommuterListScreen` |
| 6 | Q-r7-tests | Django lazy cutoff + Flutter `cutoff_applied` | future | BE tests |
| — | Q-return-qr-ui | Return QR UI scaffolding (stub) | **done** | batches + ROUTING/FLOWS |
| — | Q-d2d-phase3 | Return waiting pool + FCFS parity | **done** | batches README + API_CONTRACTS |
| — | Q-d2d-phase1-2 | Morning cross-batch + waiting + FCFS | **done** | d2d README + API_CONTRACTS |
| — | Q-docs-consol / story-split / nginx / backup | shipped | **done** | — |

---

## 3. Future scope (parked)

| Idea | Notes |
|------|-------|
| Return QR live list sockets | Mint/scan wired; Redis+socket live RCList polish if Dock exposes push beyond REST |
| Return-leg KM / org odometer / unboard UI | After STEP 8 |
| Batch-wise Mark all coming | Org-wide already shipped |
| Wire CList into return pool (R2/R9) | Roadmap ahead of code |
| Healthchecks / TLS / CI | Lab-only for now |

---

## 4. Change log

| When (IST) | Change | Repos |
|------------|--------|-------|
| 2026-09-16 09:10 | Pushed day lanes: FE `professor-cts` **30909b8**; BE `professor-dock` **66c89e9** (`batchId` hydrate) — restart dock then smoke | both |
| 2026-09-16 09:05 | Residual: no more FE code bugs blocking; only luggage no-retry edge + BE push/restart + human smoke | `cts_beta` |
| 2026-09-15 22:50 | Fix: one board tone per Already-IN delta (other wins); admin Add FAB-only (no cream duplicate) | `cts_beta` |
| 2026-09-15 22:45 | Review: cream/beep FE wiring OK (18 D2D tests PASS); blockers = FE uncommitted + BE `batchId` not pushed/restarted; minor = multi-beep race, dual Add, luggage no-retry | `cts_beta` + `cts-docker` |
| 2026-09-15 22:35 | Docs sync: API_CONTRACTS live `batchId`; d2d README role/beep/cream; brain/scope/registry | `cts_beta` (+ BE hydrate note) |
| 2026-09-15 22:30 | Audit fix: commuter beep reads ManagerKey.batchId; WS `batchId` for driver other-batch (BE hydrate + FE parse) | `cts_beta` + `cts-docker` |
| 2026-09-15 22:15 | D2D: shared cream Admin/Driver body; Driver no Add; SUPER_ADMIN no Add; red other-batch; short/long board beeps; Admin return no QR | `cts_beta` |
| 2026-09-15 10:40 | Play Store: release signing via key.properties; AAB steps in BUILD_AND_RELEASE; key.properties.example | `cts_beta` |
| 2026-09-15 10:36 | Device smoke locked: human + real devices, post-push only; P8/STEP8/JWT smoke parked (not agent) | `cts_beta` |
| 2026-09-15 10:18 | Re-entry after break; orient only — branch `feat/daily-trip-report`, large dirty tree | `cts_beta` |
| 2026-09-12 16:00 | Moved FE checklist → `docs/`; thinned `docs/features/*_E2E.md` to pointers | `cts_beta` |
| 2026-09-12 15:55 | setup/ merge+retire: CLIENT_RETURN→RETURN_QR_UI_PREP; COLUMNS→SCHEMA; ROLE+USER_ROLES→ROUTING; CREAM→UI_ARCHITECTURE §8 | `cts_beta` |
| 2026-09-12 15:45 | Retired `docs/backend/` + `docs/client_req/`; D1–D10 → FLOWS; safety → API_CONTRACTS; modules → LOCAL_DEV; attach lists updated | `cts_beta` |
| 2026-09-12 15:35 | Removed `integration_test/` + pubspec `integration_test` dep; pre-push stays manual `flutter run` | `cts_beta` |
| 2026-09-12 12:25 | Deleted leftover logs: `flutter_01.log`, `flutter_02.log`, `tmp_emu_boot.log` | `cts_beta` |
| 2026-09-12 12:25 | Explained: client_req still STEP-8 pack; docs/backend emptied on purpose (01–04 → owners); flutter_*.log + tmp_emu_boot.log = local junk (gitignored) | `cts_beta` |
| 2026-09-12 12:20 | Deleted junk `.tmp_mobile_ocr/` (7 OCR PNGs) | `cts_beta` |
| 2026-09-12 12:15 | Docs hygiene proposed: delete `.tmp_mobile_ocr`; move root checklist; merge setup overlaps; keep locked attach owners | `cts_beta` |
| 2026-09-11 12:40 | Dock P0 shipped: JWT WS middleware; GET /user/ dump closed; return end/add/remove role gate; SUPER_ADMIN/SUPERVISOR; 20 tests OK | `cts-docker` |
| 2026-09-11 12:05 | Mapped 3 critical BE holes + fix plan: GET /user/ dump; return end no auth; WS JWT middleware missing (4401) | `cts-docker` |
| 2026-09-11 10:15 | cts-index 500: nginx missing `./cts-index` bind — recreated C2S-Nginx; portal 200; API `/user/login` reachable | `cts-docker` |
| 2026-09-11 08:35 | Flutter web release → `cts-docker/cts-index` (VPS URLs bundled); nginx SPA + API split; marketing backup kept | both |
| 2026-09-10 23:05 | P7 platform PASS; phone/location manifests cleaned; FIND-018 FCM deferred; OEM note; forms canPop; CONTINUE → P8 | `cts_beta` |
| 2026-09-10 22:15 | Redis: remove host `6379` publish — `cts-docker` main `cf0f6a5` (apply on VPS) | `cts-docker` |
| 2026-09-10 22:35 | Pre-push local gate (skip d2d_channel device): analyze 0 err; **152** tests pass; lab login+bootstrap OK | `cts_beta` |
| 2026-09-10 22:15 | External VPS check: HTTPS OK; **Redis 6379 public +PONG** — must firewall/bind; 5432/8000 closed | VPS |
| 2026-09-10 23:15 | Pruned superseded continues: FE_MATCH, D2D_PHASE3, LAB_SMOKE_CONTINUE (kept LAB_SMOKE_ISSUES + client_req + inspection) | `cts_beta` |
| 2026-09-10 23:05 | P7 PASS — next P8 device (on go) | `cts_beta` |
| 2026-09-10 22:10 | Clarified: public IP via domain DNS is normal; harden firewall/SSH/TLS not “hide IP” | scope |
| 2026-09-10 22:00 | Hygiene: drop unused http/cookie deps; dead collegeName validator + commClg; API_CONTRACTS getCommuters→bootstrap; D2D comment | `cts_beta` |
| 2026-09-10 21:55 | CONTINUE prompt POV locks (env asset, phone+location, checkbox honesty) — READY TO GO | `cts_beta` |
| 2026-09-10 21:45 | Fat continue prompt: 4 lanes to close P3–P6 PARTIALS in one shot | `cts_beta` |
| 2026-09-10 20:05 | P5∥P6 inspection; FIND-010+003 closed; FIND-012..017; API logs kDebugMode | `cts_beta` |
| 2026-09-10 19:50 | Platform lean: bg catalog refresh after CRUD; non-block login/cold boot; skip post-CRUD batch cache rewrite | `cts_beta` |
| 2026-09-10 19:40 | Removed `lib/offline_temp/` Offline Mode prototype; kept OfflineFirstBatch/SyncManager | `cts_beta` |
| 2026-09-10 19:35 | FIND-001 fix (`instanceOrNull`); FE-0.4 168 pass; P3∥P4 evidence; FIND-007..011 | `cts_beta` |
| 2026-09-10 19:05 | Inspection continue prompt + mindset reset to original Main Agent; brain §5/§9 handoff | `cts_beta` |
| 2026-09-10 18:45 | FE inspection P0–P2: FIND-001 AppDatabase.instance throw after CRUD resync (3 tests); structure+UC map recorded | `cts_beta` |
| 2026-09-10 13:40 | FE checklist deep reflow: subPs dependency-ordered; P2/P4/P5/P6/P8/P9/P10 IDs re-sequenced; gates + overlap map | `cts_beta` |
| 2026-09-10 13:25 | FE checklist: India-ops/scale should-adds (TTL, poison sync, multi-op, UC15/16, RTL, OEM, size, analytics, STRIDE, web N/A) | `cts_beta` |
| 2026-09-10 12:55 | FE checklist: V0–V10 design spine + Figs 1–13 (context/DFD/UC/seq/state/deploy) | `cts_beta` |
| 2026-09-10 19:45 | Required-field lock synced to owner docs (bootstrap draft, SQLITE v4, SCHEMA, LOGIN, DISCUSSION, continue prompt, brain) | both |
| 2026-09-10 19:20 | Required fields locked: organizationId (not collegeName), cab km; FE form/mapper; BE bootstrap emits km/orgId | both |
| 2026-09-10 12:45 | FE checklist reflow: P4 API before P8 journeys; overlap map; Requires/Unblocks; P0 narrowed | `cts_beta` |
| 2026-09-10 12:35 | Added FE_PRODUCTION_INSPECTION_CHECKLIST.md (Phases 0–11); inspection not started | `cts_beta` |
| 2026-09-10 12:15 | Audit+fix: catalog SoT via bootstrap; clear SQLite on invalidate; cold-start hydrate; remove list fan-out | `cts_beta` |
| 2026-09-10 12:05 | FE: admin home + list get* read bootstrap luggage; no catalog fan-out; pull-refresh re-syncs | `cts_beta` |
| 2026-09-10 07:45 | Web: skip SQLite — API-only boot; no-op cache/sync DAOs; offline_temp gated | `cts_beta` |
| 2026-09-09 22:00 | Full assembly check: Android APK + web build PASS; iOS files OK (Mac build N/A); restored `.env.example`; 167 tests | `cts_beta` |
| 2026-09-09 21:40 | Parul final seed: 217 allowlist students + 10 Bharuch staff + 4 drivers + admin; DB wiped+reloaded | `cts-docker` |
| 2026-09-09 21:05 | Lab DB wiped + reloaded Parul-only seed (admin 9879105576; no dummy org) | `cts-docker` |
| 2026-09-09 20:55 | Parul University seed: admin 9879105576 + 4 buses/drivers/batches + 9863 riders; RejectedImport quarantine 199 | `cts-docker` |
| 2026-09-09 20:40 | Bharuch XLSX gap check vs live Postgres (admin/students/staff); awaiting defaults | both |
| 2026-09-09 20:30 | Docs sync: SUPER_ADMIN + `returnTripLogId`/`tripLeg` + SQLite v3 owners; tip SHAs | `cts_beta` |
| 2026-09-09 20:10 | Store id → `tech.abhimaarg.cts` (domain abhimaarg.tech) both platforms | `cts_beta` |
| 2026-09-09 19:50 | SUPER_ADMIN web /void/; FE null-safe + return_trip_id vars; SQLite v3; stale return_* docs scrubbed | both |
| 2026-09-09 19:30 | Platform audit: iOS Info.plist location+ATS+url schemes; Android tel/https queries; debug APK OK | `cts_beta` |
| 2026-09-09 19:10 | Lab migrate confirmed applied; API probe login/refresh/bootstrap/return QR+scan PASS | both |
| 2026-09-09 18:55 | FE match re-verify vs dock source: merge e750; FE_FIX return scan no boarding_scan join_waiting; migrate DEFER (Docker down) | `cts_beta` |
| 2026-09-09 18:10 | FE match: gap table; FE_FIX flat/nested profile + bootstrap soft-fail; 166 tests | `cts_beta` |
| 2026-09-09 10:16 | QUICK CLOSE: no STEP 8 (no go); queue unchanged — next paste FE match START | `cts_beta` |
| 2026-09-09 10:20 | Hardened FE match prompt: brain §3 pack, no migrate/smoke blockers, lib/data/local OK, stale draft refs fixed | `cts_beta` |
| 2026-09-09 10:15 | CHAT_PROMPTS: FE match-BE-tip is primary START; STEP 8 kept as alt on go | `cts_beta` |
| 2026-09-09 10:10 | Added FE_MATCH_BE_TIP_CONTINUE_PROMPT — FE check/match vs BE tip schema+API | `cts_beta` docs |
| 2026-09-09 10:05 | Keep-lane tidy: push FE docs + day-lane hooks; reset local beta-ver; BE hooks on professor-dock | both |
| 2026-09-09 09:50 | FE keep-5: merge admin-bootstrap + return-qr + AGENTS into professor-cts; navy ours-merge; delete extras | `cts_beta` |
| 2026-09-08 23:50 | Return QR Phase 2 wired: GET boarding_qr?trip=return + POST boarding_scan; return_trip_id; cream nits | `cts_beta` / `professor-cts` |
| 2026-09-08 15:45 | Return QR LOCKED: End archives RCList→history; trip keeps archive ID; FE no archive UI | `cts_beta` / `professor-cts` |
| 2026-09-08 15:43 | Return QR docs: RCList = user-ID list on return trip log row (like CList); archive-on-end = BE/history only | `cts_beta` / `professor-cts` |
| 2026-09-08 15:40 | Return QR prep: drop morning hard-wire; placeholders ReturnTripLogRef/RclistRef; scan shell separate | `cts_beta` / `professor-cts` |
| 2026-09-08 15:18 | Return QR UI prep: ReturnBoardingQrPanel/Screen + routes + role gates; stub until Dock; docs/setup/RETURN_QR_UI_PREP.md | `cts_beta` / `professor-cts` |
| 2026-09-08 12:45 | Role UI: STAFF→commuter home; SUPERVISOR admin shell + AdminService allow-list; docs ROUTING_AND_AUTH | `cts_beta` / `professor-cts` |
| 2026-09-01 10:20 | Doc header sync — API_CONTRACTS view/ waiting[] example; feature READMEs; FLOWS; PROJECT_TODOS 128 tests | `cts_beta` |
| 2026-08-31 13:45 | D2D Phase 3 shipped — return waiting Redis + join_waiting + FCFS + FE waiting UI | both |
| 2026-08-31 13:20 | D2D Phase 1+2 shipped (morning); Phase 3 handoff prompt + brain/scope/registry sync | both |
| 2026-08-29 13:25 | STEP 8 resume go — fix ISSUE-008 (driver adminCode); finish M6/M7|R5 + return R1–R8 | both |
| 2026-08-29 10:27 | END sync: PROJECT_BRAIN §5/§6/§9; DOC_REGISTRY fast+on-change; CHAT_PROMPTS; DISCUSSION_LOG pointer | `cts_beta` |
| 2026-08-29 10:02 | LIB_STRUCTURE.md: target tree aligned to disk; Phase B done; legacy root folders documented | `cts_beta` |
| 2026-08-29 10:16 | reviewer_agent.md: role card — LIB_STRUCTURE law; no Riverpod; no data/domain/presentation | `cts_beta` |
| 2026-08-29 10:10 | test_agent.md: role card — TESTING.md owner; test/features/<name>/; unit tests ≠ push gate | `cts_beta` |
| 2026-08-29 10:06 | ui_agent.md: role card — PROJECT_BRAIN first; features/screens + lib/widgets; Material only; no presentation/ | `cts_beta` |
| 2026-08-29 10:03 | main_agent.md: orchestrator role card — PROJECT_BRAIN/.cursorrules first; attach §3; END sync; Provider only | `cts_beta` |
| 2026-08-29 10:03 | ARCHITECTURE.md: layer mermaid → Screen/Provider/Repository/API; flow ≠ folders; legacy lib/data|domain loud; Provider only | `cts_beta` |
| 2026-08-29 09:35 | logic_agent.md: full replace — Provider (ChangeNotifier) only; never Riverpod; module paths locked | `cts_beta` |
| 2026-08-26 08:50 | migrate-widgets + migrate-features done; analyze 0 errors; 128 tests pass | `cts_beta` |
| 2026-08-26 08:40 | Features/offline: fix Theme migration scope/const; 0 analyze errors | `cts_beta` |
| 2026-08-26 08:35 | Widgets + appManager off AppColors → Theme (scheme/cts) | `cts_beta` |
| 2026-08-26 08:35 | Theme migration: UI off AppColors → ColorScheme + CtsColors extension | `cts_beta` |
| 2026-08-26 08:26 | Hold firebase_messaging as-is (planned FCM later; no remove/bump) | `cts_beta` |
| 2026-08-26 08:15 | Phase C: permission_handler 13, go_router 18, dropdown_search 7 (+ widget API adapt) | `cts_beta` |
| 2026-08-26 08:05 | Phase B: dotenv 6, shimmer 4, easyloading 4; 128 tests pass | `cts_beta` |
| 2026-08-26 07:57 | Phase A: `flutter pub upgrade` (31 patches); analyze OK (pre-existing infos); 128 tests pass | `cts_beta` |
| 2026-08-26 07:52 | Dep coupling map before upgrades (clusters + dry-run) | `cts_beta` |
| 2026-08-26 07:46 | Checked `flutter pub outdated` (report only; no bumps) | `cts_beta` |
| 2026-08-25 22:15 | Session rest — docs complete; no further churn | `cts_beta` |
| 2026-08-25 22:05 | FLOWS QR/KM+smoke; 05 product story; DISCUSSION_LOG pointer-only | `cts_beta` |
| 2026-08-25 21:50 | Stability lock + BE↔FE §10 | both docs |
| 2026-08-25 21:45 | Fast-path + delete widget_test | `cts_beta` |
| 2026-08-25 21:40 | Docs consol 01–04 + guides | `cts_beta` |

---

## 5. Agent sync rules

**START:** attach locked list; fill §1; align §2.  
**During:** update §2–§4 async.  
**END:** brain / registry / todos; if STEP 8 pack touched → bump DISCUSSION_STATUS.  
**STEP 8:** only on user **go**.  
**Do not** invent a new attach order; **do not** recreate `docs/backend/` or `docs/client_req/`.

## Change log (recent)

| When | Note |
|------|------|
| 2026-09-17 12:30 IST | Trip report odometer photo thumbs: parse start/end_photo_url; A-over-B URL; Bearer AuthenticatedNetworkImage; fullscreen close. PR → gb-f&d. |
| 2026-09-12 16:10 IST | FE feat/daily-trip-report: daily trip report + edit_end_km (Provider). Contract docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md. Lab smoke BE professor-dock @ 77ed62a. |

