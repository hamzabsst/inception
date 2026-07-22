FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /etc/nginx/sites-enabled/default

COPY site/ /var/www/html/
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]