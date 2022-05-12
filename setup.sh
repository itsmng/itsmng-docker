#!/usr/bin/env bash

# Autre : variables globales ici 

containerName="itsmdb"

# 1 Bis : Voulez vous mettre a jour ou installer ?
echo "ITSM-NG SETUP: Install or Upgrade ? (I/U)"


while true; do
        read installWay
        case $installWay in
        [Ii]* ) update=0; break;;
        [Uu]* ) update=1; break;;
        * ) echo "Please answer I or U.";;
    esac
done

if [ $update -eq 1 ]; then
        if [ -d "itsmng" ] && [ -d "itsmdata" ]; then
                docker exec -w /app -u application itsmweb php bin/console itsmng:database:update --force
        fi
        exit
fi

if [ -d "itsmng" ] || [ -d "itsmdata" ]; then
        echo "Instalation failed: itsmng or itsmdata already exist"
        exit
fi

echo "Database user (empty for default):"
read databaseUser
while ! [[ $databaseUser =~ ^[a-zA-Z_0-9]+$ ]]; do
        if [$databaseUser = ""]
        then
                databaseUser="itsmng"
        else
                echo "Please choose valid database user"
                read databaseUser
        fi
done
sed -i "s/MYSQL_USER : .*/MYSQL_USER : $databaseUser/g" docker-compose.yml

echo "Database password (empty for default):"
read databasePassword
while ! [[ $databasePassword =~ ^[a-zA-Z_0-9]+$ ]]; do
        if [$databasePassword = ""]
        then
                databasePassword="itsmng"
        else
                echo "Please choose valid database password"
                read databasePassword
        fi
done
sed -i "s/MYSQL_PASSWORD : .*/MYSQL_PASSWORD : $databasePassword/g" docker-compose.yml

echo "Database name (empty for default):"
read databaseName
while ! [[ $databaseName =~ ^[a-zA-Z_0-9]+$ ]]; do
        if [$databaseName = ""]
        then
                databaseName="itsmng"
        else
                echo "Please choose valid database name"
                read databaseName
        fi
done
sed -i "s/MYSQL_DATABASE : .*/MYSQL_DATABASE : $databaseName/g" docker-compose.yml

# 2 Faire confirmer a l'utilisateur la config BDD / ITSM
# Aussi la version qui sera récupérée
version=$(curl -s https://api.github.com/repos/itsmng/itsm-ng/releases/latest | grep 'tag_name' | sed -E 's/.*"([^"]+)".*/\1/')

echo "➤   ITSM-NG version: $version"
echo "➤   Database user: $databaseUser"
echo "➤   Database name: $databaseName"
echo "➤   Container name: $containerName"

echo "Press any key to continue."
read



# 3 Récupération de l'archive 
# Variabiliser les infos ici (1.0.1 / lien git / etc...)
wget "https://github.com/itsmng/itsm-ng/releases/download/$version/itsm-ng-${version:1}.tar.gz" -q --show-progress
tar -xf itsm-ng-1.0.1.tar.gz
rm -rf itsm-ng-1.0.1.tar.gz
mv ./itsm-ng ./itsmng

# Composer a faire en arrière plan
docker-compose up -d

# MAIS détecter que les deux containers soit up et OK (healthy)
itsmweb=$(docker ps -f name=itsmweb --format "{{.Status}}" | grep -c 'Up')
itsmdb=$(docker ps -f name=itsmdb --format "{{.Status}}" | grep -c 'healthy')
result=$(($itsmweb+$itsmdb))
echo -en "\rPlease wait... ($result/2)"
while [ $itsmweb == 0 ] || [ $itsmdb == 0 ]; do
        itsmweb=$(docker ps -f name=itsmweb --format "{{.Status}}" | grep -c 'Up')
        itsmdb=$(docker ps -f name=itsmdb --format "{{.Status}}" | grep -c 'healthy')
        echo -en "\rPlease wait... ($result/2)"
        sleep 1
done

echo -e "\n"
docker ps -f name=itsmweb --format "{{.Status}}"
docker ps -f name=itsmdb --format "{{.Status}}"

# Quand docker OK envoyer les commandes d'install 
docker exec -w /app -u application itsmweb php bin/console itsmng:database:install -H $containerName -u $databaseUser -p $databasePassword -d $databaseName --force

# Récap et fermeture du script 
echo -e 'Go to: http://127.0.0.1:9080'
exit