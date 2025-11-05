#!/bin/bash

# Stack Server Management Script for Unix/Linux/macOS
# Usage: ./stack.sh [command]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}Error: Neither 'docker-compose' nor 'docker compose' found!${NC}"
    echo -e "${YELLOW}Please install Docker Compose:${NC}"
    echo -e "${WHITE}  sudo apt-get update${NC}"
    echo -e "${WHITE}  sudo apt-get install docker-compose-plugin${NC}"
    exit 1
fi

show_help() {
    echo -e "\n${CYAN}🚀 Stack Server Management${NC}\n"
    echo -e "${WHITE}Usage: ./stack.sh [command]${NC}\n"
    echo -e "${YELLOW}Commands:${NC}"
    echo -e "${GREEN}  up       ${WHITE}- Start all services${NC}"
    echo -e "${GREEN}  down     ${WHITE}- Stop all services${NC}"
    echo -e "${GREEN}  restart  ${WHITE}- Restart all services${NC}"
    echo -e "${GREEN}  status   ${WHITE}- Show status of all services${NC}"
    echo -e "${GREEN}  logs     ${WHITE}- Show logs from all services${NC}"
    echo -e "${GREEN}  clean    ${WHITE}- Stop and remove all data (volumes)${NC}"
    echo -e "${GREEN}  help     ${WHITE}- Show this help message${NC}"
    echo -e "\n${YELLOW}Examples:${NC}"
    echo -e "${GRAY}  ./stack.sh up${NC}"
    echo -e "${GRAY}  ./stack.sh status${NC}"
    echo -e "${GRAY}  ./stack.sh logs${NC}\n"
}

start_stack() {
    echo -e "\n${CYAN}🚀 Starting Stack Server...${NC}\n"
    $DOCKER_COMPOSE up -d
    echo -e "\n${GREEN}✅ Stack Server started successfully!${NC}"
    echo -e "\n${YELLOW}Services available at:${NC}"
    echo -e "${WHITE}  Traefik:     http://localhost:8888${NC}"
    echo -e "${WHITE}  pgAdmin:     http://pgadmin.localhost${NC}"
    echo -e "${WHITE}  RabbitMQ:    http://rabbitmq.localhost${NC}"
    echo -e "${WHITE}  MinIO:       http://minio.localhost${NC}"
    echo -e "${WHITE}  Keycloak:    http://keycloak.localhost${NC}"
    echo -e "\n${GRAY}  PostgreSQL:  localhost:5432${NC}"
    echo -e "${GRAY}  Redis:       localhost:6379${NC}\n"
}

stop_stack() {
    echo -e "\n${CYAN}🛑 Stopping Stack Server...${NC}\n"
    $DOCKER_COMPOSE down
    echo -e "\n${GREEN}✅ Stack Server stopped successfully!${NC}\n"
}

restart_stack() {
    echo -e "\n${CYAN}🔄 Restarting Stack Server...${NC}\n"
    $DOCKER_COMPOSE restart
    echo -e "\n${GREEN}✅ Stack Server restarted successfully!${NC}\n"
}

show_status() {
    echo -e "\n${CYAN}📊 Stack Server Status${NC}\n"
    $DOCKER_COMPOSE ps
}

show_logs() {
    echo -e "\n${CYAN}📋 Stack Server Logs (Press Ctrl+C to exit)${NC}\n"
    $DOCKER_COMPOSE logs -f
}

clean_stack() {
    echo -e "\n${RED}⚠️  WARNING: This will remove all data!${NC}\n"
    read -p "Are you sure you want to continue? (yes/no): " confirmation
    if [ "$confirmation" = "yes" ]; then
        echo -e "\n${CYAN}🧹 Cleaning Stack Server...${NC}\n"
        $DOCKER_COMPOSE down -v
        echo -e "\n${GREEN}✅ Stack Server cleaned successfully!${NC}\n"
    else
        echo -e "\n${YELLOW}❌ Operation cancelled${NC}\n"
    fi
}

# Main command handler
case "${1:-help}" in
    up)
        start_stack
        ;;
    down)
        stop_stack
        ;;
    restart)
        restart_stack
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_stack
        ;;
    help|*)
        show_help
        ;;
esac

