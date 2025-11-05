#!/bin/bash

# Script to open all Stack Server ports in UFW firewall

echo "🔓 Opening Stack Server Ports..."
echo ""

# Check if UFW is active
if ! command -v ufw &> /dev/null; then
    echo "⚠️  UFW not installed. Checking iptables..."
    sudo iptables -L -n | grep -E '5050|8080|9001|15672|8888'
    exit 0
fi

# Open all required ports
echo "Opening HTTP/HTTPS ports..."
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

echo "Opening Traefik dashboard..."
sudo ufw allow 8888/tcp comment 'Traefik Dashboard'

echo "Opening pgAdmin..."
sudo ufw allow 5050/tcp comment 'pgAdmin'

echo "Opening RabbitMQ Management..."
sudo ufw allow 15672/tcp comment 'RabbitMQ Management'

echo "Opening MinIO Console..."
sudo ufw allow 9001/tcp comment 'MinIO Console'
sudo ufw allow 9000/tcp comment 'MinIO API'

echo "Opening Keycloak..."
sudo ufw allow 8080/tcp comment 'Keycloak'

echo "Opening Database ports..."
sudo ufw allow 5432/tcp comment 'PostgreSQL'
sudo ufw allow 6379/tcp comment 'Redis'
sudo ufw allow 5672/tcp comment 'RabbitMQ AMQP'

echo ""
echo "✅ All ports opened!"
echo ""
echo "Current UFW status:"
sudo ufw status numbered

echo ""
echo "🌐 Your services should now be accessible at:"
echo "  Traefik:     http://$(curl -s ifconfig.me):8888"
echo "  pgAdmin:     http://$(curl -s ifconfig.me):5050"
echo "  RabbitMQ:    http://$(curl -s ifconfig.me):15672"
echo "  MinIO:       http://$(curl -s ifconfig.me):9001"
echo "  Keycloak:    http://$(curl -s ifconfig.me):8080"

