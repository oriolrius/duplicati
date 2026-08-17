# Duplicati docker image with docker logs support

This image is based on the official duplicati image and adds support for docker logs. This allows you to see the duplicati logs using `docker logs`. Specially useful when you have a centralised logging system like ELK, or Grafana Loki.

Current base image: **`duplicati/duplicati:2.3.0.4`** (stable, 2026-07-09).

## Considerations

- Duplicati doesn't support sending logs to the console.
- This image uses a workaround to send the logs to the console.
- Using "tail -F" command to follow the log file and send it to the console.
- Every day logrotate is launched to rotate the logs.
- Log files are stored in /backup folder.

## Usage

There is a docker-compose file in the repository that you can use to start the container.

You can also use the following command to start the container: (this is how I use it)

```bash
docker run -d --name duplicati \
  -v /:/mnt -v /backup:/backup \
  -v ./data:/data \
  --network host \
  -e DUPLICATI__WEBSERVICE_PASSWORD=your_password \
  ghcr.io/oriolrius/duplicati
```

- The `-v /:/mnt` host filesystem data; data to backup (data source).
- The `-v /backup:/backup` volume is the target backup directory.
- The `-v ./data:/data` volume is duplicati configuration and database.
- The `--network host` is used to allow the container to access the host network.

**NOTE**: All those parameters are optional. I shared them just for helping other about how do I use it.

The web UI listens on port **8200**.

## Configuration

All variables are optional, but see the note on `DUPLICATI__WEBSERVICE_PASSWORD` below. A ready to copy file is available in [`.env.sample`](.env.sample).

| Variable | Default | Description |
| --- | --- | --- |
| `DUPLICATI__WEBSERVICE_PASSWORD` | *(unset)* | Password for the web UI. Strongly recommended, see below. |
| `DUPLICATI__UNENCRYPTED_DATABASE` | *(unset)* | `true` starts the server with `--disable-db-encryption`, so the sensitive fields of the server database are stored in clear text. |
| `DUPLICATI__DEBUG_LEVEL` | `Information` | Log level: `Error`, `Warning`, `DryRun`, `Information`, `Retry`, `Profiling`. |
| `DUPLICATI__IMPORT_CONFIG` | *(unset)* | Directory with exported backup configurations (`*.json`). Every file is imported on start and renamed to `*.json.imported`. |
| `TZ` | *(container default)* | Timezone used by the web UI (`--webservice-timezone`). |

### Web UI password

Since Duplicati 2.1 the web UI is always authenticated. If `DUPLICATI__WEBSERVICE_PASSWORD` is not set, the server does not lock you out, but the only way in is a **single-use sign-in link that is printed to the log on every start and expires 5 minutes later**:

```
[Warning-Duplicati.Server.Program-ServerStartedSignin]: Use the following link to sign in: http://localhost:8200/signin.html?token=...
```

That is fine for a first look, but on a long running container it means fishing a fresh token out of `docker logs` (and shipping it to your log system) every time you want to open the UI. Set the variable.

### Database encryption

By default Duplicati encrypts the sensitive fields of its server database with a key derived from the machine. Two supported ways out of the warning it prints when it has no key of its own:

- `DUPLICATI__UNENCRYPTED_DATABASE=true` — no encryption at all.
- `SETTINGS_ENCRYPTION_KEY=<key>` — encrypt with your own key (passed straight through to Duplicati). Keep the key, the database is not readable without it.

### Importing configurations

When `DUPLICATI__IMPORT_CONFIG` points to a directory, every `*.json` in it is imported with `duplicati-server-util import`, and renamed to `*.json.imported` on success. `DUPLICATI__WEBSERVICE_PASSWORD` is passed as the *decryption passphrase* of the exported file, so export your configurations from the UI either unencrypted or using that same password.

## Upgrading

### to v2.0.3 (Duplicati 2.1.0.107 → 2.3.0.4)

Duplicati migrates its databases itself on the first start, but the migration is not meant to be reverted:

- the server configuration database is migrated to schema 11,
- every job database is migrated as well, on the first run of each job,
- afterwards, an older image can no longer read them. Duplicati 2.1+ ships `duplicati-database-tool downgrade` for job databases, but the safe move is a copy.

So, before pulling the new image:

1. stop the container,
2. copy the `/data` volume somewhere,
3. make sure `DUPLICATI__WEBSERVICE_PASSWORD` is set (see above),
4. start the new image and watch `docker logs`.

## Build

It uses github workflows to build the image. Pushes to `main` publish `ghcr.io/oriolrius/duplicati:main` and `:latest`, and pushing a `v*` tag publishes that version, e.g. `:v2.0.3`, and moves `:latest`.

You can also build the image locally using the following command:

```bash
docker build -t ghcr.io/oriolrius/duplicati .

or

docker compose build
```

## Greatings

This image is based on the work of [duplicati](https://github.com/duplicati/duplicati) and [logrotate](https://github.com/logrotate/logrotate).

Thank you for your work!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
