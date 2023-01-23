
![](https://static.wixstatic.com/media/e5b7d4_f67ff8c629844818a6e3e43550cb1e17~mv2.png/v1/fill/w_348,h_122,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Original%20on%20Transparent.png)

ITSM-NG is a GLPI fork with the objective of offering a strong community component and relevant technological choices.


# Some Links
  - [Website](https://www.itsm-ng.com)
  - [Github](https://github.com/itsmng)
  - [Wiki](https://wiki.itsm-ng.org)

# Storage of Data

| Volumes        | Description                                                                   |
|----------------|-------------------------------------------------------------------------------|
| itsmng-config  | He contain the database Information, the name and the login of MySQL database |
| itsmng-plugins | He contain all of the ITSM-NG plugins files                                   |
| itsmng-files   | He contain all of the attachments, and profile picture                        |
| itsmdata       | He contain all of the files of MariaDB.                                       |

# To start the container and the installation 
```
docker-compose up -d
```

# To shutdown the container 
```
docker-compose down
```

# Docker-Compose.yml
```
version: '3'
services:
  itsmweb :
    image : itsm-ng
    depends_on:
      - itsmdb
    container_name : itsmweb
    restart: always
    ports :
      - "80:80"
    volumes :
      - ./itsmng-config:/var/www/itsm-ng/config
      - ./itsmng-plugins:/var/www/itsm-ng/plugins
      - ./itsmng-files:/var/www/itsm-ng/files
    environment:
      MARIADB_USER : itsmng
      MARIADB_PASSWORD : itsmng
      MARIADB_DATABASE : itsmng
  itsmdb :
    image: mariadb
    container_name: itsmdb
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    volumes :
      - ../itsmdata:/var/lib/mysql
    environment:
      MARIADB_AUTO_UPGRADE: "yes"
      MARIADB_ALLOW_EMPTY_ROOT_PASSWORD: "yes"
      MARIADB_USER : itsmng
      MARIADB_PASSWORD : itsmng
      MARIADB_DATABASE : itsmng
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost", "-u", "root", "-p$$YSQL_ROOT_PASSWORD"]
      timeout: 20s
      retries: 10
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
