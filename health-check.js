#!/usr/bin/env node

/**
 * Stack Server Health Check Script
 * 
 * This script checks if all services are accessible and responding correctly.
 * 
 * Usage:
 *   npm install pg ioredis amqplib minio axios
 *   node health-check.js
 */

const { Client } = require('pg');
const Redis = require('ioredis');
const amqp = require('amqplib');
const Minio = require('minio');
const axios = require('axios');

const services = {
  postgres: {
    name: 'PostgreSQL',
    status: '⏳',
    test: async () => {
      const client = new Client({
        host: 'localhost',
        port: 5432,
        database: 'main_db',
        user: 'admin',
        password: 'admin123',
        connectionTimeoutMillis: 5000,
      });
      await client.connect();
      const result = await client.query('SELECT version()');
      await client.end();
      return { ok: true, version: result.rows[0].version.split(' ')[1] };
    }
  },
  redis: {
    name: 'Redis',
    status: '⏳',
    test: async () => {
      const client = new Redis({
        host: 'localhost',
        port: 6379,
        password: 'redis123',
        connectTimeout: 5000,
        lazyConnect: true,
      });
      await client.connect();
      const pong = await client.ping();
      const info = await client.info('server');
      const version = info.match(/redis_version:(.+)/)[1];
      client.disconnect();
      return { ok: pong === 'PONG', version };
    }
  },
  rabbitmq: {
    name: 'RabbitMQ',
    status: '⏳',
    test: async () => {
      const connection = await amqp.connect('amqp://admin:admin123@localhost:5672', {
        timeout: 5000
      });
      const channel = await connection.createChannel();
      await channel.close();
      await connection.close();
      
      // Get version from management API
      const response = await axios.get('http://localhost:15672/api/overview', {
        auth: { username: 'admin', password: 'admin123' },
        timeout: 5000
      });
      return { ok: true, version: response.data.rabbitmq_version };
    }
  },
  minio: {
    name: 'MinIO',
    status: '⏳',
    test: async () => {
      const client = new Minio.Client({
        endPoint: 'localhost',
        port: 9000,
        useSSL: false,
        accessKey: 'minioadmin',
        secretKey: 'minioadmin123',
      });
      
      const buckets = await client.listBuckets();
      
      // Get version from API
      const response = await axios.get('http://localhost:9000/minio/health/live', {
        timeout: 5000
      });
      
      return { ok: response.status === 200, version: 'latest', buckets: buckets.length };
    }
  },
  keycloak: {
    name: 'Keycloak',
    status: '⏳',
    test: async () => {
      const response = await axios.get('http://localhost:8080/health/ready', {
        timeout: 10000
      });
      return { ok: response.status === 200, status: response.data.status };
    }
  },
  pgadmin: {
    name: 'pgAdmin',
    status: '⏳',
    test: async () => {
      const response = await axios.get('http://localhost:5050/', {
        timeout: 5000,
        validateStatus: (status) => status === 200
      });
      return { ok: response.status === 200 };
    }
  }
};

function formatStatus(passed) {
  return passed ? '✅' : '❌';
}

function printHeader() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║     Stack Server - Health Check Report        ║');
  console.log('╚════════════════════════════════════════════════╝\n');
}

function printResult(name, status, details) {
  const padding = ' '.repeat(12 - name.length);
  let line = `${status} ${name}${padding}`;
  
  if (details) {
    if (details.version) line += ` │ v${details.version}`;
    if (details.buckets !== undefined) line += ` │ ${details.buckets} buckets`;
    if (details.status) line += ` │ ${details.status}`;
  }
  
  console.log(line);
}

function printSummary(results) {
  const passed = results.filter(r => r.passed).length;
  const total = results.length;
  const allPassed = passed === total;
  
  console.log('\n' + '─'.repeat(48));
  console.log(`\nStatus: ${allPassed ? '✅ ALL SERVICES HEALTHY' : '⚠️  SOME SERVICES UNAVAILABLE'}`);
  console.log(`Result: ${passed}/${total} services passed\n`);
  
  if (!allPassed) {
    console.log('💡 Tip: Run "docker-compose logs -f" to view service logs\n');
  }
}

async function checkService(key) {
  const service = services[key];
  try {
    const result = await service.test();
    return {
      name: service.name,
      passed: result.ok,
      details: result
    };
  } catch (error) {
    return {
      name: service.name,
      passed: false,
      error: error.message
    };
  }
}

async function main() {
  printHeader();
  
  console.log('Testing services...\n');
  
  const results = [];
  
  for (const key of Object.keys(services)) {
    const result = await checkService(key);
    results.push(result);
    printResult(result.name, formatStatus(result.passed), result.details);
  }
  
  printSummary(results);
  
  // Exit with error code if any service failed
  const allPassed = results.every(r => r.passed);
  process.exit(allPassed ? 0 : 1);
}

// Handle uncaught errors
process.on('unhandledRejection', (error) => {
  console.error('\n❌ Error:', error.message);
  console.log('\n💡 Make sure the stack is running: docker-compose up -d\n');
  process.exit(1);
});

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { checkService, services };

