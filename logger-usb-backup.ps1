param(
    [switch]$Force
)

# Verificar si Node.js está instalado
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Node.js no está instalado o no está en el PATH."
    Write-Host "💡 Instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Ruta al script de Node.js
$scriptPath = "$PSScriptRoot\usb-backup-logger.js"

# Verificar si el script de Node.js existe
if (-not (Test-Path $scriptPath)) {
    Write-Error "❌ No se encontró el script usb-backup-logger.js en: $scriptPath"
    Write-Host "💡 Asegúrate de que usb-backup-logger.js esté en la misma carpeta que este script" -ForegroundColor Yellow
    exit 1
}

# Verificar si existe la carpeta de logs
$logsPath = "$env:USERPROFILE\logs"
if (-not (Test-Path $logsPath)) {
    Write-Host "❌ No se encontró la carpeta de logs en: $logsPath" -ForegroundColor Red
    Write-Host "💡 Asegúrate de haber ejecutado los otros scripts primero para generar logs" -ForegroundColor Yellow
    exit 1
}

# Mostrar información antes de ejecutar
Write-Host "🎒 BACKUP DE LOGS A USB" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "📁 Carpeta de logs: $logsPath" -ForegroundColor White

$logFiles = Get-ChildItem $logsPath -File | Measure-Object
Write-Host "📊 Archivos a respaldar: $($logFiles.Count)" -ForegroundColor White

if (-not $Force) {
    $confirmation = Read-Host "¿Continuar con el backup? (s/n)"
    if ($confirmation -notmatch '^[sS]$') {
        Write-Host "❌ Backup cancelado por el usuario" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "🚀 Iniciando proceso de backup..." -ForegroundColor Green

try {
    # Ejecutar el script de Node.js
    & node $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 ¡Backup completado exitosamente!" -ForegroundColor Green
        Write-Host "💡 Puedes desconectar tu USB de forma segura" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ El backup falló" -ForegroundColor Red
    }
} catch {
    Write-Error "❌ Error al ejecutar el backup: $_"
    exit 1
}