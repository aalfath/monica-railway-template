[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/monica-1?utm_medium=integration&utm_source=button&utm_campaign=monica)

# Monica on Railway

A Railway template for [Monica](https://www.monicahq.com) **4.1.2**, the open-source personal relationship manager (personal CRM): contacts, relationships, notes, activities, reminders, gifts, debts, journal entries, documents and photos, with CardDAV/CalDAV sync and an API.

## What the template deploys

| Service | Source | Volume | What it does |
|---|---|---|---|
| `Monica` | this repo (`Dockerfile`) | `/var/www/html/storage` | Web app (Apache + PHP 8.2) and the scheduler, on the public domain |
| `MariaDB` | `mariadb:11.8.9`, pinned by digest | `/var/lib/mysql` | Monica's database, private network only |

- `Dockerfile`: the official Docker Hub image `monica:4.1.2-apache`, pinned by digest. Monica 5.x is still beta, so this template stays on 4.x until 5.0 is released as stable.
- `railway-start.sh`: listens on `PORT`, sets `APP_URL` from the Railway domain, trusts Railway's HTTPS proxy, keeps sign-up closed, refuses the image's placeholder `APP_KEY`/`HASH_SALT`, then runs the image's own entrypoint (waits for the database, runs migrations, creates the OAuth keys).
- `apache2-railway` and `railway-owner.php`: on an empty database, create the first account from `MONICA_ADMIN_EMAIL` and the generated `MONICA_ADMIN_PASSWORD`, so nobody else can claim a fresh public deploy. Then start the scheduler (reminders, "stay in touch" emails) and Apache.
- `/healthz` answers 200 once Apache runs, which is after the migrations. Railway uses it as the health check.

## Variables

| Service | Variable | Default | What it does |
|---|---|---|---|
| Monica | `MONICA_ADMIN_EMAIL` | asked at deploy | Login email of the first account, created on the first start |
| Monica | `MONICA_ADMIN_PASSWORD` | generated secret | Its password. Read it in the service's Variables tab; change it in Monica later |
| Monica | `APP_KEY`, `HASH_SALT` | generated secrets | Laravel encryption key and ID salt. Don't change them after the first start |
| Monica | `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL. Change it if you add a custom domain |
| Monica | `PORT` | `8080` | Port Apache listens on; the domain points at it |
| Monica | `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` | references to `MariaDB` | Database connection over the private network |
| MariaDB | `MARIADB_DATABASE`, `MARIADB_USER` | `monica` | Database and user created on the first start |
| MariaDB | `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD` | generated secrets | Database passwords |

`MONICA_ADMIN_EMAIL` and `MONICA_ADMIN_PASSWORD` are used once, while the database has no account. Sign-up stays closed (`APP_DISABLE_SIGNUP=true`); invite other users from Monica's settings, or set `APP_DISABLE_SIGNUP=false` on purpose.

Optional settings from Monica's [`.env` reference](https://github.com/monicahq/monica/blob/v4.1.2/.env.example) can be added as variables on the Monica service:

- **Email** (reminders, invitations): `MAIL_MAILER=smtp`, `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`, `MAIL_FROM_ADDRESS`. Without them, mail is only written to the log.
- **Weather** on contact pages: `ENABLE_WEATHER=true` and your own `WEATHERAPI_KEY`. **Geolocation** of addresses: `ENABLE_GEOLOCATION=true` and `LOCATION_IQ_API_KEY`.

## After deploy

1. Open the Monica service's domain and sign in with `MONICA_ADMIN_EMAIL` and the generated `MONICA_ADMIN_PASSWORD` (Monica service → Variables).
2. Change the password and turn on two-factor authentication under **Settings → Security**.
3. For phone or desktop sync, use CardDAV/CalDAV at `https://YOUR-DOMAIN/dav/`.

## Updates

Version bumps are merged to `main` here. Railway shows deployers of this template an "update available" notice, and they choose when to apply it. On start, a newer image runs Monica's database migrations by itself. Each version is listed in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Back up the MariaDB volume and the Monica volume before a major update.
