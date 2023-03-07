#!/bin/bash

# Purpose: Deploy Kea DHCP or Stork on localhost

# Usage (run as sudo):
# sudo su -
# chmod +x kea-build.sh
# ./kea-build.sh

# Set variables for the build
VARS_DIRECTORY=""
VARS_BUILD_FILE="kea-build.env"
# agent.env or server.env
VARS_ENV_FILE="[agent|server].env"

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
    echo "Imported the following variables for the build from (${VARS_DIRECTORY}/${VARS_BUILD_FILE}):"
    echo
    # Import build variables
    BUILD_SOURCE="${VARS_DIRECTORY}/${VARS_BUILD_FILE}"
    source $BUILD_SOURCE
    cat $BUILD_SOURCE
    # Import environment variables
    ENV_SOURCE="${VARS_DIRECTORY}/${VARS_ENV_FILE}"
    source $ENV_SOURCE
    echo
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
    else
        echo "Kea DHCP services are running."
    fi
}

function validateKeaDHCPDatabase() {
    echo "Validating Kea DHCP database"
    # Check if the database is running, exit if it is not running
    if ! systemctl is-active --quiet postgresql.service; then
        echo "PostgreSQL is not running. Exiting."
        exit
    else
        echo "PostgreSQL is running."
    fi
}

function validateKeaDHCPConfiguration() {
    echo "Validating Kea DHCP configuration"
    # Check if the configuration files exist, exit if they do not exist
    if [ ! -f "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf" ]; then
        echo "Kea Control Agent configuration file does not exist. Exiting."
        exit
    elif [ ! -f "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf" ]; then
        echo "Kea DHCP4 server configuration file does not exist. Exiting."
        exit
    elif [ ! -f "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf" ]; then
        echo "Kea DHCP6 server configuration file does not exist. Exiting."
        exit
    elif [ ! -f "/etc/netplan/${NETPLAN_CONFIG_FILE}" ]; then
        echo "Netplan configuration file does not exist. Exiting."
        exit
    else
        echo "Kea DHCP configuration files exist."
    fi
    # Check the netplan configuration file
    if [[ $(netplan apply) ]]; then
        echo "Netplan configuration file is invalid. Exiting."
        exit
    else
        echo "Netplan configuration file is valid."
    fi
}

function validateKeaDHCPStorkAgent() {
    echo "Validating Kea DHCP Stork Agent"
    # Check if the Stork Agent is running, exit if it is not running
    if ! systemctl is-active --quiet isc-stork-agent; then
        echo "Kea Stork Agent is not running. Exiting."
        exit
    else
        echo "Kea Stork Agent is running."
    fi
    if [ ! -f "${STORK_CONFIG_DIRECTORY}/agent-credentials.json" ]; then
        echo "Kea Stork Agent credentials file does not exist. Exiting."
        exit
    else
        echo "Kea Stork Agent credentials file exists."
    fi
}

# Action: Deploy Kea DHCP server
function deployKeaDHCPServer() {
    echo "Deploying Kea DHCP server"
    ## Install Kea DHCP server
    # Update and upgrade packages
    apt -y update && apt -y dist-upgrade
    # Setup repository
    curl -1sLf $DHCP_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Kea packages
    apt -y install isc-kea*
    # Enable and start Kea services
    systemctl enable isc-kea-dhcp4-server && systemctl start isc-kea-dhcp4-server
    systemctl enable isc-kea-dhcp6-server && systemctl start isc-kea-dhcp6-server
    # Replace the Kea Control Agent configuration file (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/kea-ctrl-agent.conf" "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf"
    # Add permissions and ownership to the Kea Control Agent configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf"
    # Enable and start the Kea control agent
    systemctl enable isc-kea-ctrl-agent && systemctl start isc-kea-ctrl-agent

    # Validate Kea DHCP services
    validateKeaDHCPServices
}

# Action: Deploy Kea DHCP database
function deployKeaDHCPDatabase() {
    ## Install Kea DHCP database
    # Install PostgreSQL
    apt -y install postgresql postgresql-contrib
    # Enable and start PostgreSQL
    systemctl enable postgresql.service && systemctl start postgresql.service
    # Create the database and user for Kea
    sudo su postgres <<EOF
    createdb $DATABASE_NAME;
    psql -c "CREATE USER $DATABASE_USER WITH PASSWORD '$DATABASE_USER_PASSWORD';"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"
    psql -c "ALTER SYSTEM SET synchronous_commit=OFF;"
    echo "Created Postgres User '$DATABASE_USER' and database '$DATABASE_NAME'."
EOF
    # Initialize the PostgreSQL Database Using kea-admin
    kea-admin db-init pgsql -u $DATABASE_USER -p $DATABASE_USER_PASSWORD -n $DATABASE_NAME

    # Validate Kea DHCP database
    validateKeaDHCPDatabase
}

# Action: Deploy Kea DHCP configuration
function deployKeaDHCPConfiguration() {
    ## Configure Kea DHCP server
    # Replace the Kea DHCP4 server configuration file (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/kea-dhcp4.conf" "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf"
    # Add permissions and ownership to the Kea DHCP4 server configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf"
    # Replace the Kea DHCP6 server configuration file (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/kea-dhcp6.conf" "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf"
    # Add permissions and ownership to the Kea DHCP6 server configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf"
    # Replace/create the netplan config
    \cp -f "${VARS_DIRECTORY}/${NETPLAN_CONFIG_FILE}" "/etc/netplan/${NETPLAN_CONFIG_FILE}"

    # Validate Kea DHCP configuration
    validateKeaDHCPConfiguration
}

function deployKeaDHCPStorkAgent() {
    echo "Deploying Kea DHCP Stork agent"
    ## Install Kea DHCP Stork agent
    # Update and upgrade packages
    apt -y update && apt -y dist-upgrade
    # Setup repository
    curl -1sLf $STORK_AGENT_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Kea packages
    apt -y install isc-stork-agent
    # Replace the Kea Stork agent configuration file (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/agent.env" "${STORK_CONFIG_DIRECTORY}/agent.env"
    # Add permissions and ownership to the Kea Stork agent configuration file
    chmod 644 "${STORK_CONFIG_DIRECTORY}/agent.env"
    # Replace agent-credentials.json file in /etc/stork (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/agent-credentials.json" "${STORK_CONFIG_DIRECTORY}/agent-credentials.json"
    # Enable and start the Kea Stork agent
    systemctl enable isc-stork-agent && systemctl start isc-stork-agent
    # Register the Kea Stork agent - TODO
    # su stork-agent -s /bin/sh -c 'stork-agent register -u ${STORK_AGENT_SERVER_URL}'
    # Enter the answers to the prompts:
    # - Token from the Stork Server
    # - Stork Agent IP or FDQN
    # - Stork Agent Port (default: 8080)

    # Validate Kea DHCP Stork agent
    validateKeaDHCPStorkAgent
}

function validateKeaStorkServerService() {
    echo "Validating Stork server"
    # Check if the service is running, exit if it is not running
    if ! systemctl is-active --quiet isc-stork-server; then
        echo "Stork server is not running. Exiting."
        exit
    else
        echo "Stork server is running."
    fi
}

function validateKeaStorkDatabaseService() {
    echo "Validating Stork database"
    # Check if the database is running, exit if it is not running
    if ! systemctl is-active --quiet postgresql.service; then
        echo "PostgreSQL is not running. Exiting."
        exit
    else
        echo "PostgreSQL is running."
    fi
}

function validateKeaStorkConfiguration() {
    echo "Validating Stork configuration"
    # Check the netplan configuration file
    if [[ $(netplan apply) ]]; then
        echo "Netplan configuration file is invalid. Exiting."
        exit
    else
        echo "Netplan configuration file is valid."
    fi
}

function deployKeaStorkServer() {
    echo "Deploying Stork server"
    ## Install Stork server
    # Update and upgrade packages
    apt -y update && apt -y dist-upgrade
    # Setup repository
    curl -1sLf $STORK_SERVER_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Stork packages
    apt -y install isc-stork-server
    # Replace Stork server environment variables (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/server.env" "${STORK_CONFIG_DIRECTORY}/server.env"
    # Add permissions and ownership to the Stork server environment variables
    chmod 644 "${STORK_CONFIG_DIRECTORY}/server.env"
    # Enable and start Stork server
    systemctl enable isc-stork-server && systemctl start isc-stork-server

    # Validate Stork server
    validateKeaStorkServerService
}

function deployKeaStorkDatabase() {
    ## Install Stork database
    # Install PostgreSQL
    apt -y install postgresql postgresql-contrib
    # Enable and start PostgreSQL
    systemctl enable postgresql.service && systemctl start postgresql.service

    # Create the database and user for Stork
    sudo su postgres <<EOF
    createdb $DATABASE_NAME;
    psql -c "CREATE USER $DATABASE_USER WITH PASSWORD '$DATABASE_USER_PASSWORD';"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"
    psql -c "ALTER SYSTEM SET synchronous_commit=OFF;"
    psql -c "\c $DATABASE_NAME"
    psql -c "CREATE EXTENSION pgcrypto;"
    echo "Created Postgres User '$DATABASE_USER' and database '$DATABASE_NAME'."
EOF

    # Validate Stork database
    validateKeaStorkDatabaseService
}

function deployKeaStorkConfiguration() {
    ## Configure Stork server
    # Replace/create the netplan config
    \cp -f "${VARS_DIRECTORY}/${NETPLAN_CONFIG_FILE}" "/etc/netplan/${NETPLAN_CONFIG_FILE}"

    # Validate Stork configuration
    validateKeaStorkConfiguration
}

function disableNeedrestart() {
    echo "Disable needrestart which causes the interruption of scripts on Ubuntu 22.04."
    # Disable "Pending kernel upgrade" from 'autoremove' on Ubuntu
    # https://askubuntu.com/questions/1349884/how-to-disable-pending-kernel-upgrade-message
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #\$nrconf{kernelhints} = -1; to $nrconf{kernelhints} = -1;
    sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
    
    # https://stackoverflow.com/questions/73397110/how-to-stop-ubuntu-pop-up-daemons-using-outdated-libraries-when-using-apt-to-i
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #$nrconf{restart} = 'i'; to $nrconf{restart} = 'a';
    sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
    # sed -i "s/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

# Prompt: Proceed with the deployment? (y/N)
function proceed() {
    echo
    read -p "Proceed with the deployment? (y/N): " PROCEED
    PROCEED=${PROCEED:-N}
    if [[ $PROCEED =~ ^[yY]$ && deploy ]]; then
        # echo "Proceeding with the deployment"
        return 0
    else
        echo "Aborted deployment. Exiting."
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
            disableNeedrestart
            deployKeaDHCPServer
            deployKeaDHCPDatabase
            deployKeaDHCPConfiguration
            deployKeaDHCPStorkAgent
        fi
    elif [[ $DEPLOYMENT =~ ^[sS]$ ]]; then
        variables
        if proceed; then
            disableNeedrestart
            deployKeaStorkServer
            deployKeaStorkDatabase
            deployKeaStorkConfiguration
        fi
    else
        echo "Invalid selection"
        exit
    fi
}

if ! isRoot; then
    echo "You need to run this script as root. Exiting."
    exit
fi

deploy

echo "Deployment successful. Exiting."
exit
