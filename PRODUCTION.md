# 🚀 Production Deployment Guide

This guide will help you deploy the Stack Server on a production server with Traefik reverse proxy, automatic SSL certificates, and proper security configurations.

## 📋 Prerequisites

- **Server**: Linux VPS/dedicated server with root access
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: Minimum 20GB free space
- **Domain**: A domain name with DNS configured
- **Software**: Docker & Docker Compose installed
- **Ports**: 80 (HTTP) and 443 (HTTPS) open in firewall

## 🌐 DNS Configuration

Before starting, configure your DNS with A records pointing to your server's IP:

```
example.com                  → your-server-ip
*.example.com                → your-server-ip  (wildcard)

# Or configure individual subdomains:
traefik.example.com          → your-server-ip
pgadmin.example.com          → your-server-ip
rabbitmq.example.com         → your-server-ip
minio.example.com            → your-server-ip
minio-api.example.com        → your-server-ip
keycloak.example.com         → your-server-ip
```

## 🔧 Step-by-Step Setup

### 1. Clone/Upload Stack to Server

```bash
# SSH into your server
ssh user@your-server-ip

# Navigate to desired location
cd /opt

# Clone or upload your stack
git clone <your-repo> stack-server
# OR
scp -r ./Stack user@your-server-ip:/opt/stack-server

cd stack-server
```

### 2. Configure Environment Variables

Edit the `.env` file with your production values:

```bash
nano .env
```

**Critical changes:**

```env
# Your actual domain
DOMAIN=example.com

# Your real email for Let's Encrypt notifications
ACME_EMAIL=admin@example.com

# IMPORTANT: Change all default passwords!
POSTGRES_PASSWORD=<strong-random-password>
PGADMIN_DEFAULT_PASSWORD=<strong-random-password>
REDIS_PASSWORD=<strong-random-password>
RABBITMQ_DEFAULT_PASS=<strong-random-password>
MINIO_ROOT_PASSWORD=<strong-random-password>
KEYCLOAK_ADMIN_PASSWORD=<strong-random-password>
```

> 💡 **Tip**: Generate strong passwords with: `openssl rand -base64 32`

### 3. Enable HTTPS in docker-compose.yml

Edit `docker-compose.yml` and uncomment HTTPS lines for each service:

```bash
nano docker-compose.yml
```

**For each service (pgadmin, rabbitmq, minio, keycloak), uncomment these lines:**

```yaml
# Change from:
- "traefik.http.routers.pgadmin.entrypoints=web"

# To (uncomment these):
- "traefik.http.routers.pgadmin.entrypoints=websecure"
- "traefik.http.routers.pgadmin.tls.certresolver=letsencrypt"
- "traefik.http.routers.pgadmin-http.rule=Host(`pgadmin.${DOMAIN:-localhost}`)"
- "traefik.http.routers.pgadmin-http.entrypoints=web"
- "traefik.http.routers.pgadmin-http.middlewares=pgadmin-https-redirect"
- "traefik.http.middlewares.pgadmin-https-redirect.redirectscheme.scheme=https"
```

**Do this for:**
- ✅ pgAdmin (lines ~97-103)
- ✅ RabbitMQ (lines ~156-162)
- ✅ MinIO Console & API (lines ~206-209)
- ✅ Keycloak (lines ~254-260)
- ✅ Traefik Dashboard (lines ~44-46)

### 4. Production Keycloak Configuration

For production, change Keycloak from `start-dev` to production mode:

```yaml
# Find this line in keycloak service:
command: start-dev

# Change to:
command: start

# And update these environment variables:
KC_HOSTNAME_STRICT_HTTPS: 'true'
```

### 5. Set Proper File Permissions

```bash
# Set ownership
sudo chown -R $USER:$USER /opt/stack-server

# Protect .env file
chmod 600 .env

# Make scripts executable
chmod +x stack.sh
```

### 6. Start the Stack

```bash
# Start all services
docker-compose up -d

# Watch logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 7. Wait for SSL Certificates

Traefik will automatically request SSL certificates from Let's Encrypt. This takes 1-2 minutes.

```bash
# Watch Traefik logs for certificate issuance
docker-compose logs -f traefik
```

You should see messages like:
```
time="..." level=info msg="Certificate obtained for domains [pgadmin.example.com]"
```

### 8. Access Your Services

Once certificates are issued, access your services via HTTPS:

| Service | URL |
|---------|-----|
| Traefik Dashboard | https://traefik.example.com |
| pgAdmin | https://pgadmin.example.com |
| RabbitMQ Management | https://rabbitmq.example.com |
| MinIO Console | https://minio.example.com |
| MinIO API | https://minio-api.example.com |
| Keycloak | https://keycloak.example.com |

## 🔒 Security Hardening

### 1. Firewall Configuration

```bash
# Using UFW (Ubuntu)
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 5432/tcp  # PostgreSQL (if needed externally)
sudo ufw allow 6379/tcp  # Redis (if needed externally)
sudo ufw allow 5672/tcp  # RabbitMQ (if needed externally)
sudo ufw enable

# Block direct port access (force through Traefik)
sudo ufw deny 5050  # pgAdmin
sudo ufw deny 8080  # Keycloak
sudo ufw deny 9000  # MinIO
sudo ufw deny 9001  # MinIO Console
sudo ufw deny 15672 # RabbitMQ Management
```

### 2. Secure Traefik Dashboard

Add authentication to Traefik dashboard:

```bash
# Generate password hash
sudo apt-get install apache2-utils
htpasswd -nb admin <your-password>
# Copy the output
```

Add to Traefik service in `docker-compose.yml`:

```yaml
labels:
  - "traefik.http.routers.traefik.middlewares=auth"
  - "traefik.http.middlewares.auth.basicauth.users=admin:$$apr1$$..."  # paste hash here
```

### 3. Limit Database Access

If PostgreSQL/Redis/RabbitMQ don't need external access, remove their port mappings:

```yaml
# Remove or comment out:
# ports:
#   - "5432:5432"  # PostgreSQL
#   - "6379:6379"  # Redis
```

### 4. Enable Docker Security Features

```bash
# Enable Docker user namespace remapping
echo "{\"userns-remap\": \"default\"}" | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

### 5. Regular Updates

```bash
# Update images regularly
docker-compose pull
docker-compose up -d

# Update system packages
sudo apt update && sudo apt upgrade -y
```

## 📊 Monitoring & Logging

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f traefik
docker-compose logs -f postgres
```

### Check Certificate Status

```bash
# List certificates
docker exec stack-traefik cat /letsencrypt/acme.json

# Or use a JSON viewer
docker exec stack-traefik cat /letsencrypt/acme.json | jq
```

### Monitor Resource Usage

```bash
# Docker stats
docker stats

# System resources
htop
```

## 🔧 Maintenance

### Backup Data

```bash
# Backup script
#!/bin/bash
BACKUP_DIR="/backup/stack-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec stack-postgres pg_dumpall -U admin > $BACKUP_DIR/postgres.sql

# Backup volumes
docker run --rm -v stack_postgres_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/postgres_data.tar.gz -C /data .
docker run --rm -v stack_redis_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/redis_data.tar.gz -C /data .
docker run --rm -v stack_minio_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/minio_data.tar.gz -C /data .

echo "Backup completed: $BACKUP_DIR"
```

### Restore from Backup

```bash
# Restore PostgreSQL
cat /backup/postgres.sql | docker exec -i stack-postgres psql -U admin

# Restore volumes
docker run --rm -v stack_postgres_data:/data -v /backup:/backup alpine tar xzf /backup/postgres_data.tar.gz -C /data
```

### Certificate Renewal

Let's Encrypt certificates are automatically renewed by Traefik. No manual intervention needed!

To force renewal (for testing):

```bash
# Remove certificates
docker exec stack-traefik rm /letsencrypt/acme.json
docker-compose restart traefik
```

## 🐛 Troubleshooting

### SSL Certificate Issues

**Problem**: Certificate not issued

**Solutions**:
1. Check DNS is properly configured: `nslookup pgadmin.example.com`
2. Ensure ports 80 and 443 are open: `netstat -tlnp | grep :80`
3. Check Traefik logs: `docker-compose logs traefik`
4. Verify email in `.env` is correct
5. Try Let's Encrypt staging first (uncomment line in docker-compose.yml)

### Service Not Accessible

**Problem**: Can't access service via domain

**Solutions**:
1. Check service is running: `docker-compose ps`
2. Verify DNS resolution: `dig pgadmin.example.com`
3. Check Traefik routing: `docker exec stack-traefik cat /etc/traefik/traefik.yml`
4. View Traefik dashboard: http://your-server-ip:8888

### Database Connection Errors

**Problem**: Services can't connect to PostgreSQL

**Solutions**:
1. Check PostgreSQL is ready: `docker exec stack-postgres pg_isready`
2. View PostgreSQL logs: `docker-compose logs postgres`
3. Verify credentials in `.env`

### Out of Disk Space

```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk usage
df -h
du -sh /var/lib/docker/*
```

## 📈 Scaling & Performance

### Resource Limits

Add resource limits to `docker-compose.yml`:

```yaml
services:
  postgres:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

### Database Performance

```yaml
# PostgreSQL tuning
postgres:
  environment:
    POSTGRES_INITDB_ARGS: "-c shared_buffers=256MB -c max_connections=200"
```

### Redis Persistence

```yaml
redis:
  command: redis-server --requirepass redis123 --appendonly yes
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Stack

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/stack-server
            git pull
            docker-compose pull
            docker-compose up -d
```

## ✅ Production Checklist

Before going live, verify:

- [ ] All default passwords changed
- [ ] `.env` file configured with production values
- [ ] DNS records configured and propagated
- [ ] HTTPS enabled for all services
- [ ] Firewall rules configured
- [ ] Traefik dashboard secured with authentication
- [ ] SSL certificates issued successfully
- [ ] Backup strategy implemented
- [ ] Monitoring set up
- [ ] Test all services accessible via HTTPS
- [ ] Database connection strings updated in applications
- [ ] Health checks passing
- [ ] Logs reviewed for errors

## 📚 Additional Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [PostgreSQL Production Checklist](https://www.postgresql.org/docs/current/security.html)

---

**Need Help?** Check the logs first: `docker-compose logs -f`

