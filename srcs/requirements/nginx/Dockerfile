FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	nginx \
	mime-support \
	openssl \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY conf/mime.types /etc/mime.types
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
