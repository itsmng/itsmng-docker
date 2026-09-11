
![](https://static.wixstatic.com/media/e5b7d4_f67ff8c629844818a6e3e43550cb1e17~mv2.png/v1/fill/w_348,h_122,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Original%20on%20Transparent.png)

ITSM-NG is a GLPI fork with the objective of offering a strong community component and relevant technological choices.

# Some Links

  - [Website](https://www.itsm-ng.com)
  - [Github](https://github.com/itsmng)
  - [Wiki](https://wiki.itsm-ng.org)

# How to use ITSM-NG image

## Run an ITSM-NG instance

### Standalone

Before run ITSM-NG instance, please refer to the [MariaDB docker documentation](https://hub.docker.com/_/mariadb) to create your own database container.

To start application instance with the latest version :

    podman run \
    --name [MY_CONTAINER_NAME] \
    -e MARIADB_HOST=[DB_HOST] \
    -e MARIADB_DATABASE=[DB_NAME] \
    -e MARIAD_USER=[DB_USER] \
    -e MARIADB_PASSWORD=[DB_PASSWORD] \
    -idt docker.io/itsmng/itsm-ng:latest

### Stack

We have a `podman-compose` example in every folder for each tag of our image.

To get these examples / templates, clone our git repository :

    git clone https://github.com/itsmng/itsmng-docker

To start the ITSM-NG application stack, run the following command :

    podman-compose up -d

By default, volume names use the current version as a prefix (i.e. 1.3.0 => 130_volumename). You can set a custom prefix with the next command :

    podman-compose -p MY_PREFIX up -d

You can check if containers are running correctly with the next command :

    podman container ls

The container status is `Up` if it works.

Now, your ITSM-NG application is available at the following address [http://localhost:8080](http://localhost:8080).

## Running under a restricted PodSecurityStandard (Kubernetes)

Since this image, the container runs entirely as the unprivileged `www-data` user
(uid/gid `33`), listens on port `8080` (not `80`), and never needs to `chown`/`chmod`
anything at runtime. This makes it compatible with a `securityContext` such as:

    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      privileged: false
      readOnlyRootFilesystem: true
      runAsGroup: 33
      runAsNonRoot: true
      runAsUser: 33
      fsGroup: 33
      seLinuxOptions: {}
      seccompProfile:
        type: RuntimeDefault

Because the root filesystem is read-only, Apache/PHP-FPM still need a few
writable, non-persistent directories for pid/lock/log files. Mount an
`emptyDir` volume on each of the following paths:

| Path                 | Purpose                          |
|----------------------|-----------------------------------|
| `/tmp`               | Generic scratch space            |
| `/run/apache2`       | Apache PID file                  |
| `/var/lock/apache2`  | Apache lock files                |
| `/var/log/apache2`   | Apache logs (also sent to stdout/stderr) |
| `/run/php`           | PHP-FPM socket/PID file           |

With Kubernetes, the `fsGroup: 33` in the `securityContext` above makes the
kubelet automatically set up each `emptyDir` as group-writable by `33`, so no
extra configuration is needed. When testing locally with plain `docker run
--read-only --tmpfs ...`, pass an explicit owner on each mount (Docker's
tmpfs defaults to `root:root`), e.g. `--tmpfs /tmp:uid=33,gid=33`.

Plugins can no longer be installed at runtime (it required root privileges and
a writable root filesystem). Bake them into the image instead with the
`ITSMNG_PLUGINS` build argument, e.g.:

    podman build --build-arg ITSMNG_PLUGINS="accounts barcode formcreator" -t itsmng .


## Environment variables

You will find below the list of all available environments variables for our docker image.

| Variable           | Description                               |
|--------------------|-------------------------------------------|
| `MARIADB_HOST`     | Used to define the database hostname      |
| `MARIADB_USER`     | Used to define the database username      |
| `MARIADB_PASSWORD` | Used to define the database user password |
| `MARIADB_DATABASE` | Used to define the database name          |

## Volumes information

Below you will find the volumes list created by ITSM-NG docker application and their description :

| Volume           | Description                                                      |
|------------------|------------------------------------------------------------------|
| `itsmng-config`  | It contains the application configuration                        |
| `itsmng-plugins` | It contains the application plugins                              |
| `itsmng-files`   | It contains the application extra data (logs, cache, attachment) |
| `itsmng-data`    | It contains the MariaDB instance data                            |

## Docker-compose.yml sample

    version: '3'
    services:
      itsmweb :
        image : docker.io/itsmng/itsm-ng:latest
        depends_on:
          - itsmdb
        container_name : itsmweb
        restart: always
        ports :
          - "8080:8080"
        volumes :
          - itsmng-config:/etc/itsm-ng/config
          - itsmng-plugins:/usr/share/itsm-ng/plugins
          - itsmng-files:/var/lib/itsm-ng
        environment:
          MARIADB_HOST : itsmdb
          MARIADB_USER : itsmng
          MARIADB_PASSWORD : itsmng
          MARIADB_DATABASE : itsmng
          # Install plugins at build time instead (--build-arg ITSMNG_PLUGINS="..."):
          #   accounts
          #   barcode
          #   consumables
          #   databases
          #   dashboardng
          #   datainjection
          #   edittraduction
          #   escalade
          #   fields
          #   formcreator
          #   genericobject
          #   mreporting
          #   news
          #   oauthimap
          #   ocsinventoryng
          #   okta
          #   onetimesecret
          #   pdf
          #   tag
          #   timelineticket
          #   useditemsexport
          #   whitelabel
          #   workflows
      itsmdb :
        image: docker.io/mariadb:10.6
        container_name: itsmdb
        command: --default-authentication-plugin=mysql_native_password
        restart: always
        volumes :
          - itsmng-data:/var/lib/mysql
        environment:
          MARIADB_AUTO_UPGRADE: "yes"
          MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: "yes"
          MYSQL_ROOT_PASSWORD: iamastrongpassword
          MARIADB_USER : itsmng
          MARIADB_PASSWORD : itsmng
          MARIADB_DATABASE : itsmng

    volumes:
      itsmng-config:
      itsmng-plugins:
      itsmng-files:
      itsmng-data:

# Contributing

1. Fork it!
2. Create your feature branch: git checkout -b my-new-feature
3. Add your changes: git add folder/file1.php
4. Commit your changes: git commit -m 'Add some feature'
5. Push to the branch: git push origin my-new-feature
6. Submit a pull request !

# License

ITSM-NG Docker Image is GPLv3 licensed
