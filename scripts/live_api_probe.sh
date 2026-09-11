#!/usr/bin/env bash
# Live / lab CTS API smoke probe.
# Usage:
#   BASE_URL=https://abhimaarg.tech ./scripts/live_api_probe.sh
# Optional overrides:
#   ADMIN_MOBILE=9879105576 DRIVER_MOBILE=6351505091 COMMUTER_MOBILE=6206361827 PASSWORD=password
set -euo pipefail

BASE_URL="${BASE_URL:-https://abhimaarg.tech}"
BASE_URL="${BASE_URL%/}"
ADMIN_MOBILE="${ADMIN_MOBILE:-9879105576}"
DRIVER_MOBILE="${DRIVER_MOBILE:-6351505091}"
COMMUTER_MOBILE="${COMMUTER_MOBILE:-6206361827}"
PASSWORD="${PASSWORD:-password}"
OUT="${OUT_DIR:-/tmp/cts-live-api-probe}"
mkdir -p "$OUT"
REPORT="$OUT/report.tsv"
echo -e "http\trole\tmethod\tpath\tnote" > "$REPORT"

login() {
  local mobile="$1" label="$2"
  local body http
  http=$(curl -sS -o "$OUT/login_$label.json" -w "%{http_code}" \
    -X POST "$BASE_URL/user/login" \
    -H 'Content-Type: application/json' -H 'Accept: application/json' \
    -d "{\"mobileNumber\":\"$mobile\",\"password\":\"$PASSWORD\"}")
  if [[ "$http" != "200" ]]; then
    echo "LOGIN FAIL $label $mobile -> $http $(head -c 120 "$OUT/login_$label.json")"
    return 1
  fi
  python3 - "$OUT/login_$label.json" "$OUT" "$label" <<'PY'
import json, pathlib, sys
src, out, label = sys.argv[1:4]
d = json.load(open(src))
pathlib.Path(f"{out}/access_{label}.txt").write_text(d["access"])
pathlib.Path(f"{out}/refresh_{label}.txt").write_text(d["refresh"])
u = d["user"]
print(f"LOGIN OK {label} id={u.get('id')} type={u.get('userType')} adminCode={d.get('adminCode')}")
if d.get("adminCode"):
    pathlib.Path(f"{out}/admin_code.txt").write_text(str(d["adminCode"]))
PY
}

call() {
  local role="$1" method="$2" path="$3" data="${4:-}"
  local token="" auth=()
  if [[ -f "$OUT/access_$role.txt" ]]; then
    token=$(cat "$OUT/access_$role.txt")
    auth=(-H "Authorization: Bearer $token")
  fi
  local f="$OUT/resp_${role}_${method}_$(echo "$path" | tr '/?=&' '_').json"
  local http
  if [[ -n "$data" ]]; then
    http=$(curl -sS -o "$f" -w "%{http_code}" -X "$method" "$BASE_URL$path" \
      "${auth[@]}" -H 'Content-Type: application/json' -H 'Accept: application/json' -d "$data")
  else
    http=$(curl -sS -o "$f" -w "%{http_code}" -X "$method" "$BASE_URL$path" \
      "${auth[@]}" -H 'Accept: application/json')
  fi
  local note
  note=$(python3 -c "print(open('$f').read()[:160].replace(chr(10),' '))" 2>/dev/null || true)
  echo -e "$http\t$role\t$method\t$path\t$note" | tee -a "$REPORT"
}

echo "=== CTS live probe against $BASE_URL ==="
login "$ADMIN_MOBILE" ADMIN
login "$DRIVER_MOBILE" DRIVER
login "$COMMUTER_MOBILE" COMMUTER

ACODE=$(cat "$OUT/admin_code.txt" 2>/dev/null || true)
ADMIN_ID=$(python3 -c "import json;print(json.load(open('$OUT/login_ADMIN.json'))['user']['id'])")
DRIVER_BATCH=$(python3 -c "import json;print((json.load(open('$OUT/login_DRIVER.json')).get('profile') or {}).get('batchId') or 3)")

echo "=== Auth / bootstrap ==="
call ADMIN GET "/user/$ADMIN_ID"
call ADMIN POST "/user/refresh" "{\"refresh\":\"$(cat "$OUT/refresh_ADMIN.txt")\"}"
call ADMIN GET "/user/admin-bootstrap/"

echo "=== Unauth security check ==="
call UNAUTH GET "/user/$ADMIN_ID"

echo "=== Admin lists ==="
if [[ -n "$ACODE" ]]; then
  call ADMIN GET "/user/admin/commuter/$ACODE"
  call ADMIN GET "/user/admin/driver/$ACODE"
  call ADMIN GET "/cab/admin/batch/$ACODE"
  call ADMIN GET "/cab/admin/route/$ACODE"
  call ADMIN GET "/cab/admin/cab/$ACODE"
  call ADMIN GET "/cab/admin/pickuppoint/$ACODE"
  call ADMIN GET "/d2d/running_batches/$ACODE"
  call ADMIN GET "/d2d/odometer/org/$ACODE/"
fi

echo "=== Driver client pack / return ==="
call DRIVER GET "/d2d/get_d2d_log_status/$DRIVER_BATCH"
call DRIVER GET "/d2d/boarding_qr/$DRIVER_BATCH/?trip=return"
call DRIVER GET "/d2d/boarding_qr/$DRIVER_BATCH/?trip=morning"
call DRIVER GET "/d2d/odometer/$DRIVER_BATCH/"
call DRIVER GET "/d2d/return_batch/status/$DRIVER_BATCH"
call DRIVER GET "/d2d/return_batch/view/$DRIVER_BATCH"
call DRIVER GET "/d2d/return_batch/get_commuter/$DRIVER_BATCH"

echo "=== Commuter return intent ==="
call COMMUTER GET "/d2d/return_batch/intent"
call COMMUTER GET "/d2d/return_batch/intent_options"

echo "=== Role negatives (read-only) ==="
call COMMUTER GET "/d2d/boarding_qr/$DRIVER_BATCH/?trip=return"
call DRIVER GET "/user/admin-bootstrap/"

echo
echo "Report: $REPORT"
echo "Tokens/JSON under: $OUT"
echo "See docs/testing/LIVE_API_TEST_REPORT.md for interpreted results."
