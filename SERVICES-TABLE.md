# 📊 Services Reference Table

Quick reference for all services, ports, and credentials in the Stack Server.

## 🌐 Web Services (Access via Browser)

| Service | Port(s) | Via Traefik | Direct Access | Username | Password | Default URL |
|---------|---------|-------------|---------------|----------|----------|-------------|
| **Traefik Dashboard** | 8888 | - | http://localhost:8888 | - | - | http://localhost:8888 |
| **pgAdmin** | 80→5050 | http://pgadmin.localhost | http://localhost:5050 | admin@admin.com | admin123 | http://pgadmin.localhost |
| **RabbitMQ Management** | 15672 | http://rabbitmq.localhost | http://localhost:15672 | admin | admin123 | http://rabbitmq.localhost |
| **MinIO Console** | 9001 | http://minio.localhost | http://localhost:9001 | minioadmin | minioadmin123 | http://minio.localhost |
| **MinIO API** | 9000 | http://minio-api.localhost | http://localhost:9000 | minioadmin | minioadmin123 | http://minio-api.localhost |
| **Keycloak Admin** | 8080 | http://keycloak.localhost | http://localhost:8080 | admin | admin123 | http://keycloak.localhost |

## 🗄️ Database & Cache Services (Direct Connection)

| Service | Port | Host (Local) | Host (Docker) | Username | Password | Connection String |
|---------|------|--------------|---------------|----------|----------|-------------------|
| **PostgreSQL** | 5432 | localhost | postgres | admin | admin123 | `postgresql://admin:admin123@localhost:5432/main_db` |
| **Redis** | 6379 | localhost | redis | - | redis123 | `redis://:redis123@localhost:6379` |
| **RabbitMQ AMQP** | 5672 | localhost | rabbitmq | admin | admin123 | `amqp://admin:admin123@localhost:5672/` |

## 🌍 For Production Server (Replace localhost with your IP)

| Service | Access URL Pattern | Example |
|---------|-------------------|---------|
| **Traefik** | `http://YOUR-IP:8888` | `http://192.168.1.100:8888` |
| **pgAdmin** | `http://YOUR-IP:5050` | `http://192.168.1.100:5050` |
| **RabbitMQ** | `http://YOUR-IP:15672` | `http://192.168.1.100:15672` |
| **MinIO** | `http://YOUR-IP:9001` | `http://192.168.1.100:9001` |
| **Keycloak** | `http://YOUR-IP:8080` | `http://192.168.1.100:8080` |
| **PostgreSQL** | `YOUR-IP:5432` | `192.168.1.100:5432` |
| **Redis** | `YOUR-IP:6379` | `192.168.1.100:6379` |
| **RabbitMQ AMQP** | `YOUR-IP:5672` | `192.168.1.100:5672` |

## 🔐 All Credentials Summary

| Service | Username/Email | Password | Notes |
|---------|---------------|----------|-------|
| **PostgreSQL** | `admin` | `admin123` | Database: `main_db` |
| **pgAdmin** | `admin@admin.com` | `admin123` | Web interface for PostgreSQL |
| **Redis** | *(no username)* | `redis123` | Password-only auth |
| **RabbitMQ** | `admin` | `admin123` | Both AMQP & Management UI |
| **MinIO** | `minioadmin` | `minioadmin123` | Access Key / Secret Key |
| **Keycloak** | `admin` | `admin123` | Admin console access |
| **Traefik** | *(no auth)* | *(no auth)* | Dashboard is open by default |

> ⚠️ **IMPORTANT**: These are default development credentials. **Change them for production!**

## 🔧 How to Change Passwords

Edit the `.env` file:

```env
# PostgreSQL
POSTGRES_USER=admin
POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@admin.com
PGADMIN_DEFAULT_PASSWORD=YOUR_SECURE_PASSWORD

# Redis
REDIS_PASSWORD=YOUR_SECURE_PASSWORD

# RabbitMQ
RABBITMQ_DEFAULT_USER=admin
RABBITMQ_DEFAULT_PASS=YOUR_SECURE_PASSWORD

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=YOUR_SECURE_PASSWORD

# Keycloak
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=YOUR_SECURE_PASSWORD
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

## 🎯 Quick Connection Examples

### From Your Application (Node.js)

```javascript
// PostgreSQL
const pg = require('pg');
const client = new pg.Client('postgresql://admin:admin123@localhost:5432/main_db');

// Redis
const Redis = require('ioredis');
const redis = new Redis({ host: 'localhost', port: 6379, password: 'redis123' });

// RabbitMQ
const amqp = require('amqplib');
const conn = await amqp.connect('amqp://admin:admin123@localhost:5672/');

// MinIO
const Minio = require('minio');
const minio = new Minio.Client({
  endPoint: 'localhost',
  port: 9000,
  useSSL: false,
  accessKey: 'minioadmin',
  secretKey: 'minioadmin123'
});
```

### From Command Line

```bash
# PostgreSQL
psql postgresql://admin:admin123@localhost:5432/main_db

# Redis
redis-cli -h localhost -p 6379 -a redis123

# Test connections
curl http://localhost:8888/api/http/routers  # Traefik
curl http://localhost:9000/minio/health/live  # MinIO
```

## 📝 Port Summary (All Services)

```
Web Services (HTTP):
  80    - Traefik HTTP entry point
  443   - Traefik HTTPS entry point
  8888  - Traefik Dashboard
  5050  - pgAdmin (direct)
  15672 - RabbitMQ Management UI (direct)
  9000  - MinIO API (direct)
  9001  - MinIO Console (direct)
  8080  - Keycloak (direct)

Database/Backend Services:
  5432  - PostgreSQL
  6379  - Redis
  5672  - RabbitMQ AMQP
```

## 🛡️ Security Recommendations

### For Development
✅ Default passwords are fine  
✅ Services exposed on localhost only  

### For Production
❌ **Never use default passwords**  
❌ **Never expose ports directly to internet**  
✅ Use `.env` file with strong passwords  
✅ Use firewall to restrict access  
✅ Use SSH tunnels or VPN  
✅ Enable Traefik authentication  
✅ Use HTTPS with real domain  

### Generate Strong Passwords

```bash
# Generate random passwords
openssl rand -base64 32

# Or use this in your terminal
for service in POSTGRES REDIS RABBITMQ MINIO KEYCLOAK; do
  echo "$service: $(openssl rand -base64 24)"
done
```

---

**Need more details?**
- Connection examples: [CONNECTIONS.md](CONNECTIONS.md)
- Command reference: [CHEATSHEET.md](CHEATSHEET.md)
- Full documentation: [README.md](README.md)

