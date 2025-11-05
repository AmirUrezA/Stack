# Connection Examples for Stack Services

Quick reference for connecting to each service from your applications.

## 📦 PostgreSQL

### Connection Strings

```bash
# Standard connection string
postgresql://admin:admin123@localhost:5432/main_db

# With psql CLI
psql postgresql://admin:admin123@localhost:5432/main_db
```

### Node.js (pg / TypeORM / Prisma)

```javascript
// Using pg
const { Pool } = require('pg');
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'main_db',
  user: 'admin',
  password: 'admin123',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Using TypeORM
{
  type: "postgres",
  host: "localhost",
  port: 5432,
  username: "admin",
  password: "admin123",
  database: "main_db",
  synchronize: false,
  logging: true
}

// Using Prisma (in .env)
DATABASE_URL="postgresql://admin:admin123@localhost:5432/main_db?schema=public"
```

### Python

```python
# Using psycopg2
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="main_db",
    user="admin",
    password="admin123"
)

# Using SQLAlchemy
from sqlalchemy import create_engine
engine = create_engine('postgresql://admin:admin123@localhost:5432/main_db')

# Using asyncpg (async)
import asyncpg
conn = await asyncpg.connect(
    host='localhost',
    port=5432,
    user='admin',
    password='admin123',
    database='main_db'
)
```

### Go

```go
import (
    "database/sql"
    _ "github.com/lib/pq"
)

connStr := "host=localhost port=5432 user=admin password=admin123 dbname=main_db sslmode=disable"
db, err := sql.Open("postgres", connStr)
```

### Java / Spring Boot

```properties
# application.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/main_db
spring.datasource.username=admin
spring.datasource.password=admin123
spring.datasource.driver-class-name=org.postgresql.Driver
```

---

## 🔴 Redis

### Connection Strings

```bash
# With password
redis://:redis123@localhost:6379

# With redis-cli
redis-cli -h localhost -p 6379 -a redis123
```

### Node.js

```javascript
// Using ioredis (recommended)
const Redis = require('ioredis');
const redis = new Redis({
  host: 'localhost',
  port: 6379,
  password: 'redis123',
  retryStrategy: (times) => {
    return Math.min(times * 50, 2000);
  }
});

// Using node-redis
const { createClient } = require('redis');
const client = createClient({
  url: 'redis://:redis123@localhost:6379'
});
await client.connect();
```

### Python

```python
# Using redis-py
import redis

r = redis.Redis(
    host='localhost',
    port=6379,
    password='redis123',
    db=0,
    decode_responses=True
)

# Using aioredis (async)
import aioredis
redis = await aioredis.create_redis_pool(
    'redis://:redis123@localhost:6379'
)
```

### Go

```go
import "github.com/go-redis/redis/v8"

rdb := redis.NewClient(&redis.Options{
    Addr:     "localhost:6379",
    Password: "redis123",
    DB:       0,
})
```

### Java / Spring Boot

```properties
# application.properties
spring.redis.host=localhost
spring.redis.port=6379
spring.redis.password=redis123
```

---

## 🐰 RabbitMQ

### Connection Strings

```bash
# AMQP connection string
amqp://admin:admin123@localhost:5672/
```

### Node.js

```javascript
// Using amqplib
const amqp = require('amqplib');

const connection = await amqp.connect('amqp://admin:admin123@localhost:5672');
const channel = await connection.createChannel();

// Declare a queue
await channel.assertQueue('my-queue', { durable: true });

// Send message
channel.sendToQueue('my-queue', Buffer.from('Hello World'));

// Consume messages
channel.consume('my-queue', (msg) => {
  console.log('Received:', msg.content.toString());
  channel.ack(msg);
});
```

### Python

```python
# Using pika
import pika

credentials = pika.PlainCredentials('admin', 'admin123')
connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host='localhost',
        port=5672,
        credentials=credentials
    )
)
channel = connection.channel()

# Declare queue
channel.queue_declare(queue='my-queue', durable=True)

# Publish message
channel.basic_publish(
    exchange='',
    routing_key='my-queue',
    body='Hello World'
)
```

### Go

```go
import "github.com/streadway/amqp"

conn, err := amqp.Dial("amqp://admin:admin123@localhost:5672/")
ch, err := conn.Channel()

// Declare queue
q, err := ch.QueueDeclare(
    "my-queue",
    true,   // durable
    false,  // delete when unused
    false,  // exclusive
    false,  // no-wait
    nil,    // arguments
)
```

### Java / Spring Boot

```properties
# application.properties
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=admin
spring.rabbitmq.password=admin123
```

---

## 🗄️ MinIO (S3-Compatible)

### Connection Details

```bash
# Endpoint: http://localhost:9000
# Access Key: minioadmin
# Secret Key: minioadmin123
```

### Node.js

```javascript
// Using minio client
const Minio = require('minio');

const minioClient = new Minio.Client({
  endPoint: 'localhost',
  port: 9000,
  useSSL: false,
  accessKey: 'minioadmin',
  secretKey: 'minioadmin123'
});

// Create bucket
await minioClient.makeBucket('my-bucket', 'us-east-1');

// Upload file
await minioClient.fPutObject('my-bucket', 'file.txt', './local-file.txt');

// Using AWS SDK (S3-compatible)
const AWS = require('aws-sdk');
const s3 = new AWS.S3({
  endpoint: 'http://localhost:9000',
  accessKeyId: 'minioadmin',
  secretAccessKey: 'minioadmin123',
  s3ForcePathStyle: true,
  signatureVersion: 'v4'
});
```

### Python

```python
# Using minio client
from minio import Minio

client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin123",
    secure=False
)

# Create bucket
client.make_bucket("my-bucket")

# Upload file
client.fput_object("my-bucket", "file.txt", "./local-file.txt")

# Using boto3 (AWS SDK)
import boto3
from botocore.client import Config

s3 = boto3.client(
    's3',
    endpoint_url='http://localhost:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123',
    config=Config(signature_version='s3v4')
)
```

### Go

```go
import "github.com/minio/minio-go/v7"
import "github.com/minio/minio-go/v7/pkg/credentials"

minioClient, err := minio.New("localhost:9000", &minio.Options{
    Creds:  credentials.NewStaticV4("minioadmin", "minioadmin123", ""),
    Secure: false,
})

// Create bucket
err = minioClient.MakeBucket(ctx, "my-bucket", minio.MakeBucketOptions{})
```

---

## 🔐 Keycloak

### Admin API

```bash
# Admin Console: http://localhost:8080
# Username: admin
# Password: admin123
```

### Node.js

```javascript
// Using keycloak-admin-client
const KcAdminClient = require('keycloak-admin').default;

const kcAdminClient = new KcAdminClient({
  baseUrl: 'http://localhost:8080',
  realmName: 'master'
});

// Authenticate
await kcAdminClient.auth({
  username: 'admin',
  password: 'admin123',
  grantType: 'password',
  clientId: 'admin-cli'
});

// Using keycloak-connect (for Express.js)
const Keycloak = require('keycloak-connect');
const keycloak = new Keycloak({}, {
  realm: 'your-realm',
  'auth-server-url': 'http://localhost:8080',
  'ssl-required': 'none',
  resource: 'your-client',
  'confidential-port': 0
});
```

### Python

```python
# Using python-keycloak
from keycloak import KeycloakAdmin

keycloak_admin = KeycloakAdmin(
    server_url="http://localhost:8080",
    username="admin",
    password="admin123",
    realm_name="master",
    verify=True
)

# Get users
users = keycloak_admin.get_users({})
```

### Environment Variables (Common)

```bash
# For your application's .env file
POSTGRES_URL=postgresql://admin:admin123@localhost:5432/main_db
REDIS_URL=redis://:redis123@localhost:6379
RABBITMQ_URL=amqp://admin:admin123@localhost:5672/
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123
KEYCLOAK_URL=http://localhost:8080
```

---

## 🐳 Docker Network Connections

When connecting **from within other Docker containers** (same docker-compose or network), use the service name as hostname:

```bash
# PostgreSQL
postgresql://admin:admin123@postgres:5432/main_db

# Redis
redis://:redis123@redis:6379

# RabbitMQ
amqp://admin:admin123@rabbitmq:5672/

# MinIO
http://minio:9000

# Keycloak
http://keycloak:8080
```

### Adding your app to the stack network

```yaml
# In your app's docker-compose.yml
services:
  your-app:
    # ... other config
    networks:
      - stack_stack-network

networks:
  stack_stack-network:
    external: true
```

---

## 🧪 Testing Connections

### Quick Test Script (Node.js)

```javascript
// test-connections.js
const { Client } = require('pg');
const Redis = require('ioredis');
const amqp = require('amqplib');
const Minio = require('minio');

async function testConnections() {
  // Test PostgreSQL
  const pg = new Client({
    host: 'localhost',
    port: 5432,
    database: 'main_db',
    user: 'admin',
    password: 'admin123'
  });
  await pg.connect();
  console.log('✅ PostgreSQL connected');
  await pg.end();

  // Test Redis
  const redis = new Redis({ host: 'localhost', port: 6379, password: 'redis123' });
  await redis.ping();
  console.log('✅ Redis connected');
  redis.disconnect();

  // Test RabbitMQ
  const rabbit = await amqp.connect('amqp://admin:admin123@localhost:5672');
  console.log('✅ RabbitMQ connected');
  await rabbit.close();

  // Test MinIO
  const minio = new Minio.Client({
    endPoint: 'localhost',
    port: 9000,
    useSSL: false,
    accessKey: 'minioadmin',
    secretKey: 'minioadmin123'
  });
  await minio.listBuckets();
  console.log('✅ MinIO connected');
}

testConnections().catch(console.error);
```

Run: `npm i pg ioredis amqplib minio && node test-connections.js`

