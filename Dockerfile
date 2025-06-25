FROM wordpress:6.8.1-fpm-alpine

# Install PHP extensions
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        bzip2-dev \
        gettext-dev \
        gmp-dev \
        libxml2-dev \
        tidyhtml-dev \
        libxslt-dev \
    ; \
    \
    # Install extensions via docker-php-ext-install
    docker-php-ext-install -j$(nproc) \
        bz2 \
        gettext \
        gmp \
        pcntl \
        soap \
        tidy \
        xsl \
    ; \
    \
    # Install Redis extension via PECL
    pecl install redis; \
    docker-php-ext-enable redis; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .php-ext-rundeps $runDeps; \
    apk del .build-deps

# Verify extensions are loaded
RUN php -m | grep -E '(redis|bz2|gettext|gmp|pcntl|soap|tidy|xsl)'
