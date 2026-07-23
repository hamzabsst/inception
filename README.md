*This project has been created as part of the 42 curriculum by hbousset.*

# Inception

## Description
Inception containerizes a WordPress stack with NGINX, WordPress (PHP-FPM), and MariaDB, each in its own container on an isolated Docker network — plus three bonus services: Redis (object cache), Adminer (DB admin UI), and a static showcase site.

**Goal:** demonstrate Docker best practices — container orchestration, persistent storage, network isolation, and secure config management.

**Sources Included:** custom Dockerfiles per service, `docker-compose.yml`, config files (NGINX, PHP-FPM, Redis, DB init, WordPress setup), entrypoint scripts, Makefile.

## Docker Architecture & Design Choices

- Each service in its own container, built from Debian bookworm (penultimate stable, not `latest`), no pre-made images
- Named volumes for persistent data; NGINX is the sole entrypoint (HTTPS, port 443 only)
- Adminer/static site exposed on separate ports; Redis is internal-only

**VMs vs Docker:** VMs run a full OS (heavy, slow to start); Docker shares the host kernel (lightweight, starts in seconds). → **Chosen: Docker**, for efficiency.

**Secrets vs Env Variables:** env vars sit in plain text in `.env`; Docker Secrets are mounted as files, not exposed in `docker inspect`. → **Chosen: Secrets** for passwords, `.env` for non-sensitive config.

**Docker Network vs Host Network:** bridge network isolates containers with DNS-based discovery; host network shares the host's network stack directly, no isolation. → **Chosen: bridge network** (`inception`).

**Volumes vs Bind Mounts:** named volumes are Docker-managed and portable; bind mounts point straight at a host path. → **Chosen: named volumes** bound via `driver_opts` to `/home/hbousset/data/` — Docker-managed, but still lands at a fixed host path.

## Instructions

### Prerequisites
- Docker (v20.10+) and Docker Compose (v1.29+)
- Make and Git

### Setup & Execution

1. **Configure secrets** (required for security):
   ```bash
   vim secrets/db_root_password.txt    # MariaDB root password
   vim secrets/db_password.txt         # Database user password
   vim secrets/wp_admin_password.txt   # WordPress admin password
   vim secrets/wp_user_password.txt    # WordPress user password
   vim secrets/redis_password.txt      # Redis password
   ```

2. **Review runtime settings** in `srcs/.env`:
   ```bash
   cat srcs/.env
   ```

3. **Configure domain** in `/etc/hosts`:
   ```bash
   sudo vim /etc/hosts
   # Add: 127.0.0.1 hbousset.42.fr
   ```

4. **Build and launch**:
   ```bash
   make all        # Build images and start containers
   make status     # Check service status
   make logs       # View container logs
   ```

### Access Services
- Website: `https://hbousset.42.fr`
- WordPress Admin: `https://hbousset.42.fr/wp-admin`
- Adminer (bonus): `http://hbousset.42.fr:8080`
- Static site (bonus): `http://hbousset.42.fr:8081`
- Redis (bonus): internal only, used by WordPress as an object cache

**Note:** SSL warnings are normal with self-signed certificates. Accept them to proceed.

### Useful Commands
```bash
make up       # Start containers
make down     # Stop and remove containers
make stop     # Stop containers (keep them)
make re       # Full rebuild
make fclean   # Reset everything (remove volumes)
make logs     # View all logs
make status   # Check container status
```

## Resources

### Documentation & References
- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- WordPress: https://wordpress.org/support/
- NGINX: https://nginx.org/en/docs/
- MariaDB: https://mariadb.com/kb/en/documentation/
- Redis: https://redis.io/docs/
- Adminer: https://www.adminer.org/

### How AI Was Used
AI assisted with:
1. **Conceptual Understanding** — Docker architecture, networking, and volume management concepts
2. **Technical Implementation** — Dockerfile best practices, docker-compose configuration, entrypoint scripting, and troubleshooting (e.g. Debian version selection, MariaDB root-password handling, service healthchecks/`depends_on` ordering)
3. **Documentation** — Structure and writing of README, USER_DOC.md, and DEV_DOC.md