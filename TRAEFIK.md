# 🌐 Traefik Reverse Proxy Configuration

This document explains how Traefik is configured in the Stack Server and how to customize it.

## 🎯 What is Traefik?

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. It automatically discovers services and configures routing.

### Why Traefik for This Stack?

✅ **Automatic SSL/TLS** - Free Let's Encrypt certificates  
✅ **Docker Integration** - Auto-discovers containers  
✅ **Dynamic Configuration** - No restarts needed  
✅ **Built-in Dashboard** - Visual monitoring  
✅ **Production Ready** - Load balancing, health checks  

## 🏗️ Architecture

```
Internet
    ↓
Traefik (Port 80/443)
    ↓
┌─────────┬──────────┬──────────┬──────────┐
│         │          │          │          │
pgAdmin RabbitMQ  MinIO    Keycloak
(Port 80) (15672)  (9000/1) (8080)
```

## 📝 Configuration Overview

### Entry Points

Traefik has two entry points configured:

```yaml
- "--entrypoints.web.address=:80"      # HTTP
- "--entrypoints.websecure.address=:443"  # HTTPS
```

### Docker Provider

Traefik watches Docker for new containers:

```yaml
- "--providers.docker=true"
- "--providers.docker.exposedbydefault=false"
- "--providers.docker.network=stack-network"
```

### SSL/TLS with Let's Encrypt

Automatic SSL certificate management:

```yaml
- "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
- "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
- "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
```

## 🎛️ Service Routing

Each service is configured with Traefik labels. Here's how they work:

### Example: pgAdmin

```yaml
labels:
  # Enable Traefik for this service
  - "traefik.enable=true"
  
  # Define routing rule (subdomain)
  - "traefik.http.routers.pgadmin.rule=Host(`pgadmin.${DOMAIN}`)"
  
  # Use HTTP entry point
  - "traefik.http.routers.pgadmin.entrypoints=web"
  
  # Internal port to forward to
  - "traefik.http.services.pgadmin.loadbalancer.server.port=80"
```

### With HTTPS (Production)

```yaml
labels:
  - "traefik.enable=true"
  
  # HTTPS router
  - "traefik.http.routers.pgadmin.rule=Host(`pgadmin.${DOMAIN}`)"
  - "traefik.http.routers.pgadmin.entrypoints=websecure"
  - "traefik.http.routers.pgadmin.tls.certresolver=letsencrypt"
  
  # HTTP to HTTPS redirect
  - "traefik.http.routers.pgadmin-http.rule=Host(`pgadmin.${DOMAIN}`)"
  - "traefik.http.routers.pgadmin-http.entrypoints=web"
  - "traefik.http.routers.pgadmin-http.middlewares=pgadmin-https-redirect"
  - "traefik.http.middlewares.pgadmin-https-redirect.redirectscheme.scheme=https"
```

## 🌍 Domain Configuration

### Local Development (Default)

```env
DOMAIN=localhost
```

Access services at:
- http://pgadmin.localhost
- http://rabbitmq.localhost
- http://minio.localhost
- http://keycloak.localhost

> **Note**: `.localhost` domains work automatically in most browsers without DNS configuration.

### Production Server

```env
DOMAIN=example.com
ACME_EMAIL=admin@example.com
```

Access services at:
- https://pgadmin.example.com
- https://rabbitmq.example.com
- https://minio.example.com
- https://keycloak.example.com

## 🔧 Customization Examples

### 1. Add Basic Authentication

Protect a service with username/password:

```bash
# Generate password
htpasswd -nb admin password123
# Output: admin:$apr1$...

# Add to service labels:
labels:
  - "traefik.http.routers.pgadmin.middlewares=pgadmin-auth"
  - "traefik.http.middlewares.pgadmin-auth.basicauth.users=admin:$$apr1$$..."
```

> **Note**: Double `$$` is required in docker-compose.yml

### 2. Add IP Whitelist

Restrict access to specific IPs:

```yaml
labels:
  - "traefik.http.routers.pgadmin.middlewares=pgadmin-ipwhitelist"
  - "traefik.http.middlewares.pgadmin-ipwhitelist.ipwhitelist.sourcerange=192.168.1.0/24,10.0.0.0/8"
```

### 3. Rate Limiting

Limit requests per IP:

```yaml
labels:
  - "traefik.http.routers.api.middlewares=api-ratelimit"
  - "traefik.http.middlewares.api-ratelimit.ratelimit.average=100"
  - "traefik.http.middlewares.api-ratelimit.ratelimit.burst=50"
```

### 4. Custom Headers

Add security headers:

```yaml
labels:
  - "traefik.http.routers.app.middlewares=security-headers"
  - "traefik.http.middlewares.security-headers.headers.customresponseheaders.X-Frame-Options=SAMEORIGIN"
  - "traefik.http.middlewares.security-headers.headers.customresponseheaders.X-Content-Type-Options=nosniff"
```

### 5. Path-Based Routing

Route based on URL path instead of subdomain:

```yaml
# Instead of: pgadmin.example.com
# Use: example.com/pgadmin

labels:
  - "traefik.http.routers.pgadmin.rule=Host(`${DOMAIN}`) && PathPrefix(`/pgadmin`)"
  - "traefik.http.middlewares.pgadmin-stripprefix.stripprefix.prefixes=/pgadmin"
  - "traefik.http.routers.pgadmin.middlewares=pgadmin-stripprefix"
```

### 6. Load Balancing Multiple Instances

Scale a service and load balance:

```bash
# Scale service
docker-compose up -d --scale your-service=3

# Traefik automatically detects and load balances!
```

### 7. Custom TLS Configuration

Use your own certificates:

```yaml
traefik:
  command:
    - "--providers.file.directory=/etc/traefik/dynamic"
  volumes:
    - ./traefik/certs:/etc/traefik/certs:ro
    - ./traefik/dynamic:/etc/traefik/dynamic:ro
```

## 📊 Traefik Dashboard

Access the dashboard at: **http://your-server-ip:8888** or **http://traefik.localhost**

The dashboard shows:
- All registered routers
- Active services
- Middlewares
- Entry points
- Health status

### Secure the Dashboard (Production)

```yaml
# Add authentication
labels:
  - "traefik.http.routers.traefik.middlewares=traefik-auth"
  - "traefik.http.middlewares.traefik-auth.basicauth.users=admin:$$apr1$$..."
  
  # Or disable external access
command:
  - "--api.insecure=false"  # Disable insecure API
```

## 🔍 Debugging

### View Traefik Configuration

```bash
# View logs
docker-compose logs -f traefik

# Check detected routers
docker exec stack-traefik wget -qO- http://localhost:8080/api/http/routers | jq

# Check services
docker exec stack-traefik wget -qO- http://localhost:8080/api/http/services | jq
```

### Common Issues

#### 1. "Gateway Timeout" or "Bad Gateway"

**Cause**: Service is not healthy or wrong port

**Solution**:
```bash
# Check service is running
docker-compose ps

# Check service logs
docker-compose logs service-name

# Verify internal port in service labels
```

#### 2. SSL Certificate Not Issued

**Cause**: DNS not configured or Let's Encrypt rate limit

**Solution**:
```bash
# Check DNS
nslookup pgadmin.example.com

# Use staging environment first
# Uncomment in docker-compose.yml:
# - "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"

# Check Traefik logs
docker-compose logs traefik | grep -i acme
```

#### 3. Service Not Detected

**Cause**: Service not labeled or not on same network

**Solution**:
```yaml
# Ensure service has:
networks:
  - stack-network
labels:
  - "traefik.enable=true"
```

## 🔐 Security Best Practices

### 1. Use HTTPS in Production

Always enable HTTPS and HTTP-to-HTTPS redirects in production.

### 2. Secure the Traefik Dashboard

```yaml
# Move dashboard to HTTPS with auth
labels:
  - "traefik.http.routers.traefik.entrypoints=websecure"
  - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
  - "traefik.http.routers.traefik.middlewares=traefik-auth"
```

### 3. Enable Access Logs

```yaml
command:
  - "--accesslog=true"
  - "--accesslog.filepath=/var/log/traefik/access.log"
volumes:
  - ./logs:/var/log/traefik
```

### 4. Use Security Headers

```yaml
# Add to each service
labels:
  - "traefik.http.middlewares.secure-headers.headers.stsSeconds=31536000"
  - "traefik.http.middlewares.secure-headers.headers.stsIncludeSubdomains=true"
  - "traefik.http.middlewares.secure-headers.headers.stsPreload=true"
```

## 📚 Advanced Topics

### Middleware Chaining

Combine multiple middlewares:

```yaml
labels:
  # Chain: auth → ratelimit → headers
  - "traefik.http.routers.app.middlewares=app-auth,app-ratelimit,app-headers"
  - "traefik.http.middlewares.app-auth.basicauth.users=..."
  - "traefik.http.middlewares.app-ratelimit.ratelimit.average=100"
  - "traefik.http.middlewares.app-headers.headers.customresponseheaders.X-Custom=value"
```

### TCP/UDP Routing

For non-HTTP services:

```yaml
command:
  - "--entrypoints.postgres.address=:5432"
labels:
  - "traefik.tcp.routers.postgres.rule=HostSNI(`*`)"
  - "traefik.tcp.routers.postgres.entrypoints=postgres"
  - "traefik.tcp.services.postgres.loadbalancer.server.port=5432"
```

### File Provider (Static Config)

For complex configurations:

```yaml
# traefik/config.yml
http:
  routers:
    my-router:
      rule: "Host(`example.com`)"
      service: my-service
  services:
    my-service:
      loadBalancer:
        servers:
          - url: "http://service:8080"
```

## 🎓 Learning Resources

- [Traefik Official Docs](https://doc.traefik.io/traefik/)
- [Traefik Docker Provider](https://doc.traefik.io/traefik/providers/docker/)
- [Let's Encrypt with Traefik](https://doc.traefik.io/traefik/https/acme/)
- [Traefik Middlewares](https://doc.traefik.io/traefik/middlewares/overview/)

## 🆘 Getting Help

If you encounter issues:

1. Check Traefik logs: `docker-compose logs traefik`
2. Visit Traefik dashboard: `http://localhost:8888`
3. Verify Docker labels: `docker inspect <container-name>`
4. Test DNS resolution: `nslookup your-domain.com`
5. Check firewall rules: `sudo ufw status`

---

**Happy Routing! 🚀**

