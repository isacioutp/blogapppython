#!/usr/bin/env bash
set -euo pipefail

# Uso:
# BASE_URL="https://tu-app.ondigitalocean.app" ALERT_TOKEN="tu-token" ./probar_eventos.sh
# Opcional:
# ERR500_COUNT=20 LOGIN_FAIL_COUNT=50 LOGIN_USER="attacker"

BASE_URL="${BASE_URL:-}"
ALERT_TOKEN="${ALERT_TOKEN:-}"
ERR500_COUNT="${ERR500_COUNT:-20}"
LOGIN_FAIL_COUNT="${LOGIN_FAIL_COUNT:-50}"
LOGIN_USER="${LOGIN_USER:-attacker}"

if [ -z "$BASE_URL" ]; then
  echo "Falta BASE_URL. Ejemplo: BASE_URL=https://tu-app.ondigitalocean.app"
  exit 1
fi

HEADER_ARGS=()
if [ -n "$ALERT_TOKEN" ]; then
  HEADER_ARGS=(-H "X-Alert-Sim-Token: $ALERT_TOKEN")
fi

echo "==> Generando ${ERR500_COUNT} errores 500"
ok_500=0
for i in $(seq 1 "$ERR500_COUNT"); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "${HEADER_ARGS[@]}" \
    "$BASE_URL/simulate/error-500" || true)
  if [ "$code" = "500" ]; then
    ok_500=$((ok_500 + 1))
  fi
  echo "[$i/$ERR500_COUNT] status=$code"
done
echo "500 recibidos: $ok_500/$ERR500_COUNT"

echo
echo "==> Generando ${LOGIN_FAIL_COUNT} eventos login_fail"
resp=$(curl -s "${HEADER_ARGS[@]}" \
  "$BASE_URL/simulate/login-failures?count=$LOGIN_FAIL_COUNT&username=$LOGIN_USER")
echo "Respuesta login-failures: $resp"

echo
echo "Listo. Revisa Logtail/Logtrail por:"
echo "- event=simulated_500"
echo "- event=login_fail"
