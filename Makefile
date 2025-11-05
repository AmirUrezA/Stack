.PHONY: help up down restart status logs clean health install

# Default target
help:
	@echo ""
	@echo "Stack Server - Available Commands"
	@echo "=================================="
	@echo ""
	@echo "  make up         - Start all services"
	@echo "  make down       - Stop all services"
	@echo "  make restart    - Restart all services"
	@echo "  make status     - Show status of all services"
	@echo "  make logs       - Show logs from all services"
	@echo "  make clean      - Stop and remove all data (volumes)"
	@echo "  make health     - Run health check on all services"
	@echo "  make install    - Install health check dependencies"
	@echo ""

# Start all services
up:
	@echo "🚀 Starting Stack Server..."
	@docker-compose up -d
	@echo ""
	@echo "✅ Stack Server started successfully!"
	@echo ""
	@echo "Services available at:"
	@echo "  Traefik:     http://localhost:8888"
	@echo "  pgAdmin:     http://pgadmin.localhost"
	@echo "  RabbitMQ:    http://rabbitmq.localhost"
	@echo "  MinIO:       http://minio.localhost"
	@echo "  Keycloak:    http://keycloak.localhost"
	@echo ""
	@echo "  PostgreSQL:  localhost:5432"
	@echo "  Redis:       localhost:6379"
	@echo ""

# Stop all services
down:
	@echo "🛑 Stopping Stack Server..."
	@docker-compose down
	@echo "✅ Stack Server stopped"

# Restart all services
restart:
	@echo "🔄 Restarting Stack Server..."
	@docker-compose restart
	@echo "✅ Stack Server restarted"

# Show status
status:
	@echo "📊 Stack Server Status"
	@echo ""
	@docker-compose ps

# Show logs
logs:
	@echo "📋 Stack Server Logs (Press Ctrl+C to exit)"
	@echo ""
	@docker-compose logs -f

# Clean everything
clean:
	@echo "⚠️  WARNING: This will remove all data!"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "🧹 Cleaning Stack Server..."
	@docker-compose down -v
	@echo "✅ Stack Server cleaned"

# Run health check
health:
	@echo "🏥 Running health check..."
	@node health-check.js || true

# Install dependencies for health check
install:
	@echo "📦 Installing health check dependencies..."
	@npm install
	@echo "✅ Dependencies installed"

