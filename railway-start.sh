#!/bin/sh
# Railway wrapper for GlitchTip: volume permissions, sane defaults, database
# setup and the first admin account, then the upstream ./bin/start.sh.
set -e
cd /code

# Railway volumes are mounted root-owned. Uploads (source maps, debug files)
# live in /code/uploads and must belong to the image's "app" user.
mkdir -p /code/uploads
if [ "$(stat -c %u /code/uploads)" != "5000" ]; then
    chown -R 5000:5000 /code/uploads
fi

# Public URL used in links, emails and DSNs.
if [ -z "${GLITCHTIP_DOMAIN}${GLITCHTIP_URL}${APP_URL}" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    export GLITCHTIP_DOMAIN="https://${RAILWAY_PUBLIC_DOMAIN}"
fi
# Only invited users can sign up; the admin below is created before the
# server starts, so nobody can claim a fresh instance.
export ENABLE_USER_REGISTRATION="${ENABLE_USER_REGISTRATION:-False}"
export PORT="${PORT:-8000}"
export HOME=/home/app

as_app() { setpriv --reuid=5000 --regid=5000 --init-groups "$@"; }

# Migrations and partitions (takes an advisory lock, safe with replicas).
# Retried for about two minutes, because on a fresh project the database can
# still be starting when GlitchTip boots.
tries=0
until as_app python manage.py init_database; do
    tries=$((tries + 1))
    if [ "$tries" -ge 24 ]; then
        echo "[railway] database setup failed after $tries attempts" >&2
        exit 1
    fi
    echo "[railway] database not ready, retrying in 5 s ($tries/24)"
    sleep 5
done

# First admin account, created once. Changing the variables later has no effect.
if [ -n "$GLITCHTIP_ADMIN_EMAIL" ]; then
    as_app python manage.py shell --no-imports -c "exec(open('/code/bin/railway_bootstrap.py').read())"
fi

export SKIP_INIT=true
exec setpriv --reuid=5000 --regid=5000 --init-groups ./bin/start.sh
