# Developer Documentation - Inception

This guide explains how developers can set up, build, and manage the Inception project infrastructure.

## Environment Setup

### Prerequisites

Install the following tools:

```bash
# Check Docker installation (v20.10+)
docker --version

# Check Docker Compose installation (v1.29+)
docker compose version

# Check Make installation
make --version

# Check Git
git --version
```

### Initial Configuration

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd inception
   ```

2. **Create `.env` file from template:**
   ```bash
   cat > .env << EOF
   MYSQL_ROOT_PASSWORD=root_secure_password_here
   MYSQL_DATABASE=wordpress_db
   MYSQL_USER=wp_user
   MYSQL_PASSWORD=wp_user_secure_password

   WP_TITLE=My WordPress Site
   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=admin_secure_password
   WP_ADMIN_EMAIL=admin@example.local
   WP_URL=https://localhost
   WP_PROTOCOL=https

   DOMAIN_NAME=localhost
   USER=$(whoami)
   EOF
   ```

3. **Create data directories:**
   ```bash
   mkdir -p ~/data/mariadb ~/data/wordpress
   ```

4. **Verify setup:**
   ```bash
   ls -la ~/data/
   cat .env
   docker compose version
   ```

### IDE/Editor Setup

#### VS Code
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/.env": true
  }
}
```

#### Docker Extension (Recommended)
```bash
# Install Docker extension in VS Code for container management GUI
```

### Key Files Explained

#### `srcs/docker-compose.yml`
Defines all services, networks, volumes, and dependencies:
- Services communicate via DNS (e.g., `mariadb`, `wordpress`)
- Volumes enable data persistence across container restarts
- Environment variables injected from `.env` file
- Restart policy: `unless-stopped` (auto-restart on failure)

#### `srcs/requirements/*/Dockerfile`
Each service has its own Dockerfile:
- **nginx**: Web server for routing and SSL termination
- **wordpress**: PHP application runtime
- **mariadb**: Database server

#### `srcs/requirements/*/conf/`
Configuration and initialization scripts:
- **entrypoint.sh** — Runs on container startup
- **setup_wp.sh** — WordPress initialization (downloads core, installs plugins)
- **nginx.conf.template** — NGINX configuration (dynamically templated)
- **www.conf** — PHP-FPM configuration

---

## Building & Launching

### Makefile Commands

#### Build and Start (First Time)
```bash
make all
# or
make up
```

**What happens:**
1. Creates `~/data/mariadb` and `~/data/wordpress` directories
2. Builds Docker images from Dockerfiles
3. Creates and starts containers
4. Initializes MariaDB database
5. Sets up WordPress

**Build output:**
```
[+] Building 15.2s
 => mariadb                          ✓
 => wordpress                         ✓
 => nginx                             ✓
[+] Running 3/3 ✓
 ✓ Network inception_inception        Created
 ✓ Container mariadb                   Started
 ✓ Container wordpress                 Started
 ✓ Container nginx                     Started
```

#### Rebuild Everything
```bash
make re
```

Equivalent to:
```bash
make fclean  # Remove containers and volumes
make all     # Build and start fresh
```

#### Manage Running Services

```bash
# Stop containers (keep volumes)
make stop

# Start stopped containers
make start

# Stop and remove containers (keep volumes)
make down

# Stop, remove containers and VOLUMES
make fclean
```

#### View Logs
```bash
# Real-time logs from all services
make logs

# Specific service logs
docker compose -f srcs/docker-compose.yml logs nginx -f
docker compose -f srcs/docker-compose.yml logs wordpress -f
docker compose -f srcs/docker-compose.yml logs mariadb -f

# Last N lines
docker compose -f srcs/docker-compose.yml logs --tail=50
```

#### Check Status
```bash
make status
```

Output:
```
CONTAINER ID   IMAGE                  STATUS              PORTS
abc123...      inception:nginx        Up 2 minutes        0.0.0.0:443->443/tcp
def456...      inception:wordpress    Up 2 minutes
ghi789...      inception:mariadb      Up 2 minutes
```

### Manual Docker Compose Commands

#### Build Images Without Starting
```bash
docker compose -f srcs/docker-compose.yml build
```

#### Start in Foreground (See Logs)
```bash
docker compose -f srcs/docker-compose.yml up
# Press Ctrl+C to stop
```

#### Execute Commands in Running Container
```bash
# Run bash shell
docker compose -f srcs/docker-compose.yml exec wordpress bash

# Run one-off command
docker compose -f srcs/docker-compose.yml exec mariadb mysql \
  -u wp_user -p$MYSQL_PASSWORD wordpress_db -e "SHOW TABLES;"
```

---

## Container Management

### Inspecting Containers

```bash
# List all containers
docker ps -a

# Inspect specific container
docker inspect mariadb

# Check container stats (CPU, memory, network)
docker stats

# View container environment variables
docker inspect mariadb | grep -A 20 Env
```

### Container Networking

#### Service DNS Resolution

Containers communicate by service name (Docker's internal DNS):
- `mariadb:3306` — MariaDB service
- `wordpress:9000` — WordPress/PHP-FPM service
- `nginx:443` — NGINX service

Example (inside WordPress container):
```bash
docker compose -f srcs/docker-compose.yml exec wordpress ping mariadb
# Response: ping statistics ... host is reachable
```

#### Network Inspection
```bash
# List networks
docker network ls

# Inspect inception network
docker network inspect inception_inception

# Shows connected containers and IP addresses
```

#### Port Mapping
Only NGINX exposes ports to the host:
- HTTPS: `0.0.0.0:443->443/tcp`
- WordPress and MariaDB are internal-only (secure)

### Volume Management

#### List Volumes
```bash
docker volume ls
# Named volumes created by docker-compose
```

#### Inspect Volume
```bash
docker volume inspect inception_wordpress
# Shows mount location: ~/data/wordpress
```

#### Data Location
```bash
# Database files
ls -la ~/data/mariadb/

# WordPress files (wp-content, wp-config.php, etc.)
ls -la ~/data/wordpress/

# File sizes
du -sh ~/data/*
```

#### Backup Volumes
```bash
# Backup WordPress volume
tar -czf wordpress_backup.tar.gz ~/data/wordpress/

# Backup MariaDB volume
tar -czf mariadb_backup.tar.gz ~/data/mariadb/

# Full backup
tar -czf inception_backup_$(date +%Y%m%d_%H%M%S).tar.gz ~/data/
```

#### Clean Volumes
```bash
# Remove all unused volumes
docker volume prune

# Remove specific volume (CAUTION: deletes data)
docker volume rm inception_mariadb inception_wordpress

# Alternative: use Makefile
make fclean  # Removes volumes and data
```

---

## Data Persistence

### Understanding Volume Mounts

The project uses **bind mounts** (not named volumes):

```yaml
volumes:
  mariadb:/var/lib/mysql           # Container path
    driver_opts:
      device: /home/${USER}/data/mariadb  # Host path
```

**Advantages:**
- Easy to locate and backup data
- Direct access from host file system
- No Docker daemon management layer

**Considerations:**
- File permissions must be correct
- Less isolated than named volumes
- Platform-specific paths

### File Permissions

```bash
# Check permissions
ls -ld ~/data/mariadb ~/data/wordpress

# Fix if needed (run as user, not root)
chmod 755 ~/data/mariadb
chmod 755 ~/data/wordpress

# If issues with container access:
docker compose -f srcs/docker-compose.yml exec mariadb ls -la /var/lib/mysql
```

### Data Recovery

#### From Host Filesystem
```bash
# Database files are stored as-is
cd ~/data/mariadb
ls -la

# WordPress application files
cd ~/data/wordpress
find . -name "wp-config.php"
```

#### Database Recovery
```bash
# Export complete database
docker compose -f srcs/docker-compose.yml exec mariadb mysqldump \
  -u root -p$MYSQL_ROOT_PASSWORD --all-databases > full_backup.sql

# Export specific database
docker compose -f srcs/docker-compose.yml exec mariadb mysqldump \
  -u wp_user -p$MYSQL_PASSWORD wordpress_db > wordpress_backup.sql

# Restore from backup
cat wordpress_backup.sql | docker compose -f srcs/docker-compose.yml exec -T mariadb mysql \
  -u wp_user -p$MYSQL_PASSWORD wordpress_db
```

### Persistent Volume Challenges

#### Volumes Not Syncing
```bash
# Verify volumes are mounted
docker compose -f srcs/docker-compose.yml exec nginx mount | grep /var/www

# Check file system changes
docker compose -f srcs/docker-compose.yml exec wordpress ls -la /var/www/html/
```

#### Permission Denied Errors
```bash
# Check actual permissions in container
docker compose -f srcs/docker-compose.yml exec mariadb id
docker compose -f srcs/docker-compose.yml exec mariadb ls -ld /var/lib/mysql

# Fix from host if needed
sudo chown -R 999:999 ~/data/mariadb  # MariaDB user ID
sudo chown -R 33:33 ~/data/wordpress  # www-data user ID (NGINX)
```
