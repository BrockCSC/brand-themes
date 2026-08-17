# Contributing

A design repo with a deploy key attached. So: get the theme structure right, and keep pull requests
away from credentials.

## Layout

<img src="docs/img/file-structure.svg" alt="Repository layout: two workflows, the Keycloak theme under keycloak/brockcsc/login with theme.properties and a resources directory, two shell scripts that run on different machines, and tokens.css at the root." width="850">

Only `keycloak/brockcsc` is installed onto the server; the rest is tooling and reference.

## The theme directory

Keycloak resolves a theme as `<theme-name>/<type>/`, so both directory names are load-bearing:

- `brockcsc/` — the name you pick in the admin console. Renaming it renames the theme.
- `login/` — the theme type. Renaming it stops the theme applying to the login pages at all.

```properties
parent=keycloak.v2
import=common/keycloak
styles=css/styles.css css/brockcsc.css
```

`styles` **replaces** the parent's list rather than appending, which is why the parent's
`css/styles.css` is repeated — drop it and you ship an unstyled login page. `validate.sh` fails the
build if that line or `parent` goes missing, since both look fine in a diff.

## Editing the CSS

`resources/css/brockcsc.css` overrides `keycloak.v2`, i.e. PatternFly v5.

- Declare intent through the custom properties at the top; don't repeat hex values below.
- Set PatternFly's own variables too. `border-radius` on a form control is not enough:
  `--pf-v5-c-form-control--BorderRadius` and the border-bottom colour also need resetting, or the
  parent's underline shows through your border.
- Selectors are versioned markup, not an API. They track Keycloak 26.0.8 — re-check after a major
  upgrade.

A file under `resources/` appears in three places: its relative URL in the stylesheet, the `styles`
list in `theme.properties` if it is a stylesheet, and the required-files list in `validate.sh`.

## The two scripts run on different machines

`scripts/validate.sh` runs in CI on every pull request, forks included. Structural only — no network,
no secrets — and it must stay that way. `validate.yml` has no credentials and must never become
`pull_request_target`.

`scripts/sync-themes.sh` never runs in CI. It is the source for the forced command installed on the
VPS by hand, so editing it in a pull request changes nothing until someone copies it across.

## Deploy safety

`deploy.yml` triggers on push to `main` only. **Never add a `pull_request` or `pull_request_target`
trigger** — that is what keeps a fork's pull request away from the deploy key.

The server key is pinned to a forced command: `SSH_ORIGINAL_COMMAND` is discarded, so the credential
can install a theme and nothing else. The archive is unpacked into a temp directory, checked for
traversal-looking paths and for the theme being present, then copied beside the live theme and
swapped in a single `mv`. Keep that order — copy first, swap last — so a half-written theme is never
live.

The tarball carries `tokens.css`, but the install copies only `keycloak/brockcsc`, so the palette
file is extracted and discarded.

## Testing a change

Only a real Keycloak tells you anything. Run one, mount the theme, set it on a test realm:

```sh
docker run --rm -p 8080:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  -v "$PWD/keycloak/brockcsc:/opt/keycloak/themes/brockcsc" \
  quay.io/keycloak/keycloak:26.0.8 start-dev
```

Dev mode doesn't cache themes, so a reload picks up a CSS edit. Check what a happy-path screenshot
misses: wrong password, focused field, long realm name, narrow viewport. Run `./scripts/validate.sh`
before pushing — CI runs the same script.

## Docs

The diagrams in `docs/img/` are hand-written SVG, committed and referenced with `<img>`, because
GitHub strips inline `<svg>`. A strict CSP blocks scripts, external images and web fonts, which is
why the login mock uses a system font stack instead of the theme's Geist.

Chrome and annotations use one flat palette legible on both GitHub themes rather than a pair per
theme: an SVG's `prefers-color-scheme` follows the operating system, not GitHub's setting. Inside the
mock the theme's real colours stand, since that part pictures a light UI.

Animation is CSS `@keyframes`, never SMIL, so it can be turned off — every animated file carries
`prefers-reduced-motion: reduce` and reads correctly when still.

`login-mock.svg` inlines the theme's real `logo.svg`. If the badge changes, regenerate the mock
rather than redrawing it, and keep the header block at the 76px the stylesheet sets. Update the
matching diagram in the same pull request as any colour, radius or deploy-script change.
