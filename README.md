# GlitchTip on Railway

A Railway template for [GlitchTip](https://glitchtip.com), the open-source, Sentry-compatible error tracking, performance and uptime monitoring platform.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| **GlitchTip** | this repo (`Dockerfile`) | Official `glitchtip/glitchtip:7.0.0` image, pinned by digest. One process serves the web UI and API and runs the background tasks and scheduler. Public domain, health check on `/_health/`, uploads (source maps, debug files) on a volume at `/code/uploads`. |
| **Postgres** | Railway's PostgreSQL | Events, users, projects. GlitchTip 7 needs PostgreSQL 15 or newer. |
| **Redis** | Railway's Redis | Cache and task queue (`VALKEY_URL`). |

## Variables

| Variable | Default | Notes |
|---|---|---|
| `GLITCHTIP_ADMIN_EMAIL` | *(you enter it)* | Email of the first admin account, created on first boot. |
| `GLITCHTIP_ADMIN_PASSWORD` | generated | Password for that account. Read it in the GlitchTip service's Variables tab. Only used on first boot: change it later in GlitchTip's profile page. |
| `SECRET_KEY` | generated | Django secret key. |
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | |
| `VALKEY_URL` | `${{Redis.REDIS_URL}}` | |
| `GLITCHTIP_DOMAIN` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used in links and DSNs. Change it if you add a custom domain. |
| `PORT` | `8000` | |

Open sign-up is off (`ENABLE_USER_REGISTRATION=False`): the admin invites other users from an organization's Members page. Only superusers can create organizations (GlitchTip's default).

Optional settings, added as variables on the GlitchTip service:

- **Email** (invites, password reset, alerts): `EMAIL_URL=smtp://user:password@smtp.example.com:587` and `DEFAULT_FROM_EMAIL`. Without it, GlitchTip still works, and emails are only written to the log.
- **Open sign-up:** `ENABLE_USER_REGISTRATION=True`.
- **Retention:** `GLITCHTIP_RETENTION_DAYS` (default 90).
- More in GlitchTip's [configuration docs](https://glitchtip.com/documentation/install#configuration).

## How the wrapper works

`railway-start.sh` gives the volume to GlitchTip's unprivileged `app` user, fills in `GLITCHTIP_DOMAIN` from Railway's public domain if it's unset, runs `manage.py init_database` (retried while Postgres starts), creates the admin account if it doesn't exist yet, and then runs the upstream `./bin/start.sh` as the `app` user.

## Updates

The GlitchTip service builds from this repo. When a new GlitchTip version is tested, the `FROM` line in the `Dockerfile` is bumped and merged to `main`, and Railway shows "update available" to everyone who deployed the template. Read [CHANGELOG.md](CHANGELOG.md) before you apply one. Database migrations run on start.

GlitchTip only upgrades one major version at a time (6.x to 7.0, not 5.x to 7.0).

## Links

- GlitchTip: https://glitchtip.com · source: https://gitlab.com/glitchtip/glitchtip-backend
- Release notes: https://gitlab.com/glitchtip/glitchtip-backend/-/releases
