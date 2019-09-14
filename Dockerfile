FROM jorge07/alpine-php:7.3-dev

RUN apk add --update bash && rm -rf /var/cache/apk/*

COPY ./scripts /home/cronjob-manager/
RUN chmod +x /home/cronjob-manager/bash/cronjob-manager.sh

RUN cd /home/cronjob-manager/php/ && composer install