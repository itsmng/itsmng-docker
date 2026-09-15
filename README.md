
![](https://static.wixstatic.com/media/e5b7d4_f67ff8c629844818a6e3e43550cb1e17~mv2.png/v1/fill/w_348,h_122,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Original%20on%20Transparent.png)

ITSM-NG is a GLPI fork with the objective of offering a strong community component and relevant technological choices.

# Some Links

  - [Website](https://www.itsm-ng.com)
  - [Github](https://github.com/itsmng)
  - [Wiki](https://wiki.itsm-ng.org)

# Image design

A single image covers every role. There is no entrypoint and no start-up
configuration script: the container runs Apache as PID 1, and one-shot
operations are explicit commands.

| Command | Purpose |
|-----------------|-----------------------------------------------------------|
| *(default)* | `apache2 -D FOREGROUND`, serves the application on `:8080` |
| `itsmng-init` | creates the data tree, then installs or migrates the schema |
| `itsmng-cron` | runs one pass of the scheduled tasks and exits |
| `itsmng-console`| wrapper around `bin/console` |

Everything is decided at build time:

  - **No `apt-get` at runtime.** Plugins are baked into the image through the
    `ITSMNG_PLUGINS` build argument, so a container is reproducible and its
    filesystem can stay read-only.
  - **No `chown` / `chmod` at runtime.** Writable paths belong to group `0`
    with the owner's permissions, so the image runs under an arbitrary UID.
    On Kubernetes, `fsGroup` does what the old `chown -R` used to do.
  - **No configuration written at runtime.** `/etc/itsm-ng/config_db.php` is
    shipped in the image and reads the environment.
  - **Non-root, unprivileged.** UID `1000`, group `0`, port `8080`, no
    capability required: compatible with the Kubernetes Pod Security
    Admission `restricted` profile and with `readOnlyRootFilesystem: true`.
  - **One process per container.** Apache with `mod_php`, no `php-fpm`
    started from an init script, no supervisor, no cron daemon.

Only `/var/lib/itsm-ng` needs to persist. `/tmp` and `/run/apache2` must be
writable, and a `tmpfs` / `emptyDir` is enough for both.

# How to use ITSM-NG image

## Stack (Compose)

    git clone https://github.com/itsmng/itsmng-docker
    cd itsmng-docker/latest
    cp .env.example .env        # then set MARIADB_PASSWORD
    docker compose up -d

The stack starts MariaDB, waits for it to be healthy, runs `itsmng-init`
once, then starts the web container. The application is available on
[http://localhost:8080](http://localhost:8080).

Run the scheduled tasks, or any console command:

    docker compose run --rm cron
    docker compose run --rm itsmng-console itsmng:database:update

## Standalone

    docker run -d --name itsm-ng \
      -e MARIADB_HOST=db.example.org \
      -e MARIADB_USER=itsmng \
      -e MARIADB_PASSWORD=... \
      -e MARIADB_DATABASE=itsmng \
      -p 8080:8080 \
      --read-only --tmpfs /tmp --tmpfs /run/apache2 \
      --cap-drop ALL --security-opt no-new-privileges \
      -v itsmng-data:/var/lib/itsm-ng \
      ghcr.io/itsmng/itsm-ng:latest

Initialise the database once, with the same environment and volume:

    docker run --rm -e MARIADB_HOST=... [...] \
      -v itsmng-data:/var/lib/itsm-ng \
      ghcr.io/itsmng/itsm-ng:latest itsmng-init

## Kubernetes

`deploy/kubernetes/` holds a complete example compliant with the
`restricted` Pod Security Admission profile: Deployment (read-only rootfs,
`emptyDir` for `/tmp` and `/run/apache2`), Service, PVC, the `itsmng-init`
Job and the `itsmng-cron` CronJob.

    kubectl create ns itsm-ng
    kubectl label ns itsm-ng \
      pod-security.kubernetes.io/enforce=restricted \
      pod-security.kubernetes.io/enforce-version=latest
    kubectl -n itsm-ng apply -k deploy/kubernetes
    kubectl -n itsm-ng wait --for=condition=complete job/itsm-ng-init --timeout=10m

The web Deployment never touches the schema; re-run the Job after a version
bump to apply migrations.

## Environment variables

| Variable | Description | Default |
|--------------------|-------------------------------------------|-------------|
| `MARIADB_HOST` | database hostname | `localhost` |
| `MARIADB_PORT` | database port | `3306` |
| `MARIADB_USER` | database username | `itsmng` |
| `MARIADB_PASSWORD` | database user password | |
| `MARIADB_DATABASE` | database name | `itsmng` |
| `MARIADB_SSL_CA` | CA bundle for TLS to the database | |
| `MARIADB_SSL_CERT` | client certificate for TLS | |
| `MARIADB_SSL_KEY` | client key for TLS | |

Every variable above also accepts a `_FILE` suffix pointing at a file
(`MARIADB_PASSWORD_FILE=/run/secrets/itsm-ng/password`). Use that form with a
Kubernetes Secret or a Docker secret so the credential never appears in the
process environment.

`itsmng-init` additionally reads `ITSMNG_DB_WAIT_TIMEOUT` (seconds to wait for
the database, default `60`, `0` to disable).

To take over the connection configuration entirely, mount your own file over
`/etc/itsm-ng/config_db.php`. To override PHP settings, mount an `.ini` file
into `/etc/php/8.4/apache2/conf.d/`.

## Volumes

| Path | Description |
|----------------------|-------------------------------------------------------------|
| `/var/lib/itsm-ng` | the only persistent volume: cache, sessions, documents, dumps, application logs |
| `/tmp` | writable, `tmpfs` is fine |
| `/run/apache2` | writable, `tmpfs` is fine (pid and mutex files) |

The application code, the plugins and the configuration all live in the image
and are never mounted, which is what makes an immutable deployment possible.

## Building

    cd latest
    make build                                    # local image
    make lint                                     # hadolint + shellcheck
    docker buildx bake --set itsmng.args.ITSMNG_PLUGINS="formcreator pdf tag"

Build arguments:

| Argument | Description |
|-----------------------|------------------------------------------------------|
| `ITSMNG_PLUGINS` | space-separated plugin list, installed into the image |
| `ITSMNG_APT_VERSION` | exact `itsm-ng` Debian package version to pin |
| `ITSMNG_APT_URI` | APT repository URI |
| `PHP_VERSION` | PHP version used for `mod_php` and the config paths |
| `UID` | application UID (group is always `0`) |

Adding a plugin means a new image, not a mutated container: append it to
`ITSMNG_PLUGINS`, rebuild, redeploy.

# Contributing

1. Fork it!
2. Create your feature branch: git checkout -b my-new-feature
3. Add your changes: git add folder/file1.php
4. Commit your changes: git commit -m 'Add some feature'
5. Push to the branch: git push origin my-new-feature
6. Submit a pull request !

# License

ITSM-NG Docker Image is GPLv3 licensed
