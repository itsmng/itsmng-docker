
![](https://static.wixstatic.com/media/e5b7d4_f67ff8c629844818a6e3e43550cb1e17~mv2.png/v1/fill/w_348,h_122,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Original%20on%20Transparent.png)

ITSM-NG is a GLPI fork with the objective of offering a strong community component and relevant technological choices.


# Some Links
  - [Website](https://www.itsm-ng.com)
  - [Github](https://github.com/itsmng)
  - [Wiki](https://wiki.itsm-ng.org)

# How to use this image
## Start a mariadb server instance
Starting a MariaDB instance with the latest version is simple:

```
docker run --detach --name itsm-ng --env MARIADB_HOST=itsmdb --env MARIADB_USER=itsmng --env MARIADB_PASSWORD=itsmng --env MARIADB_DATABASE=itsmng  itsm-ng:latest
```

## Environment Variables
Currently, we provide four variables to give the connection information to your MariaDB/MySQL database.

`MARIADB_HOST`

This variable is used to define the IP address of the database. This value can take an IP or a DNS/NetBIOS name.

`MARIADB_USER`

This variable is used to define the username to access on the database. You can use the root user or a specific user.

`MARIADB_PASSWORD`

This variable is used to define the password of the user database. If you have not a password, leave this variable empty.

`MARIADB_DATABASE`

This variable is used to define the database name. This database is used to save all of your tickets and data of your ITSM.
The user must have access to this database with writing permission.

## Default volumes configuration
The itsm-ng app is stored in `/var/www/itsm-ng` directory, this is the list of important files

| Volumes        | Description                                                                   |
|----------------|-------------------------------------------------------------------------------|
| itsmng-config  | The directory contains the database Information, the name and the login of MySQL database |
| itsmng-plugins | The directory contains all of the ITSM-NG plugins files                                  |
| itsmng-files   | The directory contains all of the attachments, and profile picture                      |
| itsmdata       | The directory contains all of the files of MariaDB.                                     |

## Docker-Compose.yml
```
version: '3'
services:
  itsmweb :
    image : itsm-ng/itsmng:1.3.0
    depends_on:
      - itsmdb
    container_name : itsmweb
    restart: always
    ports :
      - "8080:80"
    volumes :
      - itsmng-config:/var/www/itsm-ng/config
      - itsmng-plugins:/var/www/itsm-ng/plugins
      - itsmng-files:/var/www/itsm-ng/files
    environment:
      MARIADB_HOST : itsmdb
      MARIADB_USER : itsmng
      MARIADB_PASSWORD : itsmng
      MARIADB_DATABASE : itsmng
  itsmdb :
    image: mariadb:10.6
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
```

# Contributing

1. Fork it!
2. Create your feature branch: git checkout -b my-new-feature
3. Add your changes: git add folder/file1.php
4. Commit your changes: git commit -m 'Add some feature'
5. Push to the branch: git push origin my-new-feature
6. Submit a pull request !


# License

ITSM-NG Docker Image is GPLv3 licensed
