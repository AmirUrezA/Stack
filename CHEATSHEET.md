# 📝 Stack Server Cheat Sheet

Quick reference for common tasks and commands.

## 🚀 Start/Stop Commands

```bash
# Start all services
.\stack.ps1 up          # Windows
./stack.sh up           # Linux/macOS
docker-compose up -d    # Direct
make up                 # Make
npm run up              # NPM

# Stop all services
.\stack.ps1 down        # Windows
./stack.sh down         # Linux/macOS
docker-compose down     # Direct
make down               # Make
npm run down            # NPM

# Restart all services
.\stack.ps1 restart     # Windows
./stack.sh restart      # Linux/macOS
docker-compose restart  # Direct
make restart            # Make

# View status
.\stack.ps1 status      # Windows
./stack.sh status       # Linux/macOS
docker-compose ps       # Direct
make status             # Make

# View logs
.\stack.ps1 logs        # Windows
./stack.sh logs         # Linux/macOS
docker-compose logs -f  # Direct
make logs               # Make

# Clean everything (⚠️ removes all data)
.\stack.ps1 clean       # Windows
./stack.sh clean        # Linux/macOS
docker-compose down -v  # Direct
make clean              # Make
```

## 🌐 Service URLs

### Local Development (via Traefik)

```
Traefik Dashboard:  http://localhost:8888
pgAdmin:            http://pgadmin.localhost
RabbitMQ:           http://rabbitmq.localhost
MinIO Console:      http://minio.localhost
MinIO API:          http://minio-api.localhost
Keycloak:           http://keycloak.localhost
```

### Direct Database/Cache Connections

```
PostgreSQL:  localhost:5432
Redis:       localhost:6379
RabbitMQ:    localhost:5672
```

### Production (with your domain)

```
Traefik:     https://traefik.example.com
pgAdmin:     https://pgadmin.example.com
RabbitMQ:    https://rabbitmq.example.com
MinIO:       https://minio.example.com
MinIO API:   https://minio-api.example.com
Keycloak:    https://keycloak.example.com
```

## 🔐 Default Credentials

| Service | Username/Email | Password |
|---------|---------------|----------|
| PostgreSQL | `admin` | `admin123` |
| pgAdmin | `admin@admin.com` | `admin123` |
| Redis | - | `redis123` |
| RabbitMQ | `admin` | `admin123` |
| MinIO | `minioadmin` | `minioadmin123` |
| Keycloak | `admin` | `admin123` |

> ⚠️ **IMPORTANT**: Change these passwords for production!

## 📦 Connection Strings

```bash
# PostgreSQL
postgresql://admin:admin123@localhost:5432/main_db

# Redis
redis://:redis123@localhost:6379

# RabbitMQ
amqp://admin:admin123@localhost:5672/

# MinIO API
http://localhost:9000  # or http://minio-api.localhost

# Keycloak
http://localhost:8080  # or http://keycloak.localhost
```

## 🐳 Docker Commands

```bash
# View container logs
docker logs -f stack-postgres
docker logs -f stack-redis
docker logs -f stack-rabbitmq
docker logs -f stack-minio
docker logs -f stack-keycloak
docker logs -f stack-traefik

# Execute commands in containers
docker exec -it stack-postgres psql -U admin -d main_db
docker exec -it stack-redis redis-cli -a redis123
docker exec -it stack-rabbitmq rabbitmqctl status
docker exec -it stack-minio mc admin info local

# Container shell access
docker exec -it stack-postgres bash
docker exec -it stack-redis sh
docker exec -it stack-rabbitmq sh

# View resource usage
docker stats

# Clean up unused resources
docker system prune
docker system prune -a --volumes  # ⚠️ Removes everything
```

## 🗃️ Database Operations

### PostgreSQL

```bash
# Connect to database
docker exec -it stack-postgres psql -U admin -d main_db

# Create database
docker exec -it stack-postgres psql -U admin -c "CREATE DATABASE myapp_db;"

# List databases
docker exec -it stack-postgres psql -U admin -c "\l"

# Backup database
docker exec stack-postgres pg_dump -U admin main_db > backup.sql

# Restore database
cat backup.sql | docker exec -i stack-postgres psql -U admin main_db

# Backup all databases
docker exec stack-postgres pg_dumpall -U admin > backup-all.sql
```

### Redis

```bash
# Connect to Redis
docker exec -it stack-redis redis-cli -a redis123

# Common Redis commands
> PING
> SET mykey "Hello"
> GET mykey
> KEYS *
> FLUSHALL  # ⚠️ Delete all keys
> INFO
> SAVE  # Save to disk
```

## 📨 RabbitMQ Operations

```bash
# List queues
docker exec stack-rabbitmq rabbitmqctl list_queues

# List exchanges
docker exec stack-rabbitmq rabbitmqctl list_exchanges

# List bindings
docker exec stack-rabbitmq rabbitmqctl list_bindings

# List users
docker exec stack-rabbitmq rabbitmqctl list_users

# Add user
docker exec stack-rabbitmq rabbitmqctl add_user myuser mypassword
docker exec stack-rabbitmq rabbitmqctl set_permissions -p / myuser ".*" ".*" ".*"

# Delete queue
docker exec stack-rabbitmq rabbitmqctl delete_queue myqueue
```

## 🗄️ MinIO Operations

```bash
# List buckets
docker exec stack-minio mc ls local

# Create bucket
docker exec stack-minio mc mb local/mybucket

# Upload file
docker exec stack-minio mc cp /path/to/file.txt local/mybucket/

# Download file
docker exec stack-minio mc cp local/mybucket/file.txt /path/to/destination/

# List bucket contents
docker exec stack-minio mc ls local/mybucket

# Remove bucket
docker exec stack-minio mc rb local/mybucket --force
```

## 🔧 Traefik Operations

```bash
# View Traefik logs
docker logs -f stack-traefik

# View routing configuration
docker exec stack-traefik wget -qO- http://localhost:8080/api/http/routers | jq

# View registered services
docker exec stack-traefik wget -qO- http://localhost:8080/api/http/services | jq

# Check certificate status
docker exec stack-traefik cat /letsencrypt/acme.json | jq

# Access Traefik dashboard
# http://localhost:8888
```

## 🔍 Troubleshooting

```bash
# Check if services are running
docker-compose ps

# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs -f postgres
docker-compose logs -f traefik

# Restart specific service
docker-compose restart postgres

# Rebuild and restart
docker-compose up -d --build

# Check service health
docker inspect --format='{{.State.Health.Status}}' stack-postgres

# Check port usage
netstat -an | grep 5432
netstat -an | grep 80

# Test network connectivity
docker exec stack-postgres ping postgres
docker exec stack-postgres ping redis
```

## 🧹 Maintenance

```bash
# Update images
docker-compose pull
docker-compose up -d

# View disk usage
docker system df

# Clean up unused images
docker image prune -a

# Clean up volumes (⚠️ removes data)
docker volume prune

# Backup entire stack
docker-compose stop
tar czf stack-backup-$(date +%Y%m%d).tar.gz .

# View container sizes
docker ps --size
```

## 📊 Health Checks

```bash
# Run automated health check
npm install
npm run health-check

# Manual health checks
curl http://localhost:8888/api/http/routers  # Traefik
docker exec stack-postgres pg_isready        # PostgreSQL
docker exec stack-redis redis-cli -a redis123 PING  # Redis
docker exec stack-rabbitmq rabbitmq-diagnostics ping  # RabbitMQ
curl http://localhost:9000/minio/health/live  # MinIO
curl http://localhost:8080/health/ready       # Keycloak
```

## 🔒 Security

```bash
# Generate strong password
openssl rand -base64 32

# Generate htpasswd hash (for Traefik auth)
htpasswd -nb admin password123

# Check for security vulnerabilities
docker scan stack-postgres
docker scan stack-redis
```

## 📚 Configuration Files

```
docker-compose.yml              # Main stack configuration
.env                            # Environment variables (create from .env.example)
.env.example                    # Example environment file
docker-compose.override.yml     # Local overrides (optional)
```

## 🌍 Environment Variables

```bash
# Key variables in .env file
DOMAIN=localhost                # Your domain (localhost for dev, example.com for prod)
ACME_EMAIL=admin@example.com    # Email for Let's Encrypt

# Change all passwords in production!
POSTGRES_PASSWORD=admin123
REDIS_PASSWORD=redis123
RABBITMQ_DEFAULT_PASS=admin123
MINIO_ROOT_PASSWORD=minioadmin123
KEYCLOAK_ADMIN_PASSWORD=admin123
```

## 📖 Documentation Files

- `README.md` - Main documentation
- `QUICKSTART.md` - Get started in 3 minutes
- `PRODUCTION.md` - Production deployment guide
- `TRAEFIK.md` - Traefik configuration guide
- `CONNECTIONS.md` - Connection examples for all languages
- `CHEATSHEET.md` - This file

## 💡 Quick Tips

1. **Local development**: Default configuration works out of the box
2. **Production**: Read `PRODUCTION.md` before deploying
3. **Traefik**: Automatically handles SSL certificates in production
4. **Ports**: Database ports (5432, 6379, 5672) are always exposed
5. **Web UIs**: Access via Traefik subdomain (*.localhost or *.yourdomain.com)
6. **Logs**: Always check logs when troubleshooting: `docker-compose logs -f`
7. **Backups**: Backup volumes regularly in production
8. **Passwords**: Change default passwords before going live!

## 🆘 Common Issues

### Port conflicts
```bash
# Check what's using port 80
netstat -ano | findstr :80      # Windows
lsof -i :80                     # Linux/macOS

# Change ports in docker-compose.yml
ports:
  - "8080:80"  # Use 8080 instead of 80
```

### Service won't start
```bash
# Check logs
docker-compose logs service-name

# Remove and recreate
docker-compose rm service-name
docker-compose up -d service-name
```

### Out of disk space
```bash
# Clean Docker resources
docker system prune -a --volumes
```

### Can't access *.localhost domains
- Try using direct ports instead (uncomment in docker-compose.yml)
- Or edit your hosts file to add the domains

---

**Quick Links:**
- Full docs: [README.md](README.md)
- Get started: [QUICKSTART.md](QUICKSTART.md)
- Production: [PRODUCTION.md](PRODUCTION.md)
- Traefik: [TRAEFIK.md](TRAEFIK.md)
- Connections: [CONNECTIONS.md](CONNECTIONS.md)

