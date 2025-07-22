param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# Ruta al script de Node.js (ajustar según donde lo guardes)
$scriptPath = "$PSScriptRoot\vscode-logger.js"

# Verificar si Node.js está instalado
try {
    $null = Get-Command node -ErrorAction Stop
} catch {
    Write-Error "❌ Node.js no está instalado o no está en el PATH"
    Write-Host "💡 Instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Verificar si el script de Node.js existe
if (-not (Test-Path $scriptPath)) {
    Write-Error "❌ No se encontró el script vscode-logger.js en: $scriptPath"
    Write-Host "💡 Asegúrate de que vscode-logger.js esté en la misma carpeta que este script" -ForegroundColor Yellow
    exit 1
}

# Ejecutar el script de Node.js
Write-Host "🔄 Ejecutando logger de VS Code..." -ForegroundColor Cyan
& node $scriptPath $Path