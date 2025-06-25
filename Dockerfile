FROM wordpress:6.8.1-fpm-alpine

# Install Redis extension
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
    ; \
    \
    pecl install redis; \
    docker-php-ext-enable redis; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --virtual .redis-phpext-rundeps $runDeps; \
    apk del .build-deps

# Verify Redis extension is loaded
RUN php -m | grep -q redis
