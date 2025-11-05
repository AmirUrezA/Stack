# Stack Server Management Script for PowerShell (No Domain Version)
# This script starts the stack with direct port access - no domain needed!

param(
    [Parameter(Position=0)]
    [ValidateSet('up', 'down', 'restart', 'status', 'logs', 'clean', 'help')]
    [string]$Command = 'help'
)

function Get-ServerIP {
    try {
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
            $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"
        } | Select-Object -First 1).IPAddress
        
        if ($ip) { return $ip }
        return "localhost"
    }
    catch {
        return "localhost"
    }
}

function Show-Help {
    Write-Host "`n🚀 Stack Server Management (No Domain)`n" -ForegroundColor Cyan
    Write-Host "Usage: .\stack-no-domain.ps1 [command]`n" -ForegroundColor White
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  up       - Start all services with direct port access" -ForegroundColor Green
    Write-Host "  down     - Stop all services" -ForegroundColor Green
    Write-Host "  restart  - Restart all services" -ForegroundColor Green
    Write-Host "  status   - Show status of all services" -ForegroundColor Green
    Write-Host "  logs     - Show logs from all services" -ForegroundColor Green
    Write-Host "  clean    - Stop and remove all data (volumes)" -ForegroundColor Green
    Write-Host "  help     - Show this help message`n" -ForegroundColor Green
}

function Start-Stack {
    Write-Host "`n🚀 Starting Stack Server (No Domain Mode)...`n" -ForegroundColor Cyan
    docker-compose -f docker-compose.direct-ports.yml up -d
    
    if ($LASTEXITCODE -eq 0) {
        $serverIP = Get-ServerIP
        
        Write-Host "`n✅ Stack Server started successfully!" -ForegroundColor Green
        Write-Host "`nServices available at:" -ForegroundColor Yellow
        Write-Host "  Dashboard:   http://${serverIP}" -ForegroundColor White
        Write-Host "  pgAdmin:     http://${serverIP}/pgadmin" -ForegroundColor White
        Write-Host "  RabbitMQ:    http://${serverIP}/rabbitmq" -ForegroundColor White
        Write-Host "  MinIO:       http://${serverIP}/minio" -ForegroundColor White
        Write-Host "  Keycloak:    http://${serverIP}/keycloak" -ForegroundColor White
        Write-Host "`nDirect port access:" -ForegroundColor Yellow
        Write-Host "  pgAdmin:     http://${serverIP}:5050" -ForegroundColor Gray
        Write-Host "  RabbitMQ:    http://${serverIP}:15672" -ForegroundColor Gray
        Write-Host "  MinIO:       http://${serverIP}:9001" -ForegroundColor Gray
        Write-Host "  Keycloak:    http://${serverIP}:8080" -ForegroundColor Gray
        Write-Host "`nDatabase connections:" -ForegroundColor Yellow
        Write-Host "  PostgreSQL:  ${serverIP}:5432" -ForegroundColor Gray
        Write-Host "  Redis:       ${serverIP}:6379" -ForegroundColor Gray
        Write-Host "  RabbitMQ:    ${serverIP}:5672`n" -ForegroundColor Gray
    }
}

function Stop-Stack {
    Write-Host "`n🛑 Stopping Stack Server...`n" -ForegroundColor Cyan
    docker-compose -f docker-compose.direct-ports.yml down
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack Server stopped successfully!`n" -ForegroundColor Green
    }
}

function Restart-Stack {
    Write-Host "`n🔄 Restarting Stack Server...`n" -ForegroundColor Cyan
    docker-compose -f docker-compose.direct-ports.yml restart
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack Server restarted successfully!`n" -ForegroundColor Green
    }
}

function Show-Status {
    Write-Host "`n📊 Stack Server Status`n" -ForegroundColor Cyan
    docker-compose -f docker-compose.direct-ports.yml ps
}

function Show-Logs {
    Write-Host "`n📋 Stack Server Logs (Press Ctrl+C to exit)`n" -ForegroundColor Cyan
    docker-compose -f docker-compose.direct-ports.yml logs -f
}

function Clean-Stack {
    Write-Host "`n⚠️  WARNING: This will remove all data!`n" -ForegroundColor Red
    $confirmation = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirmation -eq 'yes') {
        Write-Host "`n🧹 Cleaning Stack Server...`n" -ForegroundColor Cyan
        docker-compose -f docker-compose.direct-ports.yml down -v
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

