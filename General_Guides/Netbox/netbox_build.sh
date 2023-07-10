### Based on the Official Netbox Installation: https://docs.netbox.dev/en/stable/installation/

# Variables
GENERATE_SECRET_KEY=true
ALLOWED_HOSTS="['*']"
DATABASE_NAME='netbox'
DATABASE_USER='netbox'
DATABASE_USER_PASSWORD='123qwe'
SUPERUSER='root'
SUPERUSER_PASSWORD='123qwe'
SUPERUSER_EMAIL='admin@admin.com'

# Check if user is root
function isRoot() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
}

if ! isRoot; then
    echo "You need to run this script as root. Exiting."
    exit
fi

function disableNeedrestart() {
    echo "Disable needrestart which causes the interruption of scripts in Ubuntu."
    # Disable "Pending kernel upgrade" messages
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #\$nrconf{kernelhints} = -1; to $nrconf{kernelhints} = -1;
    sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

    # Set needrestart services to: a (automatically restart)
    # edit the /etc/needrestart/needrestart.conf file, changing the line: #$nrconf{restart} = 'i'; to $nrconf{restart} = 'a';
    sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf
}

function enableService() {
    echo "Enabling ${1} service"
    systemctl enable $1
    if ! systemctl is-enabled --quiet $1; then
        echo "${1} is not enabled."
    else
        echo "${1} is enabled."
    fi
}

function startService() {
    echo "Starting ${1} service"
    systemctl start $1
     if ! systemctl is-active --quiet $1; then
        echo "${1} is not running."
    else
        echo "${1} is running."
    fi
}

function restartService() {
    echo "Restarting ${1} service"
    systemctl restart $1
}

function updateUpgradeSystem() {
    sudo apt update -y
    sudo apt dist-upgrade -y
}

function installPackages() {
    packages=("$@")  # Store all arguments in the 'packages' array
    for package in "${packages[@]}"; do
        sudo apt install -y "$package"
    done
}

function createDatabase() {
    sudo su postgres <<EOF
psql -c "CREATE DATABASE $DATABASE_NAME;"
psql -c "CREATE USER $DATABASE_USER WITH PASSWORD '$DATABASE_USER_PASSWORD';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"
EOF
    echo "Created Postgres User '$DATABASE_USER' and database '$DATABASE_NAME'."
}

function downloadNetbox() {
    # Download NetBox by Cloning the Git Repository
    sudo mkdir -p /opt/netbox/
    sudo git clone -b master --depth 1 https://github.com/netbox-community/netbox.git /opt/netbox/
    # If the current stable release is broken, then remote the current release and clone the previous release
    # rm -rf /opt/netbox
    # sudo git clone -b master https://github.com/netbox-community/netbox.git /opt/netbox/
    # git checkout v3.5.4 /opt/netbox/
}

function configureNetbox() {
    # Create the NetBox System User
    sudo adduser --system --group netbox
    sudo chown --recursive netbox /opt/netbox/netbox/media/
    sudo chown --recursive netbox /opt/netbox/netbox/reports/
    sudo chown --recursive netbox /opt/netbox/netbox/scripts/

    # Make a copy of configuration_example.py named configuration.py
    sudo cp /opt/netbox/netbox/netbox/configuration_example.py /opt/netbox/netbox/netbox/configuration.py

    # Set ALLOWED_HOSTS in /opt/netbox/netbox/netbox/configuration.py
    sed -i "/^ALLOWED_HOSTS =/c\ALLOWED_HOSTS = $ALLOWED_HOSTS" /opt/netbox/netbox/netbox/configuration.py

    # TODO: Fix insertion of variables
    sed -i "/    'USER': '',               # PostgreSQL username/c\    'USER': '$DATABASE_USER'," /opt/netbox/netbox/netbox/configuration.py
    sed -i "/    'PASSWORD': '',           # PostgreSQL password/c\    'PASSWORD': '$DATABASE_USER_PASSWORD'," /opt/netbox/netbox/netbox/configuration.py

    # Generate SECRET_KEY
    if $GENERATE_SECRET_KEY; then
        # echo "Generating Secret Key"
        SECRET_KEY=$(python3 /opt/netbox/netbox/generate_secret_key.py)
        sed -i "/^SECRET_KEY = ''/c\SECRET_KEY = '$SECRET_KEY'" /opt/netbox/netbox/netbox/configuration.py
    else
        echo "Don't forget to generate a Secret Key!"
    fi

    # Run the Upgrade Script
    sudo /opt/netbox/upgrade.sh
}

function createSuperUser() {
    source /opt/netbox/venv/bin/activate

    DJANGO_SUPERUSER_USERNAME=$SUPERUSER DJANGO_SUPERUSER_PASSWORD=$SUPERUSER_PASSWORD \
    python3 /opt/netbox/netbox/manage.py createsuperuser --email=$SUPERUSER_EMAIL --noinput
}

function httpServerSetup() {
    # Obtain an SSL Certificate
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/netbox.key \
    -out /etc/ssl/certs/netbox.crt <<EOF
''
''
''
''
''
''
''
EOF

    # Country Name (2 letter code) [AU]:
    # State or Province Name (full name) [Some-State]:
    # Locality Name (eg, city) []:
    # Organization Name (eg, company) [Internet Widgits Pty Ltd]:
    # Organizational Unit Name (eg, section) []:
    # Common Name (e.g. server FQDN or YOUR name) []:
    # Email Address []:

    # HTTP Server Installation - Option A: nginx
    installPackages nginx

    sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox

    restartService nginx
}

function run() {

    ### Start
    disableNeedrestart
    updateUpgradeSystem

    installPackages postgresql
    enableService postgresql.service
    startService postgresql.service

    createDatabase

    # Redis Installation
    installPackages redis-server
    startService redis-server
    startService redis
    enableService redis-server
    enableService redis
    redis-cli ping

    # Install System Packages
    installPackages git python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev

    downloadNetbox

    configureNetbox

    createSuperUser

    # Schedule the Housekeeping Task
    sudo ln -s /opt/netbox/contrib/netbox-housekeeping.sh /etc/cron.daily/netbox-housekeeping

    # Setup Gunicorn
    sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py

    # systemd Setup
    sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
    sudo systemctl daemon-reload

    startService netbox
    startService netbox-rq
    enableService netbox
    enableService netbox-rq

    # Nginx Setup
    httpServerSetup

}

run
