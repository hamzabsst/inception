FROM debian:bullseye

RUN apt-get update && \
	apt-get install -y mariadb-server && \
	rm -rf /var/lib/mysql/* && \
	rm -rf /var/lib/apt/lists/*

COPY conf/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 3306

CMD ["mariadbd", "--user=mysql"]
