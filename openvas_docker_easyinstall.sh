# openvas_docker_easyinstall.sh
# Copyright (c) 2024 Roan Rothrock
# MIT License

# Run as root

# This script is primarily based off of this documentation:
# https://greenbone.github.io/docs/latest/22.4/container/index.html

# Install some dependencies

$DEBUG='\033[36m[-]\033[39m'
$INFO='\033[32m[+]\033[39m'
$ERROR='\033[31m[!]\033[39m'

if [ "$EUID" -ne 0 ]; then
	echo "$ERROR This program must be run as root."
	echo "$INFO Try running `sudo $0`"

	return 1
fi

# Checking WIFI connectivity by pinging google.com

echo "$DEBUG Testing internet access by pinging google.com"

wget -q --spider http://google.com

if [$? -eq 0 ]; then
	echo "$DEBUG Successfully tested internet access."
else
	echo "$ERROR No internet access."
	return 1
fi

# Uninstalling conflicting Ubuntu packages (shouldn't be an issue on
# a fresh system, but, ya know... Ubuntu actually has programs on it
# when you boot it for the first time.)
echo "$INFO Handling any/all package conflicts."

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
	apt remove -y $pkg
done

# Setting up the Docker repository
echo "$INFO Setting up the Docker Repository"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Installing Docker
echo "$INFO Installing Docker for Ubuntu"

apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

###############
##%% SETUP %%##
###############

usermod -aG docker dicksonitllc

# Executing secondary script as user dicksonitllc

sudo -u dicksonitllc ./openvas_docker_easyinstall_user_config.sh
$run_command = $?

echo "$DEBUG To clarify, this script doesn't actually start Greenbone."

echo "$DEBUG The command to start Greenbone:"
echo "$run_command"

echo "$INFO Adding Greenbone to `/etc/crontab` so it'll start on system startup."

echo "$run_command" >> /etc/crontab

echo "$INFO This should do it..."
echo "$INFO Upon a system reboot you should find Greenbone running on 127.0.0.1:9392."

# ya welcome

