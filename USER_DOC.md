# Inception — User Guide

Docker setup running WordPress with NGINX and MariaDB, plus Redis, Adminer, and a static site as bonus services.

## Services

| Service    | Role                                                                | Container    |
|------------|----------------------------------------------------------------------|--------------|
| NGINX      | HTTPS entry point, serves static files, forwards PHP to WordPress     | `nginx`      |
| WordPress  | CMS (PHP-FPM), needs MariaDB                                         | `wordpress`  |
| MariaDB    | Stores all WordPress data, not exposed outside the network            | `mariadb`    |
| Redis      | Object cache for WordPress (bonus, internal only)                     | `redis`      |
| Adminer    | Web UI to browse the database (bonus)                                 | `adminer`    |
| Static site| Standalone showcase page (bonus)                                      | `bonus-site` |

## Commands

```bash
make up      # start everything
make stop    # stop containers, keep data
make down    # remove containers, keep volumes
make status  # check container status
make logs    # view logs (all services)
```

## Accessing Things

- **Site:** `https://hbousset.42.fr` (add `127.0.0.1 hbousset.42.fr` to `/etc/hosts` first)
- **Admin panel:** `https://hbousset.42.fr/wp-admin`, login with `WP_ADMIN` / `WP_ADMIN_PASSWORD`
- **Adminer:** `http://hbousset.42.fr:8080` — server `mariadb`, `DB_USER` / `db_password.txt`, `DB_NAME`
- **Static site:** `http://hbousset.42.fr:8081`

You'll get a browser warning for the self-signed SSL cert — that's expected, just proceed.

## Credentials

- Config values: `srcs/.env`
- Passwords: `secrets/` (e.g. `db_password.txt`, `wp_admin_password.txt`, `redis_password.txt`)
- Never commit `.env` or `secrets/` to Git; use strong, non-default passwords

**To change the WordPress admin password:** log in → username menu → Edit Profile → set new password.

**To change the DB password:** `make down` → edit `secrets/db_password.txt` → `make fclean` → `make up`.

## Troubleshooting

|       Problem           |                               Fix                                    |
|-------------------------|----------------------------------------------------------------------|
| Connection refused      | `make status` → `make up` if stopped → `make logs` for errors        |
| SSL warning             | Normal for self-signed certs — click through                         |
| DB connection error     | Check MariaDB is up, verify `.env`, then `make stop && make up`      |
| Adminer/site won't load | Check the container's `Up` in `make status`, then its logs           |
| Slow / high memory      | `df -h /home/<user>/data/`, `docker stats`, `docker system prune -a` |