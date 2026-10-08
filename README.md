# Home Setup

Docker Compose based home server stack. It is the infrastructure part of my home server
and it is meant to be run together with the other repositories: `home-api`,
`home-dashboard`, `scanner-service`, `reverse-proxy` and `home-backup`.

One `docker compose up -d` starts the database, the automation engine, the document
archive, the finance tools, the recipe and inventory apps and the reverse proxy. The
custom applications (API, dashboard, scanner) live in their own repositories and are
mounted into this stack.

## Services

| Service | Image / build | Purpose |
|---|---|---|
| `api` | `./appserver/api` | Home API (NestJS). The source lives in the `home-api` repository and is expected at `appserver/api`. |
| `dashy` | `lissy93/dashy` | Start page with custom widgets for the car and the documents |
| `n8n` | `n8nio/n8n` | Automation workflows, uses the custom `myhelpers` node module |
| `firefly` | `fireflyiii/core` | Personal finance manager |
| `firefly-importer` | `fireflyiii/data-importer` | CSV and bank import for Firefly III |
| `paperless` | `ghcr.io/paperless-ngx/paperless-ngx` | Document archive with OCR |
| `paperless-ai` | `clusterzx/paperless-ai` | LLM based document tagging |
| `gotenberg`, `tika` | | Converters used by paperless |
| `mealie` | `ghcr.io/mealie-recipes/mealie` | Recipe manager |
| `grocy` | `lscr.io/linuxserver/grocy` | Household inventory |
| `dbhome` | `pgvector/pgvector:pg18` | Central PostgreSQL instance with pgvector |
| `redis` | `redis:alpine` | Cache and queue backend used by n8n and paperless |
| `nginxautossh` | `./nginx` | nginx plus autossh reverse proxy. The sources live in the `reverse-proxy` repository. |

## Getting started

```bash
cp .env.example .env          # fill in your own values
cp n8n/.env.example n8n/.env
cp firefly_iii/.env.example firefly_iii/.env
cp firefly_iii/.importer.env.example firefly_iii/.importer.env

docker compose up -d
```

Create the Paperless superuser once:

```bash
docker compose run --rm paperless createsuperuser
```

### Expected folder layout

`docker compose` mounts a few host folders that are not part of this repository. Create
them first. They are either empty or filled by the containers at runtime:

```bash
mkdir -p appserver/api appserver/dashboard/app nginx mealie/data grocy/config \
         dbhome/db n8n/n8n-config
```

`appserver/api`, `appserver/dashboard/app` and `nginx` are clones of the sibling
repositories (`home-api`, `home-dashboard`, `reverse-proxy`). The API also needs its own
`appserver/api/app/.env`, see the `home-api` README. The other folders hold runtime data
and are gitignored.

### First start of the database

`dbhome/init` contains the SQL that creates one database and one owner role per service
on a fresh volume. Replace every `change-me` password in that file and in `.env` before
the first start, they have to match.

## AI usage

AI runs in three places in this stack.

- `paperless-ai` reads new documents from Paperless and asks an LLM for title, tags and
  correspondents. It is configured in its own web UI after the first start (port `3010`
  on the host).
- `mealie` gets `OPENAI_API_KEY` and `OPENAI_MODEL` from `.env` (`GENERAL_DATA_OPENAI_KEY`
  and `GENERAL_DATA_OPENAI_MODEL`) and uses them for its recipe import.
- The n8n workflows use LLM providers as well. The keys for those live in
  `n8n/.env.example` (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`) and stay in the n8n
  credential store.

The transaction matching that runs inside `home-api` is described in that repository.

## Custom n8n helper functions

`n8n/n8n-function-helpers` is a small TypeScript package that is mounted into the n8n
container as the `myhelpers` module. Build it before starting the stack:

```bash
cd n8n/n8n-function-helpers
yarn install
yarn build
```

## Dashy customisation

- `dashy/user-data/` holds the page definitions (`conf.yml`, `car.yml`, `documents.yml`).
- `dashy/widgets/` holds the custom `zp-api-response` and `zp-button-list` widgets.
- `dashy/custom/` holds the theme and the authentication headers. The API key is read
  from the `VUE_APP_API_KEY` build time variable and is not hardcoded.

## Notes

- Runtime data (`dbhome/db`, `paperless/data`, `paperless/media`, `redis/redis-data`,
  `n8n/n8n-config`, `mealie/data` and others) is excluded from git.
- The physical scanner is not part of this repository. See the `scanner-service`
  repository for the NAPS2 profile, `scanWin.bat` and the Windows service, and the
  `documents` module of `home-api`.
- `$SCANFOLDER` on the host is mounted into the paperless consume folder and
  `$BACKUPFOLDER` is mounted into `/backup`. Both are defined in `.env`.
- `firefly_iii/firefly_iii_import_configurations/` holds the CSV import profiles of the
  Firefly III data importer, one per account type. The IBANs in them are placeholders.
- `HomeAssistant/connectJbl.txt` is a helper `bluetoothctl` script for a Bluetooth
  speaker. Replace the MAC address with the one of your own device.
- Timezone, languages and OCR settings come from `.env`. The defaults assume a central
  European setup.

## License

MIT, see [`LICENSE`](LICENSE).
