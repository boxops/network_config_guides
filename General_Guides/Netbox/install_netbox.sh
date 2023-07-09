# Variables
DATABASE_NAME='netbox'
DATABASE_USER='netbox'
DATABASE_USER_PASSWORD='123qwe'


# Update / Upgrade system
sudo apt -y update && sudo apt -y dist-upgrade

# Install Postgresql
sudo apt -y install postgresql

# Create Netbox database
sudo su postgres <<EOF
psql -c "CREATE DATABASE $DATABASE_NAME;"
psql -c "CREATE USER $DATABASE_USER WITH PASSWORD '$DATABASE_USER_PASSWORD';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"
EOF
echo "Created Postgres User '$DATABASE_USER' and database '$DATABASE_NAME'."

