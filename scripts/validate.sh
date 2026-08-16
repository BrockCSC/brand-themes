#!/bin/sh
# Structural checks only - no network, no secrets, safe to run on fork PRs.
set -eu

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

for f in \
  tokens.css \
  keycloak/brockcsc/login/theme.properties \
  keycloak/brockcsc/login/resources/css/brockcsc.css \
  keycloak/brockcsc/login/resources/img/logo.svg \
  keycloak/brockcsc/login/resources/font/geist-variable.woff2 \
  roundcube/brockcsc/meta.json \
  roundcube/brockcsc/styles/styles.css; do
  [ -f "$f" ] || fail "missing $f"
done

grep -q '^parent=keycloak.v2$' keycloak/brockcsc/login/theme.properties \
  || fail "theme.properties must declare parent=keycloak.v2"

# Dropping the parent sheet ships an unstyled login page.
grep -q 'css/styles.css' keycloak/brockcsc/login/theme.properties \
  || fail "theme.properties styles= must still include the parent css/styles.css"

grep -q '"extends"[[:space:]]*:[[:space:]]*"elastic"' roundcube/brockcsc/meta.json \
  || fail "roundcube meta.json must extend elastic"

grep -q 'elastic/styles/styles.css' roundcube/brockcsc/styles/styles.css \
  || fail "roundcube styles.css must import the elastic stylesheet"

# woff2 magic, catching a corrupt or LFS-pointer font.
head -c 4 keycloak/brockcsc/login/resources/font/geist-variable.woff2 \
  | grep -q 'wOF2' || fail "geist-variable.woff2 is not a valid woff2"

for j in roundcube/brockcsc/meta.json; do
  python3 -c "import json,sys; json.load(open('$j'))" || fail "$j is not valid JSON"
done

echo "OK: theme structure valid"
