# 🚀 Quick Start Guide

Get up and running with the Stack Server in 3 minutes!

## Step 1: Prerequisites

Make sure you have Docker installed:

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version
```

**Minimum requirements:**
- Docker 20.10+
- Docker Compose 2.0+
- 4GB free RAM
- 10GB free disk space

## Step 2: Start the Stack

### Option A: Using Management Script (Recommended)

**Windows (PowerShell):**
```powershell
.\stack.ps1 up
```

**Linux/macOS:**
```bash
chmod +x stack.sh
./stack.sh up
```

### Option B: Using Docker Compose Directly

```bash
docker-compose up -d
```

## Step 3: Verify Everything is Running

```bash
# Option A: Using script
.\stack.ps1 status        # Windows
./stack.sh status         # Linux/macOS

# Option B: Direct command
docker-compose ps
```

You should see 6 services running:
- ✅ stack-postgres
- ✅ stack-pgadmin
- ✅ stack-redis
- ✅ stack-rabbitmq
- ✅ stack-minio
- ✅ stack-keycloak

## Step 4: Access the Services

Open these URLs in your browser:

### Via Traefik (Recommended)

| Service | URL | Login |
|---------|-----|-------|
| **Traefik Dashboard** | http://localhost:8888 | - |
| **pgAdmin** | http://pgadmin.localhost | admin@admin.com / admin123 |
| **RabbitMQ** | http://rabbitmq.localhost | admin / admin123 |
| **MinIO** | http://minio.localhost | minioadmin / minioadmin123 |
| **Keycloak** | http://keycloak.localhost | admin / admin123 |

### Direct Access (Optional)

To use direct ports instead, uncomment the `ports:` sections in `docker-compose.yml`:

| Service | URL | Login |
|---------|-----|-------|
| **pgAdmin** | http://localhost:5050 | admin@admin.com / admin123 |
| **RabbitMQ** | http://localhost:15672 | admin / admin123 |
| **MinIO** | http://localhost:9001 | minioadmin / minioadmin123 |
| **Keycloak** | http://localhost:8080 | admin / admin123 |

> ⏱️ **Note**: Keycloak may take 1-2 minutes to start on first launch.

## Step 5: Connect from Your Application

### Quick Connection Test

**Node.js Example:**

```javascript
// Install dependencies
// npm install pg ioredis

const { Client } = require('pg');
const Redis = require('ioredis');

// Test PostgreSQL
const pg = new Client({
  host: 'localhost',
  port: 5432,
  database: 'main_db',
  user: 'admin',
  password: 'admin123'
});

pg.connect()
  .then(() => console.log('✅ PostgreSQL connected!'))
  .catch(console.error);

// Test Redis
const redis = new Redis({
  host: 'localhost',
  port: 6379,
  password: 'redis123'
});

redis.ping()
  .then(() => console.log('✅ Redis connected!'))
  .catch(console.error);
```

### Connection Strings

```bash
# PostgreSQL
postgresql://admin:admin123@localhost:5432/main_db

# Redis
redis://:redis123@localhost:6379

# RabbitMQ
amqp://admin:admin123@localhost:5672/

# MinIO API
http://localhost:9000
```

See **[CONNECTIONS.md](CONNECTIONS.md)** for more examples in different languages.

## Step 6: Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f postgres
```

### Stop the Stack
```bash
.\stack.ps1 down      # Windows
./stack.sh down       # Linux/macOS
docker-compose down   # Direct
```

### Restart a Service
```bash
docker-compose restart postgres
```

### Clean Everything (⚠️ Removes all data)
```bash
.\stack.ps1 clean           # Windows
./stack.sh clean            # Linux/macOS
docker-compose down -v      # Direct
```

## Troubleshooting

### Port Already in Use

**Error:** `Bind for 0.0.0.0:5432 failed: port is already allocated`

**Solution:** Stop the conflicting service or change the port in `docker-compose.yml`

```yaml
postgres:
  ports:
    - "5433:5432"  # Change host port to 5433
```

### Service Won't Start

```bash
# Check logs for the specific service
docker-compose logs postgres

# Restart the service
docker-compose restart postgres

# If nothing works, clean and restart
docker-compose down -v
docker-compose up -d
```

### Keycloak Not Loading

Keycloak needs PostgreSQL to be fully ready. Wait 1-2 minutes and check:

```bash
docker-compose logs -f keycloak
```

### Out of Memory

Stop unused containers:

```bash
docker ps -a
docker stop <container-id>
```

## Next Steps

✅ **Configure pgAdmin**: Add PostgreSQL server in pgAdmin  
✅ **Create Buckets**: Set up storage buckets in MinIO  
✅ **Configure Realm**: Set up authentication realm in Keycloak  
✅ **Create Queues**: Set up message queues in RabbitMQ  

See **[README.md](README.md)** for detailed documentation.

## Need Help?

- 📖 Read the full [README.md](README.md)
- 🔌 Check [CONNECTIONS.md](CONNECTIONS.md) for connection examples
- 🐛 Check logs: `docker-compose logs -f`

---

**That's it! Your infrastructure is ready! 🎉**

