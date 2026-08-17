# brand-themes

BrockCSC visual identity for the third-party UIs execs sign in to, so Keycloak reads as part of
brockcsc.ca rather than a stock install.

<img src="docs/img/login-mock.svg" alt="The BrockCSC Keycloak login page: a tinted page with the club badge above a white card with a two pixel black border, twenty pixel radius and a hard offset shadow, containing two fields, a red primary button and an identity provider button. Callouts name the selector and custom properties behind each element." width="850">

| Theme | Applies to | Installs at |
| --- | --- | --- |
| `keycloak/brockcsc` | the `brockcsc` realm login pages | the Keycloak themes directory on the VPS |

An **extension, not a fork**: `parent=keycloak.v2` with overrides on top, so upstream security
updates apply without merge conflicts.

## Tokens

`tokens.css` holds the palette, mirroring `app/globals.css` in BrockCSC/website. Keycloak never loads
it: it builds its stylesheet list from `theme.properties` and cannot import from outside the theme,
so `brockcsc.css` restates the same custom properties.

<img src="docs/img/tokens.svg" alt="Keycloak resolves parent keycloak.v2, then common/keycloak, then css/styles.css, then css/brockcsc.css. tokens.css at the repo root is never served. Ten custom properties are identical in both files, tokens.css adds primary-ink and border, brockcsc.css adds primary-dark, and a map lists which rules read each property." width="850">

So a colour change touches both files. Only `brockcsc.css` renders; `tokens.css` keeps the club
palette readable next to the website's.

| | |
| --- | --- |
| Primary | `#9a4440` |
| Primary, hover | `#863a37` — theme only |
| Tint | `#fff1f0` |
| Card | 2px black border, `6px 6px 0 0` shadow, 20px radius |
| Control | 10px radius, `3px 3px 0 0` shadow on focus |
| Type | Geist (bundled woff2, latin subset) |

## Deploying

Merging to `main` runs `.github/workflows/deploy.yml`: validate, tar, then pipe over SSH to a key
pinned to a forced command on the VPS that can do nothing else.

<img src="docs/img/deploy-flow.svg" alt="A push to main runs the deploy workflow, which validates the structure, tars the theme, and pipes it over SSH to a key pinned to a forced command. On the server the archive is unpacked into a temporary directory, suspicious paths are refused, the theme is copied beside the live one and swapped in a single move, then Keycloak is restarted." width="850">

Keycloak caches themes in production mode, so the container restarts on install: expect a few seconds
without sign-in. Hence also no two deploys at once.

After the first deploy, set the realm's login theme:
**Keycloak admin → realm `brockcsc` → Realm settings → Themes → Login theme → `brockcsc`**.

Host, user and `known_hosts` come from repository variables, the key from a repository secret. Paths
and the container name are at the top of `scripts/sync-themes.sh`; installing an updated copy on the
VPS is a manual step.

## Contributing

`scripts/validate.sh` runs on every pull request: structure only, no network, no secrets, because
fork pull requests must never reach credentials. `deploy.yml` runs on push to `main` only, so a
contributor PR cannot reach the deploy key.

Verify rendering against a real Keycloak. Selectors track PatternFly v5 as shipped in Keycloak
26.0.8 — re-check after a major upgrade.

See [CONTRIBUTING.md](CONTRIBUTING.md).
