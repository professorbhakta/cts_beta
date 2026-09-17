> **Doc:** docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md
> **Updated:** 2026-09-17 12:30 IST
> **Session:** FE trip report odometer photo thumbnails (A + B fallback)

# Trip auto-close + daily report contract (snake_case)

**Auth:** JWT Bearer. Roles: **ADMIN** | **SUPERVISOR** (FE also allows SUPER_ADMIN shell).

**BE tip for lab smoke:** `professor-dock` @ `77ed62a` (open-trip auto-close). Do not wait on `gb-dock` merge.

## Product locks

- Remind driver + alert Admin/Supervisor if morning/return started and not ended.
- Auto-close Asia/Calcutta: **morning 12:00 PM**, **return 12:00 AM**.
- Auto-close: `end_km = start_km`, mark **incomplete**, `endTime` + `isActive=false`, archive like End.
- Admin + Supervisor may edit `end_km`; show status **edited**.
- Daily trip report (mobile first this pass; no FCM/web UI here).
- Trip report legs show **start + end odometer photo thumbnails** when a photo exists; tap → full-screen viewer with close. Quiet empty / hide on missing photo or 404.

## GET `/d2d/trip_report/?date=YYYY-MM-DD&admin_code=`

Query:

| Param | Required | Notes |
|-------|----------|-------|
| `date` | yes | `YYYY-MM-DD` |
| `admin_code` | yes | Org admin code |

Response:

```json
{
  "status": "ok",
  "trip_date": "2026-09-12",
  "count": 1,
  "items": [
    {
      "batch_id": "42",
      "batch_name": "Morning A",
      "admin_code": "ac-1",
      "trip_date": "2026-09-12",
      "morning": { "...leg..." },
      "return": null,
      "any_incomplete": true,
      "any_edited": false,
      "any_auto_closed": true
    }
  ]
}
```

Each leg object (or `null` if absent):

| Field | Type | Notes |
|-------|------|-------|
| `trip_id` | string/id | |
| `is_active` | bool | |
| `end_time` | string/null | |
| `start_km` | int/null | |
| `end_km` | int/null | |
| `distance_km` | int/null | |
| `auto_closed` | bool | |
| `incomplete` | bool | |
| `edited` | bool | |
| `close_kind` | string | `absent` \| `open` \| `normal` \| `incomplete` \| `edited` |
| `start_photo_url` | string\|null | **A (preferred):** auth download URL for start odo photo (Dock additive) |
| `end_photo_url` | string\|null | **A (preferred):** auth download URL for end odo photo (Dock additive) |

FE also surfaces an **auto_closed** chip when `auto_closed=true`.

### Odometer photo URLs (A preferred, B interim)

| Path | Notes |
|------|-------|
| **A** | Prefer non-null `start_photo_url` / `end_photo_url` on each leg |
| **B** | Else build `GET /d2d/odometer/photo/<batch_id>/<leg>/<kind>/` via `ApiUrl.odometerPhoto` (`leg`=`morning`\|`return`, `kind`=`start`\|`end`) |

Photo GETs require `Authorization: Bearer <access>` (same session as REST). FE loads thumbnails with Bearer headers — not bare `Image.network` without auth. 404 / missing → quiet empty placeholder (no loud error).

## PATCH or POST `/d2d/trip_report/edit_end_km/`

Body:

```json
{
  "batch_id": "42",
  "leg": "morning",
  "end_km": 150,
  "date": "2026-09-12"
}
```

| Field | Required | Notes |
|-------|----------|-------|
| `batch_id` | yes | |
| `leg` | yes | `morning` \| `return` |
| `end_km` | yes | int >= 0 |
| `date` | no | defaults to today on BE if omitted |

Response:

```json
{
  "status": "ok",
  "leg": "morning",
  "batch_id": "42",
  "trip_date": "2026-09-12",
  "trip_id": "m1",
  "start_km": 100,
  "end_km": 150,
  "distance_km": 50,
  "auto_closed": false,
  "incomplete": false,
  "edited": true
}
```

## Flutter pointers

| Piece | Path |
|-------|------|
| API consts | `lib/api/api_list.dart` → `tripReportUrl`, `tripReportEditEndKmUrl`, `odometerPhoto` |
| Feature | `lib/features/trip_report/` |
| Photo URL resolve | `helpers/trip_report_photo_url.dart` (A-over-B) |
| Auth image widget | `lib/widgets/authenticated_network_image.dart` |
| Route | `RouteName.tripReportScreen` |
| Gate | `AdminService.tripReport` (ADMIN / SUPER_ADMIN / SUPERVISOR) |
