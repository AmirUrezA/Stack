# Stack Server Management Script for PowerShell
# Usage: .\stack.ps1 [command]

param(
    [Parameter(Position=0)]
    [ValidateSet('up', 'down', 'restart', 'status', 'logs', 'clean', 'help')]
    [string]$Command = 'help'
)

function Show-Help {
    Write-Host "`n🚀 Stack Server Management`n" -ForegroundColor Cyan
    Write-Host "Usage: .\stack.ps1 [command]`n" -ForegroundColor White
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  up       - Start all services" -ForegroundColor Green
    Write-Host "  down     - Stop all services" -ForegroundColor Green
    Write-Host "  restart  - Restart all services" -ForegroundColor Green
    Write-Host "  status   - Show status of all services" -ForegroundColor Green
    Write-Host "  logs     - Show logs from all services" -ForegroundColor Green
    Write-Host "  clean    - Stop and remove all data (volumes)" -ForegroundColor Green
    Write-Host "  help     - Show this help message" -ForegroundColor Green
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\stack.ps1 up" -ForegroundColor Gray
    Write-Host "  .\stack.ps1 status" -ForegroundColor Gray
    Write-Host "  .\stack.ps1 logs`n" -ForegroundColor Gray
}

function Start-Stack {
    Write-Host "`n🚀 Starting Stack Server...`n" -ForegroundColor Cyan
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack Server started successfully!" -ForegroundColor Green
        Write-Host "`nServices available at:" -ForegroundColor Yellow
        Write-Host "  Traefik:     http://localhost:8888" -ForegroundColor White
        Write-Host "  pgAdmin:     http://pgadmin.localhost" -ForegroundColor White
        Write-Host "  RabbitMQ:    http://rabbitmq.localhost" -ForegroundColor White
        Write-Host "  MinIO:       http://minio.localhost" -ForegroundColor White
        Write-Host "  Keycloak:    http://keycloak.localhost" -ForegroundColor White
        Write-Host "`n  PostgreSQL:  localhost:5432" -ForegroundColor Gray
        Write-Host "  Redis:       localhost:6379`n" -ForegroundColor Gray
    }
}

function Stop-Stack {
    Write-Host "`n🛑 Stopping Stack Server...`n" -ForegroundColor Cyan
    docker-compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack Server stopped successfully!`n" -ForegroundColor Green
    }
}

function Restart-Stack {
    Write-Host "`n🔄 Restarting Stack Server...`n" -ForegroundColor Cyan
    docker-compose restart
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack Server restarted successfully!`n" -ForegroundColor Green
    }
}

function Show-Status {
    Write-Host "`n📊 Stack Server Status`n" -ForegroundColor Cyan
    docker-compose ps
}

function Show-Logs {
    Write-Host "`n📋 Stack Server Logs (Press Ctrl+C to exit)`n" -ForegroundColor Cyan
    docker-compose logs -f
}

function Clean-Stack {
    Write-Host "`n⚠️  WARNING: This will remove all data!`n" -ForegroundColor Red
    $confirmation = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirmation -eq 'yes') {
        Write-Host "`n🧹 Cleaning Stack Server...`n" -ForegroundColor Cyan
        docker-compose down -v
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ Stack Server cleaned successfully!`n" -ForegroundColor Green
        }
    } else {
        Write-Host "`n❌ Operation cancelled`n" -ForegroundColor Yellow
    }
}

# Execute command
switch ($Command) {
    'up'      { Start-Stack }
    'down'    { Stop-Stack }
    'restart' { Restart-Stack }
    'status'  { Show-Status }
    'logs'    { Show-Logs }
    'clean'   { Clean-Stack }
    'help'    { Show-Help }
    default   { Show-Help }
}

