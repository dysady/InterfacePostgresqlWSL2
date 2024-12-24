#!/bin/bash


# Demande du mot de passe sudo une fois
echo "Veuillez entrer votre mot de passe sudo (il ne sera pas demandé à nouveau) :"
sudo -v

# Fonction pour vérifier l'état de PostgreSQL
check_status() {
    sudo -u postgres pg_ctlcluster 14 main status
}

# Fonction pour stop Postgresql
# sudo -u postgres pg_ctlcluster 13 main stop

# Fonction pour démarrer PostgreSQL si nécessaire
start_postgresql() {
    status=$(sudo -u postgres pg_ctlcluster 14 main status)
    if [[ $status == *"stopped"* ]]; then
        echo "PostgreSQL n'est pas démarré. Démarrage de PostgreSQL..."
        sudo -u postgres pg_ctlcluster 14 main start
    else
        echo "PostgreSQL est déjà en cours d'exécution."
    fi
}

# Fonction pour afficher les bases de données disponibles
list_databases() {
    sudo -u postgres psql -c "
    SELECT 
        d.datname AS dbname,
        pg_catalog.pg_get_userbyid(d.datdba) AS owner, 
        pg_catalog.current_setting('listen_addresses') AS host, 
        pg_catalog.current_setting('port') AS port,
        r.rolname AS user
    FROM 
        pg_catalog.pg_database d
    JOIN 
        pg_catalog.pg_roles r ON r.oid = d.datdba
    WHERE 
        d.datistemplate = false;
    "
}

# Fonction pour afficher les utilisateurs PostgreSQL
list_users() {
    sudo -u postgres psql -c "\du"
}

# Fonction pour créer une nouvelle base de données
create_database() {
    read -p "Entrez le nom de la nouvelle base de données : " dbname
    sudo -u postgres psql -c "CREATE DATABASE $dbname;"
    echo "Base de données '$dbname' créée."
}

# Fonction pour supprimer une base de données
drop_database() {
    read -p "Entrez le nom de la base de données à supprimer : " dbname
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS $dbname;"
    echo "Base de données '$dbname' supprimée."
}

# Fonction pour sélectionner une base de données
select_database() {
    read -p "Entrez le nom de la base de données à sélectionner : " dbname
    sudo -u postgres psql $dbname
}

# Fonction pour mettre à jour PostgreSQL sur WSL 2
update_postgresql() {
    sudo apt update
    sudo apt upgrade postgresql postgresql-contrib -y
    echo "PostgreSQL a été mis à jour."
}

#start_postgresql()
sudo service postgresql start
#sudo service postgresql start

# Menu principal
while true; do
    echo ""
    echo "=== Menu PostgreSQL ==="
    echo "1. Afficher l'état de PostgreSQL"
    echo "2. Afficher les bases de données disponibles"
    echo "3. Afficher les utilisateurs PostgreSQL"
    echo "4. Créer une nouvelle base de données"
    echo "5. Supprimer une base de données"
    echo "6. Sélectionner une base de données"
    echo "7. Mettre à jour PostgreSQL sur WSL 2"
    echo "8. Quitter"
    echo ""
    read -p "Sélectionnez une option (1-8) : " option

    case $option in
        1)
            check_status
            ;;
        2)
            list_databases
            ;;
        3)
            list_users
            ;;
        4)
            create_database
            ;;
        5)
            drop_database
            ;;
        6)
            select_database
            ;;
        7)
            update_postgresql
            ;;
        8)
            echo "Sortie du script."
            exit 0
            ;;
        *)
            echo "Option invalide. Essayez à nouveau."
            ;;
    esac
done
