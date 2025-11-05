# ============================================
# VARIABLES
# ============================================
DATA_DIR 		= $(HOME)/data
MARIADB_DIR 	= $(DATA_DIR)/mariadb
WP_DIR 			= $(DATA_DIR)/wordpress

COMPOSE_FILE 	= ./srcs/docker-compose.yml
ENV_FILE 		= ./srcs/.env
DC 				= docker compose --env-file $(ENV_FILE) --file $(COMPOSE_FILE)

# ============================================
# COLORS
# ============================================
RED 			= \033[0;31m
GREEN 			= \033[0;32m
YELLOW 			= \033[0;33m
NC 				= \033[0m

# ============================================
# TARGETS
# ============================================

all: up

# Create secrets automatically
secrets:
	@echo "$(GREEN)Checking secrets...$(NC)"
	@mkdir -p srcs/secrets
	@if [ ! -f srcs/secrets/wordpress_admin_password.txt ] || \
	   [ ! -f srcs/secrets/wordpress_user_password.txt ] || \
	   [ ! -f srcs/secrets/db_password.txt ] || \
	   [ ! -f srcs/secrets/db_root_password.txt ]; then \
		echo "$(YELLOW)⚠️  Secrets not found! Creating...$(NC)"; \
		openssl rand -base64 16 > srcs/secrets/wordpress_admin_password.txt; \
		openssl rand -base64 16 > srcs/secrets/wordpress_user_password.txt; \
		openssl rand -base64 16 > srcs/secrets/db_password.txt; \
		openssl rand -base64 16 > srcs/secrets/db_root_password.txt; \
		echo "$(GREEN)✓ All secrets created$(NC)"; \
		echo ""; \
		echo "Generated passwords:"; \
		echo "  WP Admin: $$(cat srcs/secrets/wordpress_admin_password.txt)"; \
		echo "  WP User:  $$(cat srcs/secrets/wordpress_user_password.txt)"; \
		echo "  DB User:  $$(cat srcs/secrets/db_password.txt)"; \
		echo "  DB Root:  $$(cat srcs/secrets/db_root_password.txt)"; \
		echo ""; \
	else \
		echo "$(GREEN)✓ Using existing secrets$(NC)"; \
	fi

# Create data directories
mkdirs:
	@echo "$(GREEN)Creating data directories...$(NC)"
	@mkdir -p $(MARIADB_DIR) $(WP_DIR)
	@echo "$(GREEN)✓ Directories created$(NC)"

# Build and start containers
up: secrets mkdirs
	@echo "$(GREEN)Building and starting containers...$(NC)"
	$(DC) up --build -d
	@echo "$(GREEN)✓ Containers started$(NC)"

# Stop and remove containers
down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(DC) down
	@echo "$(YELLOW)✓ Containers stopped$(NC)"

# Stop containers
stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(DC) stop
	@echo "$(YELLOW)✓ Containers stopped$(NC)"

# Start containers
start:
	@echo "$(GREEN)Starting containers...$(NC)"
	$(DC) start
	@echo "$(GREEN)✓ Containers started$(NC)"

# View logs
logs:
	$(DC) logs --follow

# Status
ps:
	$(DC) ps

# Clean: Stop + remove images (keep volumes & secrets)
clean: down
	@echo "$(YELLOW)Cleaning images...$(NC)"
	docker system prune -af
	@echo "$(YELLOW)✓ Cleaned$(NC)"

# Full clean: Remove everything
fclean: down
	@echo "$(RED)Full clean: Removing everything...$(NC)"
	docker system prune -af --volumes
	@sudo rm -rf $(DATA_DIR)
	@echo "$(RED)✓ Full clean completed$(NC)"

# Rebuild
re: fclean all

# Help
help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  make all     - Build and start (auto-create secrets)"
	@echo "  make up      - Build and start"
	@echo "  make down    - Stop and remove containers"
	@echo "  make stop    - Stop containers"
	@echo "  make start   - Start containers"
	@echo "  make logs    - View logs"
	@echo "  make ps      - Show status"
	@echo "  make clean   - Clean images (keep data & secrets)"
	@echo "  make fclean  - Full clean (remove everything)"
	@echo "  make re      - Rebuild everything"

.PHONY: all secrets mkdirs up down stop start logs ps clean fclean re help