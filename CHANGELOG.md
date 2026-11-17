# Changelog

Breaking changes are listed first in each entry. Back up the database (MariaDB service) and the Monica `/var/www/html/storage` volume before you apply an update.

## 4.1.2-railway.1 (2026-11-17)

- First release of the template: Monica 4.1.2 (latest stable) in the official image `monica:4.1.2-apache@sha256:9319157715ef21ce4206b7efcc66a74ce4ae0eed8859905e69e1be6105e4ecef`, with MariaDB 11.8.9 (`mariadb:11.8.9@sha256:d36f18d65a0459510b8b0f643b226a6d299e3206486e2b64ff20754a6d291707`).
- The first account is created on the first start from `MONICA_ADMIN_EMAIL` and a generated password; public sign-up stays closed.
- README starts with the Deploy on Railway button for the published template.
- Health check `/healthz`; listens on `PORT`; the scheduler (reminders) runs in the app container.
