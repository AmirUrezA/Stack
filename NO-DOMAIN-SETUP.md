# 🌍 Using Stack Server Without a Domain

You don't need a domain to use this stack! Here are your options:

## 🎯 Option 1: Direct Port Access (Recommended for No Domain)

Access services directly via IP address and port numbers.

### Quick Setup

**Method A: Use the no-domain configuration**

```bash
# Start with direct port access
docker-compose -f docker-compose.yml -f docker-compose.no-domain.yml up -d
```

**Method B: Edit docker-compose.yml manually**

Uncomment the `ports:` sections for each service:

```yaml
pgadmin:
  ports:
    - "5050:80"      # Uncomment this

rabbitmq:
  ports:
    - "15672:15672"  # Uncomment this

minio:
  ports:
    - "9000:9000"    # Uncomment this
    - "9001:9001"    # Uncomment this

keycloak:
  ports:
    - "8080:8080"    # Uncomment this
```

### Access Services

Once started, access via your server's IP address:

```
Traefik Dashboard:  http://YOUR-SERVER-IP:8888
pgAdmin:            http://YOUR-SERVER-IP:5050
RabbitMQ:           http://YOUR-SERVER-IP:15672
MinIO Console:      http://YOUR-SERVER-IP:9001
MinIO API:          http://YOUR-SERVER-IP:9000
Keycloak:           http://YOUR-SERVER-IP:8080

PostgreSQL:         YOUR-SERVER-IP:5432
Redis:              YOUR-SERVER-IP:6379
RabbitMQ AMQP:      YOUR-SERVER-IP:5672
```

**Examples:**
- Local machine: `http://localhost:5050`
- Server: `http://192.168.1.100:5050`
- Public server: `http://123.45.67.89:5050`

---

## 🎯 Option 2: Use .localhost Domains (Local Development)

For local development, `.localhost` domains work without any DNS:

```bash
# Start normally
docker-compose up -d

# Access services
http://pgadmin.localhost
http://rabbitmq.localhost
http://minio.localhost
http://keycloak.localhost
```

This works on most modern browsers without any configuration!

---

## 🎯 Option 3: Use Free Dynamic DNS

Get a free domain that points to your server:

### Free Dynamic DNS Providers:

1. **DuckDNS** (https://www.duckdns.org)
   - Free subdomain: `yourname.duckdns.org`
   - Simple setup
   - Dynamic IP support

2. **No-IP** (https://www.noip.com)
   - Free subdomain: `yourname.ddns.net`
   - Auto-update client

3. **FreeDNS** (https://freedns.afraid.org)
   - Multiple free domains
   - Good for testing

### Setup Example with DuckDNS:

```bash
# 1. Sign up at duckdns.org and get: yourname.duckdns.org

# 2. Update .env file
DOMAIN=yourname.duckdns.org
ACME_EMAIL=your@email.com

# 3. Install DuckDNS update client on your server
mkdir ~/duckdns
cd ~/duckdns
nano duck.sh
```

Add to `duck.sh`:
```bash
#!/bin/bash
echo url="https://www.duckdns.org/update?domains=yourname&token=YOUR-TOKEN&ip=" | curl -k -o ~/duckdns/duck.log -K -
```

```bash
chmod +x duck.sh
# Run every 5 minutes
crontab -e
# Add: */5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1
```

# 4. Start stack with HTTPS
docker-compose up -d

# 5. Access services
https://pgadmin.yourname.duckdns.org
https://rabbitmq.yourname.duckdns.org
https://minio.yourname.duckdns.org
https://keycloak.yourname.duckdns.org
```

---

## 🎯 Option 4: Use Cloudflare Tunnel (Free)

Access your services securely without opening ports!

```bash
# 1. Install cloudflared
# Visit: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/

# 2. Login
cloudflared tunnel login

# 3. Create tunnel
cloudflared tunnel create mystack

# 4. Configure tunnel
nano ~/.cloudflared/config.yml
```

```yaml
tunnel: mystack
credentials-file: /root/.cloudflared/TUNNEL-ID.json

ingress:
  - hostname: pgadmin.yourtunnel.com
    service: http://localhost:5050
  - hostname: rabbitmq.yourtunnel.com
    service: http://localhost:15672
  - hostname: minio.yourtunnel.com
    service: http://localhost:9001
  - hostname: keycloak.yourtunnel.com
    service: http://localhost:8080
  - service: http_status:404
```

```bash
# 5. Run tunnel
cloudflared tunnel run mystack
```

---

## 🎯 Option 5: Use /etc/hosts (Local Only)

For local development, edit your hosts file:

**Windows:** `C:\Windows\System32\drivers\etc\hosts`  
**Linux/Mac:** `/etc/hosts`

Add:
```
127.0.0.1 pgadmin.local
127.0.0.1 rabbitmq.local
127.0.0.1 minio.local
127.0.0.1 keycloak.local
```

Update `.env`:
```env
DOMAIN=local
```

Access at:
- http://pgadmin.local
- http://rabbitmq.local
- http://minio.local
- http://keycloak.local

---

## 📋 Comparison

| Method | Cost | SSL | Easy | Remote Access | Best For |
|--------|------|-----|------|---------------|----------|
| **Direct Ports** | Free | No | ⭐⭐⭐⭐⭐ | Yes | Server without domain |
| **.localhost** | Free | No | ⭐⭐⭐⭐⭐ | No | Local development |
| **Dynamic DNS** | Free | Yes | ⭐⭐⭐ | Yes | Home server |
| **Cloudflare Tunnel** | Free | Yes | ⭐⭐ | Yes | Secure remote access |
| **/etc/hosts** | Free | No | ⭐⭐⭐⭐ | No | Local testing |

---

## 🚀 Quick Start (No Domain)

### For Local Development:

```bash
# Start normally - .localhost works automatically!
./stack.sh up

# Access services
open http://pgadmin.localhost
open http://rabbitmq.localhost
open http://minio.localhost
```

### For Server (No Domain):

```bash
# Use the no-domain configuration
docker-compose -f docker-compose.yml -f docker-compose.no-domain.yml up -d

# Or create override
cp docker-compose.no-domain.yml docker-compose.override.yml
docker-compose up -d

# Access via IP
# http://YOUR-SERVER-IP:5050  (pgAdmin)
# http://YOUR-SERVER-IP:15672 (RabbitMQ)
# http://YOUR-SERVER-IP:9001  (MinIO)
# http://YOUR-SERVER-IP:8080  (Keycloak)
```

---

## 🔒 Security Notes

When using direct ports on a public server:

1. **Use Firewall Rules**
```bash
# Allow only specific IPs
sudo ufw allow from YOUR-HOME-IP to any port 5050
sudo ufw allow from YOUR-HOME-IP to any port 15672
```

2. **Use SSH Tunneling**
```bash
# Access services securely through SSH
ssh -L 5050:localhost:5050 user@server-ip
ssh -L 15672:localhost:15672 user@server-ip
ssh -L 9001:localhost:9001 user@server-ip
ssh -L 8080:localhost:8080 user@server-ip

# Then access locally at http://localhost:5050
```

3. **Use VPN**
- Set up WireGuard or OpenVPN
- Access services through VPN tunnel
- More secure than exposing ports

4. **Change Default Passwords!**
```bash
# Generate strong passwords
openssl rand -base64 32

# Update .env file
POSTGRES_PASSWORD=<strong-password>
REDIS_PASSWORD=<strong-password>
RABBITMQ_DEFAULT_PASS=<strong-password>
MINIO_ROOT_PASSWORD=<strong-password>
KEYCLOAK_ADMIN_PASSWORD=<strong-password>
```

---

## 🎯 Recommended Setup by Use Case

### Local Development
```bash
# Use .localhost domains
docker-compose up -d
# Access: http://pgadmin.localhost
```

### Home Server
```bash
# Get free DuckDNS domain + SSL
DOMAIN=yourname.duckdns.org
docker-compose up -d
# Access: https://pgadmin.yourname.duckdns.org
```

### Cloud Server (No Domain)
```bash
# Use direct ports with firewall
docker-compose -f docker-compose.yml -f docker-compose.no-domain.yml up -d
# Access: http://YOUR-IP:5050
```

### Testing/Staging Server
```bash
# Use SSH tunnels for security
ssh -L 5050:localhost:5050 user@server
# Access: http://localhost:5050
```

---

## 💡 Summary

**You don't need to buy a domain!** 

- **Local dev**: Use `.localhost` domains (already works!)
- **Server**: Use direct IP:PORT access (simplest)
- **Want SSL/domains**: Use free Dynamic DNS services
- **Maximum security**: Use SSH tunnels or VPN

Choose the method that works best for your use case. The stack works perfectly without a domain! 🎉

