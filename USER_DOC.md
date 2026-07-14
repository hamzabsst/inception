# User Documentation - Inception

This guide explains how end users and administrators can manage and use the Inception WordPress infrastructure.

## Table of Contents

1. [Services Overview](#services-overview)
2. [Quick Start](#quick-start)
3. [Accessing the Website](#accessing-the-website)
4. [Managing Credentials](#managing-credentials)
5. [Health Checks & Troubleshooting](#health-checks--troubleshooting)
6. [Backup & Recovery](#backup--recovery)

---

## Services Overview

The Inception project provides three interconnected services:

### 1. **NGINX Web Server**
- Handles incoming HTTP/HTTPS requests
- Serves static files (images, CSS, JavaScript)
- Forwards dynamic requests to WordPress (PHP-FPM)
- Provides SSL/TLS encryption for secure connections
- Container Name: `nginx`
- Access: Port 443 (HTTPS)

### 2. **WordPress Content Management System**
- PHP-based CMS for managing website content
- Handles page creation, blog posts, media management
- User authentication and role-based access control
- Container Name: `wordpress`
- Internal Port: 9000 (PHP-FPM)
- Requires MariaDB for data storage

### 3. **MariaDB Database Server**
- Stores all WordPress data (posts, users, settings, etc.)
- Manages user credentials and permissions
- Container Name: `mariadb`
- Internal Port: 3306
- Not directly accessible from outside the container network

---

## Quick Start

### Starting the Services

```bash
cd /path/to/inception
make up
```

**What happens:**
- Docker creates and starts three containers (NGINX, WordPress, MariaDB)
- Containers automatically restart if they crash
- Services are available within seconds
- HTTPS is enabled with self-signed certificates

### Stopping the Services

```bash
make stop
```

**What happens:**
- Services gracefully shut down
- Data in volumes persists (nothing is lost)
- Containers remain on the system
- Can be restarted later without rebuilding

### Stopping and Removing Containers

```bash
make down
```

**What happens:**
- Containers are removed completely
- Volumes and data are preserved
- Use this before rebuilding the entire stack

---

## Accessing the Website

### Website Home Page

1. Open your web browser
2. Navigate to: **https://localhost**
3. Accept the SSL certificate warning (self-signed certificate)
4. You should see your WordPress homepage

**Note:** If you configured a custom domain in `.env` (e.g., `DOMAIN_NAME=mysite.local`), add it to your `/etc/hosts` file:
```bash
127.0.0.1   mysite.local
```
Then access: https://mysite.local

### WordPress Admin Panel

1. Navigate to: **https://localhost/wp-admin**
2. Log in with credentials configured in `.env`:
   - Username: `WP_ADMIN_USER`
   - Password: `WP_ADMIN_PASSWORD`
3. Dashboard shows:
   - Site statistics
   - Recent posts and comments
   - System status
   - Plugin/theme management

### Admin Panel Features

Once logged in, administrators can:

- **Posts**: Create, edit, delete blog articles
- **Pages**: Create static pages
- **Media**: Upload and manage images/files
- **Users**: Create accounts and manage user roles
- **Settings**: Configure site title, URL, timezone, etc.
- **Plugins**: Install and manage WordPress extensions
- **Themes**: Choose and customize website appearance

---

## Managing Credentials

### Where Credentials Are Stored

All credentials are stored in the `.env` file in the project root:

```bash
cat .env
```

### Important Credentials

| Credential | Purpose | File Location | Default |
|------------|---------|---------------|---------|
| `MYSQL_ROOT_PASSWORD` | Database root access | `.env` | Set during setup |
| `MYSQL_USER` | WordPress DB user | `.env` | `wp_user` |
| `MYSQL_PASSWORD` | WordPress DB password | `.env` | Set during setup |
| `WP_ADMIN_USER` | WordPress admin username | `.env` | `admin` |
| `WP_ADMIN_PASSWORD` | WordPress admin password | `.env` | Set during setup |
| `WP_ADMIN_EMAIL` | Admin contact email | `.env` | Set during setup |

### Changing WordPress Admin Password

1. Log in to WordPress admin panel: https://localhost/wp-admin
2. Click your username in top-right corner
3. Go to "Account"
4. Click "Edit Profile"
5. Change password and save

### Changing Database Password

1. Stop the services:
   ```bash
   make down
   ```

2. Edit `.env` file:
   ```bash
   nano .env
   ```
   Update `MYSQL_PASSWORD` and `MYSQL_ROOT_PASSWORD`

3. Remove old database volume:
   ```bash
   rm -rf ~/data/mariadb/*
   ```

4. Restart services:
   ```bash
   make up
   ```

### Credential Security Best Practices

- **Never commit `.env` to Git** — Add to `.gitignore`
- **Use strong passwords** — Mix uppercase, lowercase, numbers, symbols
- **Change default credentials** — Don't use `admin`/`password`
- **Limit admin access** — Only give admin roles to trusted users
- **Update regularly** — Change passwords every 3-6 months
- **Backup `.env`** — Keep secure backups separate from the repository

---

## Health Checks & Troubleshooting

### Checking Service Status

```bash
make status
```

**Expected output:**
```
CONTAINER ID   IMAGE              STATUS              PORTS
abc123...      inception_nginx    Up X minutes        0.0.0.0:443->443/tcp
def456...      inception_wordpress Up X minutes
ghi789...      inception_mariadb  Up X minutes
```

All containers should show `Up` status.

### Viewing Service Logs

```bash
# View all service logs with timestamps
make logs

# View logs for specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb

# View last 100 lines and follow new output
docker compose -f srcs/docker-compose.yml logs --tail=100 -f
```

### Common Issues & Solutions

#### Website shows "Connection Refused"
```bash
# Check if services are running
make status

# Start them if stopped
make up

# Check logs for errors
make logs
```

#### SSL Certificate Warning
- This is normal with self-signed certificates
- Click "Advanced" → "Proceed to localhost (unsafe)" in your browser
- For production, use proper SSL certificates from a CA

#### Database Connection Error in WordPress
1. Check MariaDB is running: `make status`
2. Verify `.env` credentials are correct
3. Restart all services: `make stop && make up`

#### Slow Performance or Memory Issues
```bash
# Check available disk space
df -h ~/data/

# Check Docker resource usage
docker stats

# Clean up unused Docker resources
docker system prune -a
```

#### Cannot access WordPress admin panel
1. Verify you're using correct credentials from `.env`
2. Try clearing browser cache (Ctrl+Shift+Delete)
3. Check WordPress is running: `docker compose -f srcs/docker-compose.yml logs wordpress`
