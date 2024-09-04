# openvas_docker_easyinstall_user_config.sh
# Copyright (c) 2024 Roan Rothrock
# Do not run this file - run the other one instead.

export DOWNLOAD_DIR=$HOME/greenbone-community-container && mkdir -p $DOWNLOAD_DIR

cd $DOWNLOAD_DIR && curl -f -L https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml -o docker-compose.yml

docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition pull

docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition up -d

read -p "Greenbone password: " password

#docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition \
#    exec -u gvmd gvmd gvmd --user=admin --new-password=$password

# Is this jank? Pfft, yeah. And?

exit "docker compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition exec -u gvmd gvmd gvmd --user=admin --new-password=$password"

