#!/bin/bash
# Railway wrapper for the official Monica image. Sets safe defaults, makes Apache
# listen on $PORT, then hands over to the image's own entrypoint, which creates
# the storage folders, waits for the database and runs the migrations.
set -Eeo pipefail

# Railway's build can bring back the mpm_event link the php:apache base removed
# ("AH00534: More than one MPM loaded"). mod_php needs prefork only.
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.*
[ -e /etc/apache2/mods-enabled/mpm_prefork.load ] || a2enmod -q mpm_prefork

# Listen on Railway's PORT (default 8080 in the template).
PORT="${PORT:-80}"
sed -ri "s/^Listen [0-9]+$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Defaults for a production instance behind Railway's HTTPS proxy. Any of them
# can be overridden with a variable on the service.
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
    export APP_URL="${APP_URL:-https://${RAILWAY_PUBLIC_DOMAIN}}"
fi
export APP_ENV="${APP_ENV:-production}"
export APP_DEBUG="${APP_DEBUG:-false}"
export APP_FORCE_URL="${APP_FORCE_URL:-true}"
export APP_TRUSTED_PROXIES="${APP_TRUSTED_PROXIES:-*}"
export APP_DISABLE_SIGNUP="${APP_DISABLE_SIGNUP:-true}"
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"
export CACHE_DRIVER="${CACHE_DRIVER:-database}"
export SESSION_DRIVER="${SESSION_DRIVER:-database}"
export QUEUE_CONNECTION="${QUEUE_CONNECTION:-sync}"
export MAIL_MAILER="${MAIL_MAILER:-log}"
export DB_CONNECTION="${DB_CONNECTION:-mysql}"
export DB_PORT="${DB_PORT:-3306}"

# Refuse to start with the image's well-known placeholder secrets.
if [ -z "${APP_KEY:-}" ] || [ "$APP_KEY" = "ChangeMeBy32KeyLengthOrGenerated" ]; then
    echo "railway-start: APP_KEY must be set (the template generates it)." >&2
    exit 1
fi
if [ -z "${HASH_SALT:-}" ] || [ "$HASH_SALT" = "ChangeMeBy20+KeyLength" ]; then
    echo "railway-start: HASH_SALT must be set (the template generates it)." >&2
    exit 1
fi

exec /usr/local/bin/entrypoint.sh "$@"
