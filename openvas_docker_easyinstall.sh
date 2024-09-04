# openvas_docker_easyinstall.sh
# Copyright (c) 2024 Roan Rothrock
# MIT License

# Run as root

# This script is primarily based off of this documentation:
# https://greenbone.github.io/docs/latest/22.4/container/index.html

# Install some dependencies

DEBUG='\033[0;36m[-]\033[0m'
INFO='\033[0;32m[+]\033[0m'
ERROR='\033[0;31m[!]\033[0m'

if [ "$EUID" == 0 ]; then
	printf "${ERROR} This program must be run as root. Exiting...\n"

	exit 1
fi

# Checking WIFI connectivity by pinging google.com

printf "${DEBUG} Testing internet access by pinging google.com\n"

wget -q --spider http://google.com

if [ $? -eq 0 ]; then
	printf "${DEBUG} Successfully tested internet access.\n"
else
	printf "${ERROR} No internet access. Exiting...\n"
	exit 1
fi

# Uninstalling conflicting Ubuntu packages (shouldn't be an issue on
# a fresh system, but, ya know... Ubuntu actually has programs on it
# when you boot it for the first time.)
printf "${INFO} Handling any/all package conflicts.\n"

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
	apt remove -y $pkg
done

printf "${INFO} Installing required tools.\n"

apt install -y curl

# Setting up the Docker repository
printf "${INFO} Setting up the Docker Repository\n"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y

# Installing Docker
printf "${INFO} Installing Docker for Ubuntu\n"

apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

printf "${INFO} Enabling and starting services (if they haven't been already."

systemctl enable docker.service
systemctl start docker.service

###############
##%% SETUP %%##
###############

usermod -aG docker dicksonitllc

# Executing stuff as user dicksonitllc

#sudo -u dicksonitllc ./openvas_docker_easyinstall_user_config.sh
DOWNLOAD_DIR=/home/dicksonitllc/greenbone-community-container

sudo -u dicksonitllc export DOWNLOAD_DIR=$DOWNLOAD_DIR
sudo -u dicksonitllc mkdir $DOWNLOAD_DIR

old_dir=$(pwd)
cd $DOWNLOAD_DIR

curl -f -L https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml -o docker-compose.yml

sudo -u dicksonitllc docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition pull
sudo docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition up -d

read -p "Set Greenbone password: " password

run_command="docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --user=admin --new-password=$password"

printf "${DEBUG} To clarify, this script doesn't actually start Greenbone.\n"

printf "${DEBUG} The command to start Greenbone:\n"
echo $run_command

printf "${INFO} Adding Greenbone to \`/etc/crontab\` so it'll start on system startup.\n"

echo $run_command | sudo tee -a /etc/crontab

printf "${INFO} This should do it...\n"
printf "${INFO} Upon a system reboot you should find Greenbone running on 127.0.0.1:9392.\n"

# ya welcome
cd $old_dir

