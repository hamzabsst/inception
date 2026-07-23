# Inception — Developer Guide

## Setup

**Prerequisites:** Docker (v20.10+), Docker Compose, Make, Git.

```bash
git clone <repository_url>
cd inception
```

Create `srcs/.env` (DB name/user, `WP_ADMIN`, `WP_ADMIN_EMAIL`, `WP_USER`, `DOMAIN_NAME`, etc.) and fill in `secrets/*.txt` (DB passwords, WP passwords, Redis password). `make up` creates the data directories automatically.

## Project Structure

- `srcs/docker-compose.yml` — services, network, volumes, secrets; containers reach each other by service name
- `srcs/requirements/*/Dockerfile` — one per mandatory service (nginx, wordpress, mariadb)
- `srcs/requirements/bonus/*/Dockerfile` — one per bonus service (redis, adminer, static-site)
- `srcs/requirements/*/conf/` — entrypoint scripts and config templates per service

## Build & Run

```bash
make all     # or `make up` — build images, start all containers
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
docker compose -f srcs/docker-compose.yml build                 # build only
docker compose -f srcs/docker-compose.yml up                    # foreground, see logs
docker compose -f srcs/docker-compose.yml exec wordpress bash    # shell into a container
```

## Networking

- Services resolve each other by name: `mariadb:3306`, `wordpress:9000`, `nginx:443`, `redis:6379`
- Only NGINX (443), Adminer (8080), and the static site (8081) expose ports to the host — everything else stays internal
- Inspect: `docker network ls`, `docker network inspect srcs_inception`

## Data & Volumes

Named volumes, bound to a fixed host path via `driver_opts`:
```
/home/<user>/data/mariadb    ->  /var/lib/mysql (mariadb container)
/home/<user>/data/wordpress  ->  /var/www/html (wordpress + nginx containers)
```

```bash
docker volume ls
docker volume inspect srcs_wordpress
du -sh /home/<user>/data/*
```

**Backup:**
```bash
tar -czf inception_backup_$(date +%Y%m%d_%H%M%S).tar.gz /home/<user>/data/
```

**Database dump/restore:**
```bash
# dump
docker compose -f srcs/docker-compose.yml exec mariadb mysqldump -u wp_user -p"$(cat secrets/db_password.txt)" wordpress > backup.sql

# restore
cat backup.sql | docker compose -f srcs/docker-compose.yml exec -T mariadb mysql -u wp_user -p"$(cat secrets/db_password.txt)" wordpress
```

**Remove volumes/data:** `make fclean` (deletes everything — use with care).

## Troubleshooting

|           Problem             |                                                   Fix                                                        |
|-------------------------------|--------------------------------------------------------------------------------------------------------------|
| Permission denied on volume   | `sudo chown -R 999:999 /home/<user>/data/mariadb`, `sudo chown -R 33:33 /home/<user>/data/wordpress`         |
| Container can't reach another | `docker compose -f srcs/docker-compose.yml exec wordpress ping mariadb`                                      |
| Redis not connected           | `docker compose -f srcs/docker-compose.yml exec wordpress wp redis status --allow-root --path=/var/www/html` |
| Check container env vars      |  `docker inspect mariadb \| grep -A 20 Env`                                                                  |