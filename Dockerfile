FROM debian:buster-slim
LABEL Maintainer="Christian Beneke <c.beneke@wirelab.org>" \
      Description="Container for nextcloud intended to run on kubernetes"

ENV NEXTCLOUD_VERSION=17.0.1

RUN set -eux; \
  \
# Install required packages
  apt-get update; \
  apt-get install --no-install-recommends --yes \
    apache2 \
    ca-certificates \
    ffmpeg \
    libapache2-mod-php7.3 \
    libxml2 \
    php7.3 \
    php7.3-bz2 \
    php7.3-common \
    php7.3-curl \
    php7.3-gd \
    php7.3-intl \
    php7.3-json \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-xml \
    php7.3-zip \
    php-imagick \
    php-redis \
    bzip2 \
    gnupg \
    wget \
  ; \
  \
  export GNUPGHOME="$(mktemp -d)"; \
# gpg: key D75899B9A724937A: "Nextcloud Security <security@nextcloud.com>" imported
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "28806A878AE423A28372792ED75899B9A724937A"; \
  \
  wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2; \
  wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc; \
  wget https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.sha256; \
  \
  sha256sum --check nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.sha256; \
  gpg --verify nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc nextcloud-${NEXTCLOUD_VERSION}.tar.bz2; \
  command -v gpgconf && gpgconf --kill all || :; \
  \
  mkdir /var/www/htdocs; \
  chown www-data:www-data /var/www/htdocs; \
  tar --extract --bzip2 \
    --file nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 \
    --strip-components 1 \
    --directory /var/www/htdocs \
    --owner www-data \
    --group www-data \
    nextcloud \
  ; \
# Cleanup
  rm -rf \
    "$GNUPGHOME" \
    nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 \
    nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc \
    nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.sha256 \
    /etc/apache2/sites-enabled/000-default.conf \
  ; \
  apt-get purge --yes \
    bzip2 \
    gnupg \
    wget \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
# Configure apache2
  a2enmod rewrite; \
  a2enmod headers; \
  a2enmod env; \
  a2enmod dir; \
  a2enmod mime;

COPY files/apache-nextcloud.conf /etc/apache2/sites-enabled/
COPY files/entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
