#!/bin/bash

# Purpose: Deploy Kea DHCP or Stork on localhost

# Usage (run as sudo):
# - chmod +x kea-build.sh
# - ./kea-build.sh

# Set variables for the build
VARS_DIRECTORY=""
BUILD_VARS_FILE="kea-build-vars.txt"

# Check if user is root
function isRoot() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
}

# Action: Show variables for selected
function variables() {
    read -p "Enter the path to the folder containing the variables for the build (dhcp-primary): " VARS_DIRECTORY
    VARS_DIRECTORY=${VARS_DIRECTORY:-dhcp-primary}
    echo "Variables for the build:"
    SOURCE="${VARS_DIRECTORY}/${BUILD_VARS_FILE}"
    source $SOURCE
    cat $SOURCE
}

function validateKeaDHCPServices() {
    echo "Validating Kea DHCP services"
    # Chek if any of the services are running, exit if one is not running
    if ! systemctl is-active --quiet isc-kea-dhcp4-server; then
        echo "Kea DHCP4 server is not running. Exiting."
        exit
    elif ! systemctl is-active --quiet isc-kea-dhcp6-server; then
        echo "Kea DHCP6 server is not running. Exiting."
        exit
    elif ! systemctl is-active --quiet isc-kea-ctrl-agent; then
        echo "Kea Control Agent is not running. Exiting."
        exit
    fi
}

# Action: Deploy Kea DHCP server
function deployKeaDHCP() {
    echo "Deploying Kea DHCP server"
    ## Install Kea DHCP server
    # Update and upgrade packages
    apt -y update && apt -y dist-upgrade
    # Setup repository
    curl -1sLf $CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Kea packages
    apt -y install isc-kea*
    # Enable and start Kea services
    systemctl enable isc-kea-dhcp4-server
    systemctl start isc-kea-dhcp4-server
    # Replace the Kea Control Agent configuration file (overwrite without confirmation)
    \cp -f $VARS_DIRECTORY/kea-ctrl-agent.conf /etc/kea/kea-ctrl-agent.conf
    # Add permissions and ownership to the Kea Control Agent configuration file
    chmod 644 /etc/kea/kea-ctrl-agent.conf
    # Enable and start the Kea control agent
    systemctl enable isc-kea-ctrl-agent
    systemctl start isc-kea-ctrl-agent

    ## Install Kea DHCP database
    # Install PostgreSQL
    apt -y install postgresql postgresql-contrib
    # Enable and start PostgreSQL
    systemctl enable postgresql.service
    systemctl start postgresql.service
    # Log into PostgreSQL as root
    sudo -u postgres psql postgres
    # Create a database for Kea
    CREATE DATABASE $DATABASE_NAME;
    # Create the user under which Kea will access the database
    CREATE USER $DATABASE_USER WITH PASSWORD '${DATABASE_USER_PASSWORD}';
    # Grant the user access to the database
    GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;
    # Improve PostgreSQL Performance
    ALTER SYSTEM SET synchronous_commit=OFF;
    # Exit PostgreSQL
    \q
    # Initialize the PostgreSQL Database Using kea-admin
    kea-admin db-init pgsql -u $DATABASE_USER -p $DATABASE_USER_PASSWORD -n $DATABASE_NAME

    ## Configure Kea DHCP server
    # Replace the Kea DHCP4 server configuration file (overwrite without confirmation)
    \cp -f $VARS_DIRECTORY/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf
    # Add permissions and ownership to the Kea DHCP4 server configuration file
    chmod 644 /etc/kea/kea-dhcp4.conf
    # Replace the Kea DHCP6 server configuration file (overwrite without confirmation)
    \cp -f $VARS_DIRECTORY/kea-dhcp6.conf /etc/kea/kea-dhcp6.conf
    # Add permissions and ownership to the Kea DHCP6 server configuration file
    chmod 644 /etc/kea/kea-dhcp6.conf
}

function deployKeaStork() {
    echo "Deploying Stork server"
}

# Prompt: Proceed with the deployment? (y/N)
function proceed() {
    read -p "Proceed with the deployment? (y/N): " PROCEED
    PROCEED=${PROCEED:-N}
    if [[ $PROCEED =~ ^[yY]$ && deploy ]]; then
        # echo "Proceeding with the deployment"
        return 0
    else
        echo "Exiting"
        exit
    fi
}

# Prompt: Deploy Kea DHCP server or Stork server? (D/s)
function deploy() {
    read -p "Deploy Kea DHCP server or Stork server? (D/s): " DEPLOYMENT
    DEPLOYMENT=${DEPLOYMENT:-D}
    if [[ $DEPLOYMENT =~ ^[dD]$ ]]; then
        variables
        if proceed; then
            deployKeaDHCP
        fi
    elif [[ $DEPLOYMENT =~ ^[sS]$ ]]; then
        variables
        if proceed; then
            deployKeaStork
        fi
    else
        echo "Invalid selection"
        exit
    fi
}

# if ! isRoot; then
#     echo "You need to run this script as root. Exiting."
#     exit
# fi

deploy
