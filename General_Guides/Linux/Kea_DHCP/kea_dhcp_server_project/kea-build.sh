#!/bin/bash

# Purpose: Deploy Kea DHCP or Stork on localhost

# Usage (run as sudo):
# sudo su -
# git clone https://github.com/boxops/network_developer_toolkit.git /tmp/network_developer_toolkit
# cd /tmp/network_developer_toolkit/General_Guides/Linux/Kea_DHCP/kea_dhcp_server_project
# chmod +x kea-build.sh
# ./kea-build.sh

# Set variables for the build
VARS_DIRECTORY=""
VARS_BUILD_FILE="*.env"

# Check if user is root
function isRoot() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
}

function variables() {
    read -p "Enter the path to the folder containing the variables for the build (dhcp-primary): " VARS_DIRECTORY
    VARS_DIRECTORY=${VARS_DIRECTORY:-dhcp-primary}
    echo "Imported the following variables for the build from (${VARS_DIRECTORY}/${VARS_BUILD_FILE}):"
    echo
    # for the number of *.env files in the VARS_DIRECTORY
    for env in $(ls ${VARS_DIRECTORY}/*.env); do
        export $(cat $env | xargs)
        cat $env
    done
    echo
}

function startService() {
    echo "Starting ${1} service"
    systemctl start $1
     if ! systemctl is-active --quiet $1; then
        echo "${1} is not running. Exiting."
        exit
    else
        echo "${1} is running."
    fi
}

function enableService() {
    echo "Enabling ${1} service"
    systemctl enable $1
    if ! systemctl is-enabled --quiet $1; then
        echo "${1} is not enabled. Exiting."
        exit
    else
        echo "${1} is enabled."
    fi
}

function restartService() {
    echo "Restarting ${1} service"
    systemctl restart $1
    if ! systemctl is-active --quiet $1; then
        echo "${1} is not running. Exiting."
        exit
    else
        echo "${1} is running."
    fi
}

function stopService() {
    echo "Stopping ${1} service"
    systemctl stop $1
    if systemctl is-active --quiet $1; then
        echo "${1} is running. Exiting."
        exit
    else
        echo "${1} is not running."
    fi
}

function disableService() {
    echo "Disabling ${1} service"
    systemctl disable $1
     if systemctl is-enabled --quiet $1; then
        echo "${1} is enabled. Exiting."
        exit
    else
        echo "${1} is not enabled."
    fi
}

function updatePackages() {
    echo "Updating packages"
    apt -y update
}

function upgradePackages() {
    echo "Upgrading packages"
    apt -y dist-upgrade
}

function validateKeaDHCPServices() {
    echo "Validating Kea DHCP services"
    if ! systemctl is-active --quiet isc-kea-dhcp4-server; then
        echo "Kea DHCP4 server is not running."
        restartService isc-kea-dhcp4-server
    elif ! systemctl is-active --quiet isc-kea-dhcp6-server; then
        echo "Kea DHCP6 server is not running."
        restartService isc-kea-dhcp6-server
    elif ! systemctl is-active --quiet isc-kea-ctrl-agent; then
        echo "Kea Control Agent is not running."
        restartService isc-kea-ctrl-agent
    else
        echo "Kea DHCP services are running."
    fi
}

function validateKeaDHCPDatabase() {
    echo "Validating Kea DHCP database"
    if ! systemctl is-active --quiet postgresql.service; then
        echo "PostgreSQL is not running."
        restartService postgresql.service
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
    else
        echo "Kea Control Agent configuration file exists in ${DHCP_CONFIG_DIRECTORY}."
    fi

    if ! kea-ctrl-agent -t "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf"; then
        echo "Kea Control Agent configuration file is invalid. Exiting."
        exit
    else
        echo "Kea Control Agent configuration file is valid."
    fi

    if [ ! -f "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf" ]; then
        echo "Kea DHCP4 server configuration file does not exist. Exiting."
        exit
    else
        echo "Kea DHCP4 server configuration file exists in ${DHCP_CONFIG_DIRECTORY}."
    fi

    if ! kea-dhcp4 -t "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf"; then
        echo "Kea DHCP4 server configuration file is invalid. Exiting."
        exit
    else
        echo "Kea DHCP4 server configuration file is valid."
    fi

    if [ ! -f "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf" ]; then
        echo "Kea DHCP6 server configuration file does not exist. Exiting."
        exit
    else
        echo "Kea DHCP6 server configuration file exists in ${DHCP_CONFIG_DIRECTORY}."
    fi

    if ! kea-dhcp6 -t "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf"; then
        echo "Kea DHCP6 server configuration file is invalid. Exiting."
        exit
    else
        echo "Kea DHCP6 server configuration file is valid."
    fi
}

function validateNetplanConfiguration() {
    if [ ! -f "/etc/netplan/${NETPLAN_CONFIG_FILE}" ]; then
        echo "Netplan configuration file does not exist. Exiting."
        exit
    else
        echo "Netplan configuration files exists in /etc/netplan."
    fi

    if ! netplan apply; then
        echo "Netplan configuration file is invalid. Exiting."
        exit
    else
        echo "Netplan configuration file is valid."
    fi
}

function validateKeaDHCPStorkAgent() {
    echo "Validating Kea DHCP Stork Agent"
    if ! systemctl is-active --quiet isc-stork-agent; then
        echo "Kea Stork Agent is not running."
        restartService isc-stork-agent
    else
        echo "Kea Stork Agent is running."
    fi
    # if [ ! -f "${STORK_CONFIG_DIRECTORY}/agent-credentials.json" ]; then
    #     echo "Kea Stork Agent credentials file does not exist. Exiting."
    #     exit
    # else
    #     echo "Kea Stork Agent credentials file exists in ${STORK_CONFIG_DIRECTORY}."
    # fi
}

function deployKeaDHCPServer() {
    echo "Deploying Kea DHCP server"
    ## Install Kea DHCP server
    # Setup repository
    curl -1sLf $DHCP_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Kea packages
    apt -y install isc-kea*
    # Enable and start Kea services
    enableService isc-kea-dhcp4-server
    startService isc-kea-dhcp4-server
    enableService isc-kea-dhcp6-server
    startService isc-kea-dhcp6-server
    # Replace the Kea Control Agent configuration file
    envsubst < "${VARS_DIRECTORY}/kea-ctrl-agent.conf.template" > "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf"
    # Add permissions and ownership to the Kea Control Agent configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-ctrl-agent.conf"
    # Enable and start the Kea control agent
    enableService isc-kea-ctrl-agent
    startService isc-kea-ctrl-agent

    validateKeaDHCPServices
}

function deployKeaDHCPDatabase() {
    ## Install Kea DHCP database
    # Install PostgreSQL
    apt -y install postgresql postgresql-contrib
    # Enable and start PostgreSQL
    enableService postgresql.service
    startService postgresql.service
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

    validateKeaDHCPDatabase
}

function deployKeaDHCPConfiguration() {
    ## Configure Kea DHCP server
    # Replace the Kea DHCP4 server configuration file
    envsubst < "${VARS_DIRECTORY}/kea-dhcp4.conf.template" > "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf"
    # Add permissions and ownership to the Kea DHCP4 server configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-dhcp4.conf"
    # Replace the Kea DHCP6 server configuration file
    envsubst < "${VARS_DIRECTORY}/kea-dhcp6.conf.template" > "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf"
    # Add permissions and ownership to the Kea DHCP6 server configuration file
    chmod 644 "${DHCP_CONFIG_DIRECTORY}/kea-dhcp6.conf"

    validateKeaDHCPConfiguration
}

function deployNetplanConfiguration() {
    ## Configure Netplan
    # Replace/create the netplan config
    envsubst < "${VARS_DIRECTORY}/${NETPLAN_CONFIG_FILE}.template" > "/etc/netplan/${NETPLAN_CONFIG_FILE}"
    # Apply the netplan configuration
    netplan apply

    validateNetplanConfiguration
}

function deployKeaDHCPStorkAgent() {
    echo "Deploying Kea DHCP Stork agent"
    ## Install Kea DHCP Stork agent
    # Setup repository
    curl -1sLf $STORK_AGENT_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Kea packages
    apt -y install isc-stork-agent
    # Replace the Kea Stork agent configuration file (overwrite without confirmation)
    \cp -f "${VARS_DIRECTORY}/agent.env" "${STORK_CONFIG_DIRECTORY}/agent.env"
    # Add permissions and ownership to the Kea Stork agent configuration file
    chmod 644 "${STORK_CONFIG_DIRECTORY}/agent.env"
    # Replace agent-credentials.json file in /etc/stork
    envsubst < "${VARS_DIRECTORY}/agent-credentials.json.template" > "${STORK_CONFIG_DIRECTORY}/agent-credentials.json"
    # Enable and start the Kea Stork agent
    enableService isc-stork-agent
    startService isc-stork-agent

    # Manually register the Kea Stork agent if isc-stork-agent.service does not register
    # su stork-agent -s /bin/sh -c 'stork-agent register -u ${STORK_AGENT_SERVER_URL}'
    # Enter the answers to the prompts:
    # - Token from the Stork Server
    # - Stork Agent IP or FDQN
    # - Stork Agent Port (default: 8080)

    validateKeaDHCPStorkAgent
}

function validateKeaStorkServerService() {
    echo "Validating Stork server"
    if ! systemctl is-active --quiet isc-stork-server; then
        echo "Stork server is not running."
        restartService isc-stork-server
    else
        echo "Stork server is running."
    fi
}

function validateKeaStorkDatabaseService() {
    echo "Validating Stork database service"
    if ! systemctl is-active --quiet postgresql.service; then
        echo "PostgreSQL is not running."
        restartService postgresql.service
    else
        echo "PostgreSQL is running."
    fi
}

function validateKeaStorkConfiguration() {
    echo "Validating Stork configuration"
    echo "TODO: Implement validation of Stork configuration"
    # if ! netplan apply; then
    #     echo "Netplan configuration file is invalid. Exiting."
    #     exit
    # else
    #     echo "Netplan configuration file is valid."
    # fi
}

function deployKeaStorkServer() {
    echo "Deploying Stork server"
    ## Install Stork server
    # Setup repository
    curl -1sLf $STORK_SERVER_CLOUDSMITH_PACKAGE | sudo -E bash
    # Install Stork packages
    apt -y install isc-stork-server
    # Replace Stork server environment variables
    \cp -f "${VARS_DIRECTORY}/server.env" "${STORK_CONFIG_DIRECTORY}/server.env"
    # Add permissions and ownership to the Stork server environment variables
    chmod 644 "${STORK_CONFIG_DIRECTORY}/server.env"
    # Enable and start Stork server
    enableService isc-stork-server
    startService isc-stork-server

    validateKeaStorkServerService
}

function deployKeaStorkDatabase() {
    ## Install Stork database
    # Install PostgreSQL
    apt -y install postgresql postgresql-contrib
    # Enable and start PostgreSQL
    enableService postgresql.service
    startService postgresql.service

    # Create the database and user for Stork
    sudo su postgres <<EOF
    createdb $STORK_DATABASE_NAME;
    psql -c "CREATE USER $STORK_DATABASE_USER_NAME WITH PASSWORD '$STORK_DATABASE_PASSWORD';"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE $STORK_DATABASE_NAME TO $STORK_DATABASE_USER_NAME;"
    psql -c "ALTER SYSTEM SET synchronous_commit=OFF;"
    psql -c "\c $STORK_DATABASE_NAME"
    psql -c "CREATE EXTENSION pgcrypto;"
    echo "Created Postgres User '$STORK_DATABASE_USER_NAME' and database '$STORK_DATABASE_NAME'."
EOF

    validateKeaStorkDatabaseService
}

function deployKeaStorkConfiguration() {
    ## Configure Stork server
    echo "TODO: Implement configuration of Stork server"
    # Replace/create the netplan config
    #envsubst < "${VARS_DIRECTORY}/${NETPLAN_CONFIG_FILE}.template" > "/etc/netplan/${NETPLAN_CONFIG_FILE}"

    validateKeaStorkConfiguration
}

function disableNeedrestart() {
    echo "Disable needrestart which causes the interruption of scripts in Ubuntu."
    # Disable "Pending kernel upgrade" messages
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #\$nrconf{kernelhints} = -1; to $nrconf{kernelhints} = -1;
    sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

    # Set needrestart services to: a (automatically restart)
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #$nrconf{restart} = 'i'; to $nrconf{restart} = 'a';
    sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
}

function proceed() {
    echo
    read -p "Proceed? (y/N): " PROCEED
    PROCEED=${PROCEED:-N}
    if [[ $PROCEED =~ ^[yY]$ && deploy ]]; then
        return 0
    else
        echo "Aborted deployment. Exiting."
        exit
    fi
}

function run() {
    disableNeedrestart
    read -p "Manage Kea [DHCP|Stork] server? (D/s): " OPTION
    OPTION=${OPTION:-D}
    if [[ $OPTION =~ ^[dD]$ ]]; then
        read -p "[Deploy|Configure|Troubleshoot] Kea DHCP server? (D/c/t): " MANAGE
        MANAGE=${MANAGE:-D}
        if [[ $MANAGE =~ ^[dD]$ ]]; then
            variables
            if proceed; then
                updatePackages
                # upgradePackages
                deployKeaDHCPServer
                deployKeaDHCPDatabase
                deployKeaDHCPStorkAgent
                deployKeaDHCPConfiguration
                # deployNetplanConfiguration
                echo "Deployment successful. Please consider rebooting your system."
            fi
        elif [[ $MANAGE =~ ^[cC]$ ]]; then
            variables
            if proceed; then
                deployKeaDHCPConfiguration
                # deployNetplanConfiguration
            fi
        elif [[ $MANAGE =~ ^[tT]$ ]]; then
            echo "Troubleshooting Kea DHCP server"
            variables
            if proceed; then
                validateKeaDHCPServices
                validateKeaDHCPDatabase
                validateKeaDHCPStorkAgent
                validateKeaDHCPConfiguration
                # validateNetplanConfiguration
                echo "All services are running."
            fi
        else
            echo "Invalid option. Exiting."
            exit
        fi

    elif [[ $OPTION =~ ^[sS]$ ]]; then
        read -p "[Deploy|Configure|Troubleshoot] Kea Stork server? (D/c/t): " MANAGE
        MANAGE=${MANAGE:-D}
        if [[ $MANAGE =~ ^[dD]$ ]]; then
            variables
            if proceed; then
                updatePackages
                # upgradePackages
                deployKeaStorkServer
                deployKeaStorkDatabase
                deployKeaStorkConfiguration
                # deployNetplanConfiguration
                echo "Deployment successful. Please consider rebooting your system."
            fi
        elif [[ $MANAGE =~ ^[cC]$ ]]; then
            variables
            if proceed; then
                deployKeaStorkConfiguration
                # deployNetplanConfiguration
                echo "Configuration successful."
            fi
        elif [[ $MANAGE =~ ^[tT]$ ]]; then
            echo "Troubleshooting Kea Stork server"
            variables
            if proceed; then
                validateKeaStorkServerService
                validateKeaStorkDatabaseService
                validateKeaStorkConfiguration
                # validateNetplanConfiguration
                echo "All services are running."
            fi
        else
            echo "Invalid selection"
            exit
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

run

echo "Script done. Exiting."
exit
