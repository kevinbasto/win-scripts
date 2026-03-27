merger# merger.ps1
# Usage: .\merger.ps1 -Branch <branch-name>
# Creates a snapshot of main/master and merges the given branch into it

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Branch
)

# ── Helpers ───────────────────────────────────────────────────────────────────

function Write-Info  ($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok    ($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Err   ($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Assert-LastCommand {
    param([string]$Context)
    if ($LASTEXITCODE -ne 0) {
        Write-Err "$Context (exit code $LASTEXITCODE)"
        exit 1
    }
}

# ── Validate git repo ─────────────────────────────────────────────────────────

if (-not (Test-Path ".git")) {
    Write-Err "No se encontró un repositorio Git en el directorio actual."
    exit 1
}

# ── Detect main branch (main or master) ──────────────────────────────────────

$mainBranch = $null
$candidates = @("main", "master")

foreach ($candidate in $candidates) {
    $exists = git branch --list $candidate 2>$null
    if ($exists) {
        $mainBranch = $candidate
        break
    }
}

if (-not $mainBranch) {
    Write-Err "No se encontró rama 'main' ni 'master' en el repositorio."
    exit 1
}

Write-Info "Rama base detectada: $mainBranch"

# ── Validate source branch exists ────────────────────────────────────────────

$branchExists = git branch --list $Branch 2>$null
if (-not $branchExists) {
    # Check if it exists as a remote branch
    $remoteBranch = git branch -r --list "origin/$Branch" 2>$null
    if (-not $remoteBranch) {
        Write-Err "La rama '$Branch' no existe localmente ni en origin."
        exit 1
    }
    Write-Info "La rama '$Branch' existe en remoto. Creando tracking local..."
    git checkout --track "origin/$Branch"
    Assert-LastCommand "No se pudo hacer checkout de la rama remota '$Branch'"
    git checkout $mainBranch
    Assert-LastCommand "No se pudo volver a '$mainBranch'"
}

# ── Build snapshot tag name ───────────────────────────────────────────────────

$now         = Get-Date
$snapshotTag = "snapshot-" + $now.ToString("ddMMyy-HH:mm")

Write-Info "Nombre del snapshot: $snapshotTag"

# ── Switch to main/master and pull latest ────────────────────────────────────

Write-Info "Cambiando a '$mainBranch'..."
git checkout $mainBranch
Assert-LastCommand "No se pudo hacer checkout de '$mainBranch'"

Write-Info "Actualizando '$mainBranch' desde remoto..."
git pull origin $mainBranch
Assert-LastCommand "No se pudo hacer pull de '$mainBranch'"

# ── Create snapshot tag ───────────────────────────────────────────────────────

Write-Info "Creando tag '$snapshotTag' en '$mainBranch'..."
git tag -a $snapshotTag -m "Snapshot of $mainBranch before merging branch '$Branch' on $($now.ToString('dd/MM/yyyy HH:mm'))"
Assert-LastCommand "No se pudo crear el tag '$snapshotTag'"

Write-Ok "Tag '$snapshotTag' creado correctamente."

# ── Merge source branch ───────────────────────────────────────────────────────

Write-Info "Haciendo merge de '$Branch' en '$mainBranch'..."
git merge $Branch --no-ff -m "Merge branch '$Branch' into $mainBranch [snapshot: $snapshotTag]"

if ($LASTEXITCODE -ne 0) {
    Write-Err "El merge falló o tiene conflictos. Resuelve los conflictos y luego ejecuta 'git merge --continue'."
    Write-Info "El tag '$snapshotTag' sigue disponible para revertir si es necesario: git checkout $snapshotTag"
    exit 1
}

Write-Ok "Merge completado exitosamente."

# ── Summary ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "──────────────────────────────────────────" -ForegroundColor DarkGray
Write-Ok "Resumen:"
Write-Host "  Rama base   : $mainBranch" -ForegroundColor White
Write-Host "  Rama mergeada: $Branch"    -ForegroundColor White
Write-Host "  Snapshot tag : $snapshotTag" -ForegroundColor White
Write-Host ""
Write-Host "  Para revertir a antes del merge:" -ForegroundColor DarkGray
Write-Host "    git reset --hard $snapshotTag"  -ForegroundColor Yellow
Write-Host "──────────────────────────────────────────" -ForegroundColor DarkGray