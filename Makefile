# ============================================
# VARIABLES
# ============================================
DATA_DIR 		= $(HOME)/data
MYSQL_DIR 		= $(DATA_DIR)/mariadb
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
NC 				= \033[0m # No Color

# ============================================
# TARGETS
# ============================================

all: up

# Create data directories
mkdirs:
	@echo "$(GREEN)Creating data directories...$(NC)"
	@mkdir -p $(MYSQL_DIR) $(WP_DIR)
	@echo "$(GREEN)✓ Directories created$(NC)"

# Build and start containers
up: mkdirs
	@echo "$(GREEN)Building and starting containers...$(NC)"
	$(DC) up --build -d
	@echo "$(GREEN)✓ Containers started$(NC)"

# Stop and remove containers
down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(DC) down
	@echo "$(YELLOW)✓ Containers stopped$(NC)"

# Stop containers (keep them)
stop:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(DC) stop
	@echo "$(YELLOW)✓ Containers stopped$(NC)"

# Start stopped containers
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

# Clean: Stop containers + remove images (keep volumes)
clean: down
	@echo "$(YELLOW)Cleaning images...$(NC)"
	docker system prune -af
	@echo "$(YELLOW)✓ Cleaned$(NC)"

# Full clean: Remove everything including volumes
fclean: down
	@echo "$(RED)Full clean: Removing everything...$(NC)"
	docker system prune -af --volumes
	@sudo rm -rf $(DATA_DIR)
	@echo "$(RED)✓ Full clean completed$(NC)"

# Rebuild everything
re: fclean all

# Help
help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  make all     - Build and start containers"
	@echo "  make up      - Build and start containers"
	@echo "  make down    - Stop and remove containers"
	@echo "  make stop    - Stop containers"
	@echo "  make start   - Start stopped containers"
	@echo "  make logs    - View logs"
	@echo "  make ps      - Show status"
	@echo "  make clean   - Clean images (keep volumes)"
	@echo "  make fclean  - Full clean (remove volumes)"
	@echo "  make re      - Rebuild everything"

.PHONY: all mkdirs up down stop start logs ps clean fclean re help