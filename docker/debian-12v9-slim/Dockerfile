FROM debian:12.10-slim AS base

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y\
    systemd dialog curl apache2 lynx\
    php-common libapache2-mod-php php-cli php-pgsql php-curl php-mbstring\
    git 

RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

USER node
RUN whoami
WORKDIR "/home/node"

# Install NVM and NodeJS
ENV NVM_DIR=/home/node/.nvm
ENV NODE_VERSION=v20.17.0

RUN mkdir -p $NVM_DIR && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"

ENV NODE_PATH=$NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN npm update -g npm
RUN node -v
RUN npm -v

RUN npm install @angular/cli@18

USER root

SHELL ["/bin/bash", "-c"]

RUN a2enmod rewrite
RUN a2enmod status

#######################################
FROM base AS config
COPY apache2/conf/000-custom.conf /etc/apache2/sites-available/
RUN a2ensite 000-custom

COPY apache2/srv /srv
RUN chmod +x /srv/www.sunbird.local/cli/*.sh 
RUN chown -R :www-data /srv/www.sunbird.local/public/apps
RUN chown -R :www-data /srv/www.sunbird.local/logs

COPY apache2/conf/10-www.sunbird.local.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite 10-www.sunbird.local

COPY sunbird-startup.sh /bin
RUN chmod +x /bin/sunbird-startup.sh



ENTRYPOINT [ "/bin/sunbird-startup.sh" ]

