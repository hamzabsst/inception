NAME		= inception

COMPOSE_FILE	= srcs/docker-compose.yml

all:
	@mkdir -p ~/data/wordpress ~/data/mariadb
	@docker-compose -f $(COMPOSE_FILE) up -d --build

down:
	@docker-compose -f $(COMPOSE_FILE) down

re: down all

clean: down
	@docker system prune -f

fclean: clean
	@if [ -d ~/data/wordpress ] && [ -d ~/data/mariadb ]; then \
		sudo rm -rf ~/data; \
	fi

.PHONY: all down re clean fclean
