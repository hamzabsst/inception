COMPOSE_FILE	= srcs/docker-compose.yml
DATA_DIR		= /home/$(USER)/inception/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	@docker compose -f $(COMPOSE_FILE) down

start:
	@docker compose -f $(COMPOSE_FILE) start

stop:
	@docker compose -f $(COMPOSE_FILE) stop

re: fclean all

clean: down
	@docker system prune -f

fclean:
	@docker compose -f $(COMPOSE_FILE) down -v
	@docker system prune -f
	@rm -rf $(DATA_DIR)

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

status:
	@docker compose -f $(COMPOSE_FILE) ps

.PHONY: all up down start stop re clean fclean logs status
