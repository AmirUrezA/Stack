#!/bin/bash

# Stack Server Management Script (No Domain Version)
# This script starts the stack with direct port access - no domain needed!

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
    echo -e "\n${CYAN}🚀 Stack Server Management (No Domain)${NC}\n"
    echo -e "${WHITE}Usage: ./stack-no-domain.sh [command]${NC}\n"
    echo -e "${YELLOW}Commands:${NC}"
    echo -e "${GREEN}  up       ${WHITE}- Start all services with direct port access${NC}"
    echo -e "${GREEN}  down     ${WHITE}- Stop all services${NC}"
    echo -e "${GREEN}  restart  ${WHITE}- Restart all services${NC}"
    echo -e "${GREEN}  status   ${WHITE}- Show status of all services${NC}"
    echo -e "${GREEN}  logs     ${WHITE}- Show logs from all services${NC}"
    echo -e "${GREEN}  clean    ${WHITE}- Stop and remove all data (volumes)${NC}"
    echo -e "${GREEN}  help     ${WHITE}- Show this help message${NC}\n"
}

get_server_ip() {
    # Try to get the server's IP address
    if command -v ip &> /dev/null; then
        ip route get 1 | awk '{print $7}' | head -1
    elif command -v hostname &> /dev/null; then
        hostname -I | awk '{print $1}'
    else
        echo "localhost"
    fi
}

start_stack() {
    echo -e "\n${CYAN}🚀 Starting Stack Server (No Domain Mode)...${NC}\n"
    $DOCKER_COMPOSE -f docker-compose.direct-ports.yml up -d
    
    SERVER_IP=$(get_server_ip)
    
    echo -e "\n${GREEN}✅ Stack Server started successfully!${NC}"
    echo -e "\n${YELLOW}Services available at:${NC}"
    echo -e "${WHITE}  Traefik:     http://${SERVER_IP}:8888${NC}"
    echo -e "${WHITE}  pgAdmin:     http://${SERVER_IP}:5050${NC}"
    echo -e "${WHITE}  RabbitMQ:    http://${SERVER_IP}:15672${NC}"
    echo -e "${WHITE}  MinIO:       http://${SERVER_IP}:9001${NC}"
    echo -e "${WHITE}  Keycloak:    http://${SERVER_IP}:8080${NC}"
    echo -e "\n${GRAY}  PostgreSQL:  ${SERVER_IP}:5432${NC}"
    echo -e "${GRAY}  Redis:       ${SERVER_IP}:6379${NC}"
    echo -e "${GRAY}  RabbitMQ:    ${SERVER_IP}:5672${NC}\n"
}

stop_stack() {
    echo -e "\n${CYAN}🛑 Stopping Stack Server...${NC}\n"
    $DOCKER_COMPOSE -f docker-compose.direct-ports.yml down
    echo -e "\n${GREEN}✅ Stack Server stopped successfully!${NC}\n"
}

restart_stack() {
    echo -e "\n${CYAN}🔄 Restarting Stack Server...${NC}\n"
    $DOCKER_COMPOSE -f docker-compose.direct-ports.yml restart
    echo -e "\n${GREEN}✅ Stack Server restarted successfully!${NC}\n"
}

show_status() {
    echo -e "\n${CYAN}📊 Stack Server Status${NC}\n"
    $DOCKER_COMPOSE -f docker-compose.direct-ports.yml ps
}

show_logs() {
    echo -e "\n${CYAN}📋 Stack Server Logs (Press Ctrl+C to exit)${NC}\n"
    $DOCKER_COMPOSE -f docker-compose.direct-ports.yml logs -f
}

clean_stack() {
    echo -e "\n${RED}⚠️  WARNING: This will remove all data!${NC}\n"
    read -p "Are you sure you want to continue? (yes/no): " confirmation
    if [ "$confirmation" = "yes" ]; then
        echo -e "\n${CYAN}🧹 Cleaning Stack Server...${NC}\n"
        $DOCKER_COMPOSE -f docker-compose.direct-ports.yml down -v
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

