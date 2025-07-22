param (
    [Parameter(Mandatory=$true)]
    [string]$message,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoAdd
)

# Configurar la codificación de salida para PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verificar si Git está instalado
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git no esta instalado o no esta en el PATH." -ForegroundColor Red
    exit 1
}

# Verificar si Node.js está instalado
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js no esta instalado o no esta en el PATH." -ForegroundColor Red
    Write-Host "CONSEJO: Instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Ruta al script de Node.js (ajustar según donde lo guardes)
$scriptPath = Join-Path $PSScriptRoot "commit-logger.js"

# Verificar si el script de Node.js existe
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: No se encontro el script commit-logger.js en: $scriptPath" -ForegroundColor Red
    Write-Host "CONSEJO: Asegurate de que commit-logger.js este en la misma carpeta que este script" -ForegroundColor Yellow
    exit 1
}

try {
    $commitMessage = "[FEAT]: $message"
    
    # Solo ejecutar git add si NO se especificó la flag -NoAdd
    if (-not $NoAdd) {
        Write-Host ">> Añadiendo archivos..." -ForegroundColor Cyan
        $addResult = git add . 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR en git add: $addResult" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "AVISO: Saltando git add (flag -NoAdd especificada)" -ForegroundColor Yellow
    }
    
    Write-Host ">> Realizando commit con mensaje: '$commitMessage'" -ForegroundColor Cyan
    $commitResult = git commit -m $commitMessage 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR en git commit: $commitResult" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ">> Realizando push..." -ForegroundColor Cyan
    $pushResult = git push 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR en git push: $pushResult" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ">> Registrando commit en logs..." -ForegroundColor Cyan
    $nodeResult = & node $scriptPath $message (Get-Location).Path 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR en el script de Node.js: $nodeResult" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "EXITO: Cambios añadidos, commit realizado, push completado y log guardado." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Ocurrio un error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}