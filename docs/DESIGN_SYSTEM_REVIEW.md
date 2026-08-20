# Design system review — maintainability & color psychology

Analysis of **P1** docs ([ARCHITECTURE](./ARCHITECTURE.md), [ROUTING_AND_AUTH](./ROUTING_AND_AUTH.md), [FEATURES](./FEATURES.md)) plus the live palette in `lib/appManager/colors.dart` / `lib/app/theme/app_theme.dart`.

**Goal:** keep feature-first Clean Architecture, and evolve UI so color and hierarchy match how people scan transport apps (urgency, trust, calm).

---

## 1. What P1 already gets right

| Area | Strength |
|------|----------|
| Feature folders | Clear `data → domain → presentation` boundary |
| Routing | Role prefixes + session refresh are documented and enforceable |
| Feature catalog | One table maps screen ↔ provider ↔ repository |
| Shared widgets | `DashboardShell`, list/form patterns reduce per-screen invention |

---

## 2. Better maintenance (code) — recommended upgrades

### A. Single source of visual tokens (high impact)

**Today:** `AppColors` is a flat bag of yellows/oranges; screens often hard-code `AppColors.acYellowWarm` instead of `Theme.of(context).colorScheme`.

**Better:**

1. Keep brand tokens in one place (`AppColors` or preferably `ColorScheme` + extensions).
2. Screens should prefer **semantic** roles:
   - `colorScheme.primary` — main CTA / brand accent
   - `colorScheme.error` / `tertiary` — danger / warning / success (map green/blue)
   - `colorScheme.surface` / `onSurface` — text and cards
3. Add a thin extension for domain meaning:

```dart
extension CtsColorRoles on ColorScheme {
  Color get success => /* mapped green */;
  Color get warning => /* amber */;
  Color get tripLive => /* high-attention accent */;
  Color get drawerInk => /* readable on black rail */;
}
```

**Why:** Psychology-aligned colors stay consistent when you restyle once; CRUD screens stop drifting.

### B. Finish Phase 10 cleanup (docs already note this)

- Collapse `lib/widgets/` re-exports into `lib/shared/widgets/` only.
- Role-aware drawer: AdminNavList for ADMIN; slim Driver/Commuter menus (reduces cognitive load and wrong-tap anxiety).

### C. Feature provider scoping

`AppProviders` registers every controller app-wide. For long-term maintainability:

- Prefer feature-scoped providers for forms (`*FormProvider`) created at route boundary.
- Keep session / sync / auth global.

### D. Doc discipline (already started)

When changing routes or entities, update in one PR:

1. `FEATURES.md` row  
2. `UI_ARCHITECTURE.md` navigation row  

---

## 3. Human psychology & transport UI — color recommendations

Transport apps balance **urgency (trip now)** with **trust (admin control)** and **calm (commuter daily check-in)**. Pure black + gold works for brand, but overuse of bright yellow on large surfaces causes **visual fatigue** and weakens hierarchy.

### Current palette (psychology readout)

| Color | Current use | Psychology | Risk |
|-------|-------------|------------|------|
| Black (#000 / #1A1A1A) | Drawer, AppBar | Authority, focus | Large black + bright gold can feel harsh |
| Gold / amber yellow | Primary, cards, drawer header | Energy, attention, “caution” | Too much = warning fatigue; WCAG often fails on yellow text |
| Orange | Alternating stats | Warmth, secondary emphasis | Competes with yellow for “primary attention” |
| Red / Green / Blue | Error / success / link | Universal status | Underused — should drive *meaning*, not decoration |

### Recommended direction (role-aware, still on-brand)

Keep **amber/gold as brand accent**, not as the dominant fill for every card.

| Semantic role | Suggested use | Example hex (guide) | Psychological intent |
|---------------|---------------|---------------------|----------------------|
| **Brand accent** | FAB, selected nav, key CTA border | `#F5B400` or keep `acYellowWarm` | Recognition of c2s |
| **Primary CTA fill** | Login, Save, START TRIP | Near-black `#1A1A1A` or deep charcoal with gold outline | Confidence / decisive action |
| **Surface** | Cards, forms | Off-white `#F7F6F2` (warm, not cold gray) | Calm reading, less clinical |
| **Success** | Sync OK, “coming”, trip complete | `#2E7D32` | Safety, confirmation |
| **Warning** | Pending sync, incomplete trip | `#ED6C02` | Attention without panic |
| **Danger** | Delete, Stop trip, Close channel | `#C62828` | Clear stop / irreversible |
| **Live / in-progress** | Running batch, D2D connected | Teal `#00897B` *or* controlled green | “Active now” distinct from brand gold |
| **Commuter calm** | Commuter home background | Soft warm gray-green tint optional | Low anxiety daily ritual |

### Contrast rules (accessibility = trust)

- Do **not** put yellow text on white, or black text on light yellow without checking contrast (≥ 4.5:1 for body).
- Prefer **black/dark text on soft yellow containers**, or **white/near-black on solid charcoal CTAs with gold accent**.
- Drawer: gold header is fine; body items should use **muted gold icons** + high-contrast white labels (already close).

### Role-specific mood (same brand, different emphasis)

```text
Admin     → Charcoal structure + gold accents + teal for “live”
Driver    → High-contrast START TRIP; teal “live trip”; red stop
Commuter  → Soft surface; one clear switch; green when “coming”
```

---

## 4. Practical redesign steps (no big-bang)

1. **Token pass** — Map dashboard cards to `primaryContainer` / `secondaryContainer` instead of raw gradients of yellow/orange on every tile.
2. **CTA pass** — Make primary buttons charcoal + gold border (or gold fill with black label only when contrast passes).
3. **Status pass** — Running / sync / coming / error always use semantic greens/ambers/reds, never brand yellow alone.
4. **Drawer pass** — Role-filtered nav; reduce yellow saturation in idle tiles.
5. **Document** — Add a one-page `docs/DESIGN_TOKENS.md` once tokens stabilize (optional next doc).

---

## 5. Suggested palette snapshot (for design review)

| Token | Light | Dark |
|-------|-------|------|
| Surface | `#F7F6F2` | `#121212` |
| On surface | `#1A1A1A` | `#F5F5F5` |
| Brand / primary | `#E6A800` | `#FFC107` |
| On primary | `#1A1A1A` | `#1A1A1A` |
| Live | `#00897B` | `#4DB6AC` |
| Success | `#2E7D32` | `#81C784` |
| Warning | `#ED6C02` | `#FFB74D` |
| Danger | `#C62828` | `#EF5350` |

These keep c2s recognizable (amber brand) while aligning with how people scan: **structure (neutral) → action (strong CTA) → status (semantic colors)**.

---

## 6. Link to P1 docs

- Architecture maintenance checklist → [ARCHITECTURE.md](./ARCHITECTURE.md) “Adding a new feature”
- Route/role clarity → [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md)
- Screen inventory for theming audit → [FEATURES.md](./FEATURES.md)

When ready to implement tokens in code, start with `AppTheme` + one screen (Admin dashboard) as a pilot, then roll out via shared widgets.
