#!/bin/sh
# Forced-command entrypoint for the theme deploy key, at
# /opt/wayfarer/bin/sync-themes.sh. Reads a tar.gz on stdin;
# SSH_ORIGINAL_COMMAND is ignored by design.
set -eu

KEYCLOAK_THEMES=/opt/wayfarer/keycloak/themes
ROUNDCUBE_SKINS=/opt/wayfarer/mail/skins

staging=$(mktemp -d /tmp/themes.XXXXXX)
trap 'rm -rf "$staging"' EXIT

# No -p; absolute and ../ members are refused below.
tar xzf - -C "$staging" --no-same-owner --no-same-permissions

if tar_bad=$(find "$staging" -name '..' -o -name '.*..*' -print -quit) && [ -n "$tar_bad" ]; then
  echo "refusing suspicious path: $tar_bad" >&2
  exit 1
fi

[ -f "$staging/keycloak/brockcsc/login/theme.properties" ] || {
  echo "payload missing the keycloak theme" >&2
  exit 1
}
[ -f "$staging/roundcube/brockcsc/meta.json" ] || {
  echo "payload missing the roundcube skin" >&2
  exit 1
}

install -d "$KEYCLOAK_THEMES" "$ROUNDCUBE_SKINS"

rm -rf "$KEYCLOAK_THEMES/brockcsc.new" "$ROUNDCUBE_SKINS/brockcsc.new"
cp -a "$staging/keycloak/brockcsc" "$KEYCLOAK_THEMES/brockcsc.new"
cp -a "$staging/roundcube/brockcsc" "$ROUNDCUBE_SKINS/brockcsc.new"

# Swap last so a half-copied theme is never live.
rm -rf "$KEYCLOAK_THEMES/brockcsc" "$ROUNDCUBE_SKINS/brockcsc"
mv "$KEYCLOAK_THEMES/brockcsc.new" "$KEYCLOAK_THEMES/brockcsc"
mv "$ROUNDCUBE_SKINS/brockcsc.new" "$ROUNDCUBE_SKINS/brockcsc"

# Keycloak caches themes in production mode.
docker restart keycloak >/dev/null
docker restart brockcsc-roundcube >/dev/null 2>&1 || true

echo "themes installed"
