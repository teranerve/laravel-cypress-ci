FROM php:7.3-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Rusman <rusman@technerve.my>" \
  PHP="7.3" \
  NODE="14" \
  org.label-schema.name="technerve/laravel-cypress-ci" \
  org.label-schema.description=":coffee: Docker images for build and test PHP (Laravel) applications with Gitlab CI (or any other CI platform!)" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vcs-url="https://github.com/teranerve/laravel-cypress-ci" \
  org.label-schema.vcs-ref=$VCS_REF

# Set correct environment variables
ENV IMAGE_USER=php
ENV HOME=/home/$IMAGE_USER
ENV COMPOSER_HOME=$HOME/.composer
ENV PATH=$HOME/.yarn/bin:$PATH
ENV GOSS_VERSION=0.3.8
ENV NODE_VERSION=14
ENV NPM_VERSION=6
ENV YARN_VERSION=latest
ENV PHP_VERSION=7.3

WORKDIR /tmp

COPY ./php/scripts/*.sh /tmp/
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
COPY --from=mhart/alpine-node:14 /usr/bin/node /usr/bin/
COPY --from=mhart/alpine-node:14 /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/* /usr/lib/

# COPY INSTALL SCRIPTS
RUN chmod +x /tmp/*.sh \
  && adduser -D $IMAGE_USER \
  && mkdir -p /var/www/html \
  && apk add --update --no-cache bash \
  && bash ./packages.sh \
  && bash ./cypress.sh \
  && bash ./extensions.sh \
  && bash ./nodeyarn.sh \
  && composer global require "hirak/prestissimo:^0.3" \
  && rm -rf ~/.composer/cache/* \
  && chown -R $IMAGE_USER:$IMAGE_USER /var/www $HOME \
  && echo "$IMAGE_USER  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers \
  && curl -fsSL https://goss.rocks/install | GOSS_VER=v${GOSS_VERSION} sh \
  && bash ./cleanup.sh

USER $IMAGE_USER

WORKDIR /var/www/html

CMD ["php", "-a"]
