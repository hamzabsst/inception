# Inception — Developer Guide

## Setup

**Prerequisites:** Docker (v20.10+), Docker Compose, Make, Git.

```bash
git clone <repository_url>
cd inception
```

Create `srcs/.env` with your config (DB name/user, `WP_ADMIN`, `WP_ADMIN_EMAIL`, `WP_USER`, `DOMAIN_NAME`, etc.), and:

```bash
mkdir -p ~/data/mariadb ~/data/wordpress
```

## Project Structure

- `srcs/docker-compose.yml` — defines services, networks, volumes; containers reach each other by service name (`mariadb`, `wordpress`, `nginx`)
- `srcs/requirements/*/Dockerfile` — one per service (nginx, wordpress, mariadb)
- `srcs/requirements/*/conf/` — `entrypoint.sh`, `setup_wp.sh`, `nginx.conf.template`, `www.conf`

## Build & Run

```bash
make all     # or `make up` — build images, start containers, init DB + WordPress
make re      # fclean + all — full rebuild
make stop    # stop containers, keep volumes
make start   # restart stopped containers
make down    # stop + remove containers, keep volumes
make fclean  # stop + remove containers AND volumes/data
make status  # container status
make logs    # tail all logs (or: docker compose -f srcs/docker-compose.yml logs <service> -f)
```

Useful manual commands:
```bash
docker compose -f srcs/docker-compose.yml build          # build only
docker compose -f srcs/docker-compose.yml up             # foreground, see logs
docker compose -f srcs/docker-compose.yml exec wordpress bash   # shell into a container
```

## Networking

- Services resolve each other by name: `mariadb:3306`, `wordpress:9000`, `nginx:443`
- Only NGINX exposes a port to the host (`443`) — WordPress and MariaDB stay internal
- Inspect: `docker network ls`, `docker network inspect inception_inception`

## Data & Volumes

Data lives on the host via bind mounts, not named volumes:
```
~/data/mariadb     ->  /var/lib/mysql (in mariadb container)
~/data/wordpress   ->  WordPress files (in wordpress container)
```

```bash
docker volume ls
docker volume inspect inception_wordpress
du -sh ~/data/*
```

**Backup:**
```bash
tar -czf inception_backup_$(date +%Y%m%d_%H%M%S).tar.gz ~/data/
```

**Database dump/restore:**
```bash
# dump
docker compose -f srcs/docker-compose.yml exec mariadb mysqldump -u wp_user -p$MYSQL_PASSWORD wordpress_db > backup.sql

# restore
cat backup.sql | docker compose -f srcs/docker-compose.yml exec -T mariadb mysql -u wp_user -p$MYSQL_PASSWORD wordpress_db
```

**Clean/remove volumes:** `docker volume prune` or `make fclean` (deletes data — use with care).

## Troubleshooting

|         Problem               |                                           Fix                                                          |
|-------------------------------|--------------------------------------------------------------------------------------------------------|
| Permission denied on volume   | `sudo chown -R 999:999 ~/data/mariadb` (mysql user), `sudo chown -R 33:33 ~/data/wordpress` (www-data) |
| Volumes look out of sync      | Check mounts: `docker compose -f srcs/docker-compose.yml exec <service> mount \| grep /var/www`        |
| Container can't reach another | `docker compose -f srcs/docker-compose.yml exec wordpress ping mariadb`                                |
| Check container env vars      | `docker inspect mariadb \| grep -A 20 Env`                                                             |