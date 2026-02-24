#!/bin/sh
set -e
export FLASK_APP=${FLASK_APP:-app.py}
if [ "${AUTO_INITDB:-true}" = "true" ]; then
  flask initdb
fi
if [ "${ENABLE_DEMO_SEED:-false}" = "true" ]; then
  flask seed
fi
exec "$@"
