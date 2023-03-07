#!/bin/bash

set -e

DB_NAME=${1:-my_pg_user}
DB_USER=${2:-my_awesome_db}
DB_USER_PASS=${3:-hard_password}

sudo su postgres <<EOF
createdb  $DB_NAME;
psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_USER_PASS';"
psql -c "grant all privileges on database $DB_NAME to $DB_USER;"
echo "Postgres User '$DB_USER' and database '$DB_NAME' created."
EOF
