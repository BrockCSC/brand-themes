# brand-themes

BrockCSC visual identity applied to the third-party UIs execs sign in to, so
Keycloak and webmail read as extensions of brockcsc.ca rather than stock
installs.

| Theme | Applies to | Installs at |
| --- | --- | --- |
| `keycloak/brockcsc` | the `brockcsc` realm login pages on auth.wayfarerbx.com | `/opt/wayfarer/keycloak/themes/brockcsc` |

Both are **extensions, not forks**: the Keycloak theme sets
`parent=keycloak.v2`, so
upstream security updates apply without merge conflicts.

## Tokens

`tokens.css` is the source of truth, mirroring `app/globals.css` in
BrockCSC/website. Both themes repeat the same custom properties because
Keycloak loads its stylesheet independently; change both
together.

| | |
| --- | --- |
| Primary | `#9a4440` |
| Tint | `#fff1f0` |
| Card | 2px black border, `6px 6px 0 0 #000`, 20px radius |
| Control | 10px radius, `3px 3px 0 0 #000` |
| Type | Geist (bundled woff2, latin subset) |

## Deploying

Merging to `main` runs `.github/workflows/deploy.yml`, which tars both themes
and pipes them to a forced command on the VPS. The deploy key is pinned to
`scripts/sync-themes.sh` and can do nothing else.

Keycloak caches themes in production mode, so that container restarts on
install — expect a few seconds where sign-in is unavailable.

After the first deploy, set the realm's login theme:
**Keycloak admin → realm `brockcsc` → Realm settings → Themes → Login theme →
`brockcsc`**.

## Contributing

`scripts/validate.sh` runs on every pull request. It checks structure only — no
network, no secrets — because pull requests from forks must never have access to
credentials. `deploy.yml` runs on push to `main` only, so a contributor PR
cannot reach the deploy key.

Verify rendering against a real Keycloak; the selectors track PatternFly v5 as
shipped in Keycloak 26.0.8 and should be re-checked after a major upgrade.
