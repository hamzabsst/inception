FROM debian:bookworm

RUN apt-get update && apt-get install -y php-cli php-mysqli wget \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html \
	&& wget -O /var/www/html/index.php https://www.adminer.org/latest.php

WORKDIR /var/www/html

EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]