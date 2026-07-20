*This project has been created as part of the 42 curriculum by hbousset.*

# Inception

## Description

Inception is a Docker-based infrastructure project that containerizes a WordPress application stack using three services: NGINX (web server), WordPress (with PHP-FPM), and MariaDB (database). Each service runs in its own dedicated container, communicating securely through an isolated Docker network.

**Project Goal:** Build a complete containerized application infrastructure demonstrating Docker best practices, including container orchestration, persistent data storage, network isolation, and secure configuration management.

**Sources Included:**
- Custom Dockerfiles for NGINX, WordPress, and MariaDB
- docker-compose.yml for service orchestration
- Configuration files (NGINX, PHP-FPM, database initialization, WordPress setup)
- Entrypoint scripts for service initialization
- Makefile for automation

## Docker Architecture & Design Choices

### Service Architecture
- Each service runs in its own container (separation of concerns)
- Uses Debian bullseye (stable, not latest)
- All images built from custom Dockerfiles (no pre-made images)
- Persistent data stored in volumes for survival across restarts
- NGINX is the sole entrypoint via HTTPS (port 443 only)

### Technology Comparisons

**Virtual Machines vs Docker**
- VMs: Heavy overhead (full OS), minutes to start, high resource usage
- Docker: Lightweight (shared kernel), seconds to start, low resource usage
- **Chosen:** Docker for efficiency and deployment simplicity

**Secrets vs Environment Variables**
- Environment variables: Plain text in .env (low security)
- Docker Secrets: Encrypted, not exposed in process lists (high security)
- **Chosen:** Docker Secrets for production data + .env for configuration

**Docker Network vs Host Network**
- Bridge network: Isolated containers, DNS-based communication (secure)
- Host network: Shared network, direct access, no isolation (exposed)
- **Chosen:** Bridge network (`inception`) for container isolation

**Docker Volumes vs Bind Mounts**
- Named volumes: Docker-managed, optimized performance
- Bind mounts: User-managed paths, easy data access
- **Chosen:** Named volumes persisting to `/home/hbousset/data/` (hybrid approach)

## Instructions

### Prerequisites
- Docker (v20.10+) and Docker Compose (v1.29+)
- Make and Git
- Linux/macOS (Windows requires WSL2)

### Setup & Execution

1. **Configure secrets** (required for security):
   ```bash
   nano secrets/db_root_password.txt    # Set MariaDB root password
   nano secrets/db_password.txt         # Set database user password
   nano secrets/wp_admin_password.txt   # Set WordPress admin password
   nano secrets/wp_user_password.txt    # Set WordPress user password
   ```

2. **Review runtime settings** in `srcs/.env`:
   ```bash
   cat srcs/.env
   ```

3. **Configure domain** in `/etc/hosts`:
   ```bash
   sudo nano /etc/hosts
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
- Database: `mariadb:3306` (internal only)

### Useful Commands
```bash
make up       # Start containers
make down     # Stop and remove containers
make stop     # Stop containers (keep them)
make re       # Full rebuild
make fclean   # Reset everything (remove volumes)
make logs     # View all logs
```

**Note:** SSL warnings are normal with self-signed certificates. Accept them to proceed.

## Resources

### Documentation & References
- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- WordPress: https://wordpress.org/support/
- NGINX: https://nginx.org/en/docs/
- MariaDB: https://mariadb.com/kb/en/documentation/

### How AI Was Used
AI (Claude) assisted with:
1. **Conceptual Understanding** - Docker architecture, networking, and volume management concepts
2. **Technical Implementation** - Dockerfile best practices, docker-compose configuration, troubleshooting
3. **Documentation** - Structure and writing of README, USER_DOC.md, and DEV_DOC.md

