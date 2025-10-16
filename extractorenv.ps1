# Script para invocar extractorenv.js

Write-Host "🚀 Iniciando generador de .env.example" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor Gray
Write-Host ""

# Ruta del script (ajusta según tu usuario)
$scriptPath = "C:\Users\kevin\scripts\extractorenv.js"

# Verificar si existe Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js detectado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Node.js no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "📥 Instala Node.js desde: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Verificar si existe el script extractorenv.js
if (-not (Test-Path $scriptPath)) {
    Write-Host "❌ Error: No se encontró el archivo extractorenv.js" -ForegroundColor Red
    Write-Host "📁 Buscando en: $scriptPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Script extractorenv.js encontrado" -ForegroundColor Green
Write-Host "📂 Carpeta de trabajo: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Ejecutar el script de Node.js
try {
    node $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 Proceso completado exitosamente!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  El script terminó con código de salida: $LASTEXITCODE" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error al ejecutar el script: $_" -ForegroundColor Red
    exit 1
}