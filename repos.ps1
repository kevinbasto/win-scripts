# Script PowerShell para invocar el procesador de repositorios en Node.js
param(
    [string]$ReposFile = "repos.txt",
    [string]$LogDir = "logs",
    [int]$MaxConcurrent = 4
)

$ErrorActionPreference = "Stop"

function Write-ColorLog {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

try {
    Write-ColorLog ">> Iniciando procesador de repositorios..." -Color "Cyan"
    Write-Host ""
    
    # Verificar que Node.js está instalado
    try {
        $nodeVersion = node --version 2>$null
        Write-ColorLog "[OK] Node.js encontrado: $nodeVersion" -Color "Green"
    }
    catch {
        Write-ColorLog "[ERROR] Node.js no está instalado o no se encuentra en PATH" -Color "Red"
        Write-ColorLog "Descarga Node.js desde: https://nodejs.org/" -Color "Yellow"
        exit 1
    }
    
    # Verificar que existe el script de Node.js
    $nodeScript = "C:\Users\kevin\scripts\repos.js"
    if (-not (Test-Path $nodeScript)) {
        Write-ColorLog "[ERROR] No se encontró el archivo $nodeScript" -Color "Red"
        Write-ColorLog "Asegúrate de que ambos archivos estén en el mismo directorio:" -Color "Yellow"
        Write-ColorLog "  - repos.ps1 (este archivo)" -Color "Gray"
        Write-ColorLog "  - repos.js (el procesador principal)" -Color "Gray"
        exit 1
    }
    
    Write-ColorLog "[INFO] Ejecutando: node $nodeScript $ReposFile $LogDir $MaxConcurrent" -Color "Gray"
    Write-Host ""
    
    # Ejecutar el script de Node.js
    & node $nodeScript $ReposFile $LogDir $MaxConcurrent
    
    $exitCode = $LASTEXITCODE
    
    Write-Host ""
    if ($exitCode -eq 0) {
        Write-ColorLog "[SUCCESS] Script completado exitosamente" -Color "Green"
    }
    else {
        Write-ColorLog "[ERROR] Script terminó con errores (código: $exitCode)" -Color "Red"
    }
    
    exit $exitCode
}
catch {
    Write-ColorLog "[CRITICAL] Error ejecutando el script: $($_.Exception.Message)" -Color "Red"
    exit 1
}
finally {
    Write-Host ""
    Write-ColorLog "Presiona cualquier tecla para continuar..." -Color "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}