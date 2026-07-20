FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx \
	&& rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/html/
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
