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

if [[ "$EUID" -ne 0 ]]; then
	printf "${ERROR} This program must be run as root. Exiting...\n"

	exit 1
fi

# Checking WIFI connectivity by pinging google.com

printf "${DEBUG} Testing internet access by pinging google.com\n"

wget -q --spider http://google.com

if [$? -eq 0 ]; then
	printf "${DEBUG} Successfully tested internet access.\n"
else
	printf "${ERROR} No internet access. Exiting...\n"
	exit 1
fi

# Uninstalling conflicting Ubuntu packages (shouldn't be an issue on
# a fresh system, but, ya know... Ubuntu actually has programs on it
# when you boot it for the first time.)
printf "${INFO} Handling any/all package conflicts."

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
	apt remove -y $pkg
done

# Setting up the Docker repository
printf "${INFO} Setting up the Docker Repository"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Installing Docker
printf "${INFO} Installing Docker for Ubuntu"

apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

###############
##%% SETUP %%##
###############

usermod -aG docker dicksonitllc

# Executing secondary script as user dicksonitllc

sudo -u dicksonitllc ./openvas_docker_easyinstall_user_config.sh
$run_command = $?

printf "${DEBUG} To clarify, this script doesn't actually start Greenbone."

printf "${DEBUG} The command to start Greenbone:"
printf "$run_command"

printf "${INFO} Adding Greenbone to `/etc/crontab` so it'll start on system startup."

printf "$run_command" >> /etc/crontab

printf "${INFO} This should do it..."
printf "${INFO} Upon a system reboot you should find Greenbone running on 127.0.0.1:9392."

# ya welcome

