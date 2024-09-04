# openvas_docker_easyinstall_user_config.sh
# Copyright (c) 2024 Roan Rothrock
# Do not run this file - run the other one instead.

export DOWNLOAD_DIR=$HOME/greenbone-community-container && mkdir -p $DOWNLOAD_DIR

cd $DOWNLOAD_DIR && curl -f -L https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml -o docker-compose.yml

docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition pull

docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition up -d

# I'm fully aware this is dumb... I don't care.
#user=admin
#$password='password'

# settings password manually
while true; do

	read -p " Greenbone password: " password
	read -p "Confirm Password: " confirmpassword

	if [ $password == $confirmpassword ]; then
		break
	else
		echo "Passwords don't match!"
	fi

done

#docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition \
#    exec -u gvmd gvmd gvmd --user=admin --new-password=$password

# Is this jank? Pfft, yeah. And?

return "docker computer -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --user=admin --new-password=$password"

