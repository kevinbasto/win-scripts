param (
    [Parameter(Mandatory=$false)]
    [switch]$feat,
    
    [Parameter(Mandatory=$false)]
    [switch]$fix,
    
    [Parameter(Mandatory=$false)]
    [switch]$hotfix,
    
    [Parameter(Mandatory=$false)]
    [switch]$refactor,
    
    [Parameter(Mandatory=$true, Position=0)]
    [string]$branchName
)

# Función para mostrar ayuda
function Show-Help {
    Write-Host @"
🌿 Script para crear ramas con prefijos automáticos

USO:
    .\create-branch.ps1 [-feat|-fix|-hotfix|-refactor] <nombre-rama>

EJEMPLOS:
    .\create-branch.ps1 -feat "user-authentication"     → feat/user-authentication
    .\create-branch.ps1 -fix "login-bug"               → fix/login-bug
    .\create-branch.ps1 -hotfix "critical-security"    → hotfix/critical-security
    .\create-branch.ps1 -refactor "database-layer"     → refactor/database-layer
    .\create-branch.ps1 "custom-branch-name"           → custom-branch-name (sin prefijo)

PREFIJOS:
    -feat     → feat/
    -fix      → fix/
    -hotfix   → hotfix/
    -refactor → refactor/
"@ -ForegroundColor Cyan
}

# Verificar si se pidió ayuda
if ($args -contains "--help" -or $args -contains "-h") {
    Show-Help
    exit 0
}

# Determinar el prefijo basado en las flags
$prefix = ""
$flagCount = 0

if ($feat) { $prefix = "feat/"; $flagCount++ }
if ($fix) { $prefix = "fix/"; $flagCount++ }
if ($hotfix) { $prefix = "hotfix/"; $flagCount++ }
if ($refactor) { $prefix = "refactor/"; $flagCount++ }

# Validar que solo se use una flag
if ($flagCount -gt 1) {
    Write-Error "❌ Solo puedes usar una flag de prefijo a la vez."
    Show-Help
    exit 1
}

# Construir el nombre completo de la rama
$fullBranchName = if ($prefix) { "$prefix$branchName" } else { $branchName }

# Validar el nombre de la rama
if ([string]::IsNullOrWhiteSpace($branchName)) {
    Write-Error "❌ El nombre de la rama no puede estar vacío."
    Show-Help
    exit 1
}

# Verificar si Git está instalado
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Git no está instalado o no está en el PATH."
    exit 1
}

# Verificar si Node.js está instalado
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Node.js no está instalado o no está en el PATH."
    Write-Host "💡 Instala Node.js desde https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Ruta al script de Node.js (ajustar según donde lo guardes)
$scriptPath = "$PSScriptRoot\commit-logger.js"

# Verificar si el script de Node.js existe
if (-not (Test-Path $scriptPath)) {
    Write-Error "❌ No se encontró el script commit-logger.js en: $scriptPath"
    Write-Host "💡 Asegúrate de que commit-logger.js esté en la misma carpeta que este script" -ForegroundColor Yellow
    exit 1
}

try {
    Write-Host "🌿 Creando la rama '$fullBranchName'..." -ForegroundColor Cyan
    
    # Verificar si la rama ya existe localmente
    $branchExists = git branch --list $fullBranchName
    if ($branchExists) {
        Write-Error "❌ La rama '$fullBranchName' ya existe localmente."
        exit 1
    }
    
    # Verificar si la rama ya existe en origin
    $remoteBranchExists = git ls-remote --heads origin $fullBranchName
    if ($remoteBranchExists) {
        Write-Error "❌ La rama '$fullBranchName' ya existe en origin."
        exit 1
    }
    
    # Crear la rama local
    git checkout -b $fullBranchName

    Write-Host "🚀 Subiendo la rama a origin..." -ForegroundColor Cyan
    # Subir la rama a origin y configurar upstream
    git push --set-upstream origin $fullBranchName

    Write-Host "📊 Registrando cambio de rama en logs..." -ForegroundColor Cyan
    # Registrar el cambio de rama usando el mismo logger
    $logMessage = "Nueva rama creada: $fullBranchName"
    & node $scriptPath $logMessage (Get-Location).Path

    Write-Host "✅ Rama '$fullBranchName' creada, subida a origin con upstream configurado y registrada en logs." -ForegroundColor Green
    
    # Mostrar información adicional
    Write-Host "`n📋 Información de la rama:" -ForegroundColor Cyan
    Write-Host "   Nombre completo: $fullBranchName" -ForegroundColor White
    if ($prefix) {
        Write-Host "   Prefijo usado: $($prefix.TrimEnd('/'))" -ForegroundColor White
        Write-Host "   Nombre base: $branchName" -ForegroundColor White
    }
}
catch {
    Write-Error "❌ Ocurrió un error: $_"
    exit 1
}