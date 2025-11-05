# Stack Server - Development Infrastructure

A comprehensive Docker Compose stack for modern application development, including database, cache, message broker, object storage, and authentication services.

## 🚀 Services Included

| Service | Port(s) | Description | Default Credentials |
|---------|---------|-------------|---------------------|
| **Traefik** | 80, 443, 8888 | Reverse proxy & load balancer | - |
| **PostgreSQL** | 5432 | Relational database | `admin` / `admin123` |
| **pgAdmin** | via Traefik | PostgreSQL web interface | `admin@admin.com` / `admin123` |
| **Redis** | 6379 | In-memory cache & data store | Password: `redis123` |
| **RabbitMQ** | 5672 + Traefik | Message broker | `admin` / `admin123` |
| **MinIO** | via Traefik | S3-compatible object storage | `minioadmin` / `minioadmin123` |
| **Keycloak** | via Traefik | Identity & access management | `admin` / `admin123` |

## 📋 Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- At least 4GB of free RAM
- Ports 80, 443, 5432, 6379, 5672, 8888 available
- **Domain not required!** Works with IP addresses or `.localhost` domains

## 🛠️ Quick Start

### 1. Clone or copy this stack

```bash
cd Stack
```

### 2. Configure environment (optional for local dev)

```bash
# Copy .env.example to .env
cp .env.example .env

# For local development, default values work fine
# For production deployment, see PRODUCTION.md
```

### 3. Start all services

```bash
# Using management script (recommended)
.\stack.ps1 up     # Windows PowerShell
./stack.sh up      # Linux/macOS

# Or using docker-compose directly
docker-compose up -d
```

### 4. Access services

**Option A: Via Traefik (subdomain routing):**
- Traefik Dashboard: http://localhost:8888
- pgAdmin: http://pgadmin.localhost
- RabbitMQ: http://rabbitmq.localhost
- MinIO Console: http://minio.localhost
- MinIO API: http://minio-api.localhost
- Keycloak: http://keycloak.localhost

**Option B: Direct Port Access (no domain needed):**

For servers without a domain, use the no-domain configuration:
```bash
docker-compose -f docker-compose.yml -f docker-compose.no-domain.yml up -d
```

Then access via IP address:
- pgAdmin: http://YOUR-IP:5050
- RabbitMQ: http://YOUR-IP:15672
- MinIO: http://YOUR-IP:9001
- Keycloak: http://YOUR-IP:8080

See **[NO-DOMAIN-SETUP.md](NO-DOMAIN-SETUP.md)** for detailed options without a domain.

### 5. Stop all services

```bash
.\stack.ps1 down          # Windows
./stack.sh down           # Linux/macOS
docker-compose down       # Direct
```

### 6. Stop and remove all data

```bash
.\stack.ps1 clean         # Windows
./stack.sh clean          # Linux/macOS
docker-compose down -v    # Direct
```

## 📖 Service Details

### Traefik (Reverse Proxy)
- **Dashboard**: http://localhost:8888
- **HTTP Entry Point**: Port 80
- **HTTPS Entry Point**: Port 443

Traefik automatically routes traffic to services based on subdomain:
- **Local Dev**: `http://[service].localhost` (e.g., http://pgadmin.localhost)
- **Production**: `https://[service].yourdomain.com` (with automatic SSL)

For direct port access without Traefik, uncomment the `ports:` sections in `docker-compose.yml`.

See **[TRAEFIK.md](TRAEFIK.md)** for detailed configuration and **[PRODUCTION.md](PRODUCTION.md)** for server deployment.

### PostgreSQL
- **Connection String**: `postgresql://admin:admin123@localhost:5432/main_db`
- **Host**: `localhost` (or `postgres` from other containers)
- **Port**: `5432`
- **Database**: `main_db`
- **User**: `admin`
- **Password**: `admin123`

### pgAdmin
- **URL (Traefik)**: http://pgadmin.localhost
- **URL (Direct)**: http://localhost:5050 (if ports uncommented)
- **Email**: `admin@admin.com`
- **Password**: `admin123`

**Adding PostgreSQL Server in pgAdmin:**
1. Open http://pgadmin.localhost (or http://localhost:5050)
2. Right-click "Servers" → "Register" → "Server"
3. General tab: Name = `Stack PostgreSQL`
4. Connection tab:
   - Host: `postgres` (or `stack-postgres`)
   - Port: `5432`
   - Database: `main_db`
   - Username: `admin`
   - Password: `admin123`

### Redis
- **Connection String**: `redis://:redis123@localhost:6379`
- **Host**: `localhost` (or `redis` from other containers)
- **Port**: `6379`
- **Password**: `redis123`

**Testing Redis:**
```bash
docker exec -it stack-redis redis-cli -a redis123
> ping
PONG
```

### RabbitMQ
- **Management UI (Traefik)**: http://rabbitmq.localhost
- **Management UI (Direct)**: http://localhost:15672 (if ports uncommented)
- **AMQP Port**: `5672` (always exposed for direct connections)
- **Username**: `admin`
- **Password**: `admin123`
- **Connection String**: `amqp://admin:admin123@localhost:5672/`

### MinIO
- **Console (Traefik)**: http://minio.localhost
- **API (Traefik)**: http://minio-api.localhost
- **Console (Direct)**: http://localhost:9001 (if ports uncommented)
- **API (Direct)**: http://localhost:9000 (if ports uncommented)
- **Access Key**: `minioadmin`
- **Secret Key**: `minioadmin123`

**Using MinIO Client:**
```bash
docker exec -it stack-minio mc alias set local http://localhost:9000 minioadmin minioadmin123
docker exec -it stack-minio mc mb local/my-bucket
```

### Keycloak
- **Admin Console (Traefik)**: http://keycloak.localhost
- **Admin Console (Direct)**: http://localhost:8080 (if ports uncommented)
- **Username**: `admin`
- **Password**: `admin123`

**Note**: First startup may take 1-2 minutes as Keycloak initializes the database.

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
cp .env.example .env
```

Then edit the `.env` file with your preferred credentials.

### Custom Postgres Database

To create additional databases, you can connect to postgres and run:

```bash
docker exec -it stack-postgres psql -U admin -d main_db
CREATE DATABASE myapp_db;
```

## 🐳 Docker Commands

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f postgres
docker-compose logs -f redis
docker-compose logs -f rabbitmq
```

### Restart a service
```bash
docker-compose restart postgres
```

### Check status
```bash
docker-compose ps
```

### Execute commands in containers
```bash
# PostgreSQL
docker exec -it stack-postgres psql -U admin -d main_db

# Redis
docker exec -it stack-redis redis-cli -a redis123

# RabbitMQ
docker exec -it stack-rabbitmq rabbitmqctl status
```

## 🔌 Connecting from Your Applications

### Node.js / TypeScript Examples

**PostgreSQL (using pg):**
```javascript
const { Pool } = require('pg');
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'main_db',
  user: 'admin',
  password: 'admin123'
});
```

**Redis (using ioredis):**
```javascript
const Redis = require('ioredis');
const redis = new Redis({
  host: 'localhost',
  port: 6379,
  password: 'redis123'
});
```

**RabbitMQ (using amqplib):**
```javascript
const amqp = require('amqplib');
const connection = await amqp.connect('amqp://admin:admin123@localhost:5672');
```

**MinIO (using minio):**
```javascript
const Minio = require('minio');
const minioClient = new Minio.Client({
  endPoint: 'localhost',
  port: 9000,
  useSSL: false,
  accessKey: 'minioadmin',
  secretKey: 'minioadmin123'
});
```

### Python Examples

**PostgreSQL (using psycopg2):**
```python
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="main_db",
    user="admin",
    password="admin123"
)
```

**Redis (using redis-py):**
```python
import redis
r = redis.Redis(host='localhost', port=6379, password='redis123', db=0)
```

## 🔒 Security Notes

⚠️ **WARNING**: The default credentials are for **development only**. 

For production use:
1. Change all default passwords
2. Use environment variables or secrets management
3. Enable SSL/TLS connections
4. Restrict network access
5. Use strong passwords (minimum 16 characters)

## 🧹 Maintenance

### Backup PostgreSQL
```bash
docker exec stack-postgres pg_dump -U admin main_db > backup.sql
```

### Restore PostgreSQL
```bash
docker exec -i stack-postgres psql -U admin main_db < backup.sql
```

### Clear Redis cache
```bash
docker exec -it stack-redis redis-cli -a redis123 FLUSHALL
```

### View MinIO storage size
```bash
docker exec stack-minio du -sh /data
```

## 🐛 Troubleshooting

### Port already in use
If you get port conflict errors, either:
- Stop the conflicting service on your host
- Modify the ports in `docker-compose.yml` (e.g., change `5432:5432` to `5433:5432`)

### Services not starting
```bash
# Check logs
docker-compose logs

# Remove everything and start fresh
docker-compose down -v
docker-compose up -d
```

### Keycloak taking too long to start
Keycloak requires PostgreSQL to be fully ready. The first startup takes longer as it creates the database schema. Wait 1-2 minutes and check logs:
```bash
docker-compose logs -f keycloak
```

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
- [Keycloak Documentation](https://www.keycloak.org/documentation)

## 📝 License

This stack configuration is provided as-is for development purposes.

---

**Happy Coding! 🎉**

