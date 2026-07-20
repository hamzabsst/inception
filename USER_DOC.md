# Inception — User Guide

Docker setup running WordPress with NGINX and MariaDB.

## Services

|  Service	|                                Role                               |  Container  |
|-----------|-------------------------------------------------------------------|-------------|
| NGINX     | HTTPS entry point, serves static files, forwards PHP to WordPress | `nginx`     |
| WordPress | CMS (PHP-FPM), needs MariaDB                                      | `wordpress` |
| MariaDB   | Stores all WordPress data, not exposed outside the network        | `mariadb`   |

## Commands

```bash
make up      # start everything
make stop    # stop containers, keep data
make down    # remove containers, keep volumes
make status  # check container status
make logs    # view logs (all services)
```

## Accessing the Site

- **Site:** `https://localhost` (or your custom domain from `.env`, added to `/etc/hosts`)
- **Admin panel:** `https://<your-domain>/wp-admin`, login with `WP_ADMIN` / `WP_ADMIN_PASSWORD`

You'll get a browser warning for the self-signed SSL cert — that's expected, just proceed.

## Credentials

- Config values: `srcs/.env`
- Passwords: `secrets/` (e.g. `db_password.txt`, `wp_admin_password.txt`)
- Never commit `.env` to Git; use strong, non-default passwords

**To change the WordPress admin password:** log in → username menu → Edit Profile → set new password.

**To change the DB password:** `make down` → edit `.env` → `rm -rf ~/data/mariadb/*` → `make up`.

## Troubleshooting

|     Problem             |                           Fix                                    |
|-------------------------|------------------------------------------------------------------|
| Connection refused      | `make status` → `make up` if stopped → `make logs` for errors    |
|     SSL warning         | Normal for self-signed certs — click through                     |
| DB connection error     | Check MariaDB is up, verify `.env`, then `make stop && make up`  |
| Slow / high memory      | `df -h ~/data/`, `docker stats`, `docker system prune -a`        |
| Can't reach admin panel | Recheck credentials, clear browser cache, check WordPress logs   |